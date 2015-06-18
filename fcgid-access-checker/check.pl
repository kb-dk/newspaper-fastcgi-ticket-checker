#!/usr/bin/perl

use warnings;
# For some reason the BEGIN-magic cause "use strict" to fail causing
# Apache to consider the script broken.  Could not find quick solution.
#use strict;
use diagnostics;

use CGI::Fast;
use Cache::Memcached;
use Config::Simple;
use IO::Handle;
use JSON;
use Time::HiRes;

# http://learn.perl.org/faq/perlfaq8.html#How-do-I-add-the-directory-my-program-lives-in-to-the-module-library-search-path

BEGIN {
    # Magic to derive directory of running script so we can tell Perl to look there.
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

### -- Prepare data structures

my $memd = new Cache::Memcached {
# HACK!  See above.
#    'servers' => @memcached_servers,
    'servers' => [$memcached_servers],
    'debug' => 0,
    'compress_threshold' => 10_000,
};

my $json = JSON->new->allow_nonref;

my $ticket_uuid_regexp = qr/$ticket_uuid_pattern/;
my $resource_uuid_regexp = qr/$resource_uuid_pattern/;

open(my $STATISTICSHANDLE, "+>>", $statisticsFile) or die "open statistics file $statisticsFile\n";

### -- go

print STDERR "access checker ready using $config_file.  memcached servers=$memcached_servers.\n";

while (my $q = CGI::Fast->new) {

    my $status = "400"; # BAD REQUEST
    
    # http://perldoc.perl.org/CGI.html#OBTAINING-THE-SCRIPT'S-URL
    # "-absolute" gives "/path/to/script.cgi"

    # "." is dirty hack as Config::Simple returns the empty string as an empty array
    my $ticket_uuid_source = ($ticket_param eq ".") ? $q->url(-absolute=>1) : $q->param($ticket_param);
    if (defined $ticket_uuid_source) {
        $ticket_uuid_source =~ /$ticket_uuid_regexp/; # create $1
        my $ticket_id = $1;

        my $resource_uuid_source = ($resource_param eq ".") ? $q->url(-absolute=>1) : $q->param($resource_param);
        if (defined $resource_uuid_source) {
            $resource_uuid_source =~ /$resource_uuid_regexp/; # create $1
            my $resource_id = $1;

            my $remote_ip = $q->remote_addr();

            my $ticket_content = $memd -> get($ticket_id);
            $status = CheckTicket::returnStatusCodeFor($json, $ticket_content, $remote_ip, $resource_id, $resource_type, $ticket_id, $STATISTICSHANDLE);
        }
    }
    print("Status: $status\n\n");
}
close($STATISTICSHANDLE) or die "cannot close $STATISTICSHANDLE";
print STDERR "access checker done.\n";

