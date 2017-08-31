#!/usr/bin/perl

use 5.010;

use warnings;
use diagnostics;

use CGI::Fast;
use Cache::Memcached;
use Config::Simple;
use IO::Handle;
use JSON;
use Time::HiRes;

# Magic to derive directory of running script so we can tell Perl to look there.

BEGIN {
    # http://learn.perl.org/faq/perlfaq8.html#How-do-I-add-the-directory-my-program-lives-in-to-the-module-library-search-path
    use File::Spec::Functions qw(rel2abs);
    use File::Basename qw(dirname basename);
    my $path = rel2abs($0);
    our $directory = dirname($path);
    our $config_file = $directory . "/" . basename($0, ".pl") . ".ini";
}

use lib $directory;

use CheckTicket;

### --

my $cfg = new Config::Simple($config_file) or die "No config file: $config_file";



### -- Establish configuration

# There are some very delicate issues with having multiple servers.  USE ONLY ONE FOR NOW.
my $memcached_servers = $cfg->param("memcached_servers") or die "no memcached_servers";

my $resource_type = $cfg->param("resource_type") or die "no resource_type";

my $ticket_uuid_pattern = $cfg->param("ticket_uuid_pattern") or die "no ticket_uuid_pattern";
my $ticket_param = $cfg->param("ticket_param") or die "no ticker_param ('.' means look in url path)";

my $resource_uuid_pattern = $cfg->param("resource_uuid_pattern") or die "no resource_uuid_pattern";
my $resource_param = $cfg->param("resource_param") or die "no resource_param ('.' means look in url path)";

my $statisticsFile = $cfg ->param("statistics_file") or die "no statistics_file";

my $ignored_resource_pattern = $cfg ->param("ignored_resource_pattern") // "";

### -- Prepare data structures

my $memcached_server = new Cache::Memcached {
    # Workaround.  TRA could not figure out how to get an array out of
    # the configuration module.  So only one server supported for now.
    # 'servers' => @memcached_servers,
    'servers' => [$memcached_servers],
	'debug' => 0,
	'compress_threshold' => 10_000,
};

my $json_parser = JSON->new->allow_nonref;

my $ticket_uuid_regexp = qr/$ticket_uuid_pattern/;
my $resource_uuid_regexp = qr/$resource_uuid_pattern/;

# http://docstore.mik.ua/orelly/perl/cookbook/ch07_02.htm
open(my $STATISTICSHANDLE, "+>>", $statisticsFile) or die "open statistics file $statisticsFile\n";

### -- Go

print STDERR "access checker ready using $config_file.  memcached servers=$memcached_servers.\n";

while (my $q = CGI::Fast->new) { # as long as Apache sends them

    my $status = "400"; # BAD REQUEST

    # http://perldoc.perl.org/CGI.html#OBTAINING-THE-SCRIPT'S-URL
    # "-absolute" gives "/path/to/script.cgi"

    # "." is a workaround as Config::Simple returns the empty string as an empty array
    my $ticket_uuid_source = ($ticket_param eq ".") ? $q->url(-absolute=>1) : $q->param($ticket_param);

    if (defined $ticket_uuid_source) {
        $ticket_uuid_source =~ /$ticket_uuid_regexp/; # create $1
        my $ticket_id = $1;

        my $resource_uuid_source = ($resource_param eq ".") ? $q->url(-absolute=>1) : $q->param($resource_param);
        if (defined $resource_uuid_source) {
            $resource_uuid_source =~ /$resource_uuid_regexp/; # create $1
            my $resource_id = $1;

            my $remote_ip = $q->remote_addr();

            my $ticket_content = $memcached_server -> get($ticket_id);

            $status = CheckTicket::logUsageStatisticsAndReturnStatusCodeFor($json_parser,
									    $ticket_content,
									    $remote_ip,
									    $resource_id,
									    $resource_type,
									    $resource_uuid_source,
									    $ticket_id,
									    $ignored_resource_pattern,
									    $STATISTICSHANDLE);
        }
    }
    print("Status: $status\n\n");
}
close($STATISTICSHANDLE) or die "cannot close $STATISTICSHANDLE";
print STDERR "access checker done.\n";

