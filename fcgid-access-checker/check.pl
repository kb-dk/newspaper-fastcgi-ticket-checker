#!/usr/bin/perl

use warnings;
#use strict;
use diagnostics;

use CGI::Fast;
use Cache::Memcached;
use Config::Simple;
use IO::Handle;
use JSON;

# http://learn.perl.org/faq/perlfaq8.html#How-do-I-add-the-directory-my-program-lives-in-to-the-module-library-search-path
BEGIN {
    # Magic to derive directory of running script.
    use File::Spec::Functions qw(rel2abs);
    use File::Basename qw(dirname);
    my $path = rel2abs($0);
    our $directory = dirname($path);
}

use lib $directory;

use CheckTicket;


### -- 

my $cfg = new Config::Simple("$directory/../fcgid-access-checker.ini");

### -- 

my $memcached_server = $cfg->param("memcached.server") or die "no memcached.server";
my $resource_type = $cfg->param("checker.resource_type") or die "no checker.resource_type";

my $ticket_uuid_pattern = $cfg->param("checker.ticket_uuid_pattern") or die "no checker.ticket_uuid_pattern";
my $ticket_param = $cfg->param("checker.ticket_param") or die "no checket.ticker_param (empty means look in url path)";

my $resource_uuid_pattern = $cfg->param("checker.resource_uuid_pattern") or die "no checker.resource_uuid_pattern";
my $resource_param = $cfg->param("checker.resource_param") or die "no checket.resource_param (empty means look in url path)";

# 

my $memd = new Cache::Memcached {
    'servers' => [$memcached_server],
    'compress_threshold' => 10_000,
};

my $json = JSON->new->allow_nonref;

# prepare regexps

my $ticket_uuid_regexp = qr/$ticket_uuid_pattern/;
my $resource_uuid_regexp = qr/$resource_uuid_pattern/;

### -- go

print STDERR "access checker running.";

while (my $q = CGI::Fast->new) {
    # http://perldoc.perl.org/CGI.html#OBTAINING-THE-SCRIPT'S-URL
    # -absolute give "/path/to/script.cgi"
    
    my $ticket_uuid_source = ($ticket_param eq ".") ? $q->url(-absolute=>1) : $q->param($ticket_param);
    $ticket_uuid_source =~ /$ticket_uuid_regexp/; # create $1
    my $ticket_id = $1;
   print STDERR "ticket_id " . $ticket_id . "\n";
   print STDERR "R2 " . $resource_param . " - " . (defined $resource_param) . " _ " . $q->url(-absolute=>1) . "\n";
 
    my $resource_uuid_source = ($resource_param ne ".") ? $q->param($resource_param) : $q->url(-absolute=>1);
   print STDERR "R1 " . $resource_uuid_source . "\n";
    $resource_uuid_source =~ /$resource_uuid_regexp/; # create $1
    my $resource_id = $1;
	print STDERR "resource_id: $resource_id\n";
    
    my $remote_ip = $q->remote_addr();
    my $request_url = $q->url();

    my $ticket_content = $memd -> get($ticket_id);

    my $status = CheckTicket::returnStatusCodeFor($json, $ticket_content, $remote_ip, $resource_id, $resource_type);

    print("Status: $status\n\n");
}
