#!/usr/bin/perl

use warnings;
#use strict; # gives error with $cfg->...
use diagnostics;

use CGI::Fast;
use Cache::Memcached;
use IO::Handle;
use JSON;
use CheckTicket;
use Config::Simple

### -- configuration start

my $cfg = new Config::Simple("../fcgid-access-checker.ini");

### -- configuration end

my $memcached_server = $cfg->param("memcached.server") or die "no memcached.server";
my $resource_type = $cfg->param("doms.resource_type") or die "no doms.resource_type";
#my $resource_pattern = $cfg->param("doms.resource_pattern") or "die no doms.resource_pattern";


#

my $memd = new Cache::Memcached {
    'servers' => [$memcached_server],
    'compress_threshold' => 10_000,
};

my $json = JSON->new->allow_nonref;

### -- go

while (my $q = CGI::Fast->new) {
   	my $ticket_id = $q->param("ticket");
        my $remote_ip = $q->remote_addr();
        my $request_url = $q->url();

        my $requested_resources = $request_url =~ $resource_pattern;
	my $status = "unset";

        if (!defined $remote_ip) {

	    $status = "500";

	} elsif (!defined $request_url) {

	    $status = "500";
	    
        } elsif (defined $ticket_id) {

	    my $ticket_content = $memd -> get($ticket_id);

	    if (defined $ticket_content) {
		$status = CheckTicket::returnStatusCodeFor($json, $ticket_content, $remote_ip, $requested_resources, $resource_type);
	    } else {
		$status = "404";
	    }
	    
	} else {
	    $status = "400"; # why?
	}

	print("Status: $status\n\n");
}
