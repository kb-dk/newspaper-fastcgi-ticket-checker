#!/usr/bin/perl

use warnings;
use strict; 
use diagnostics;

use CGI::Fast;
use Cache::Memcached;
use CheckTicket;
use Config::Simple;
use IO::Handle;
use JSON;

### -- configuration start

my $cfg = new Config::Simple("../fcgid-access-checker.ini");

### -- configuration end

my $memcached_server = $cfg->param("memcached.server") or die "no memcached.server";
my $resource_type = $cfg->param("doms.resource_type") or die "no doms.resource_type";
my $url_pattern = $cfg->param("doms.url_pattern") or die "no doms.url_pattern";

#

my $memd = new Cache::Memcached {
    'servers' => [$memcached_server],
    'compress_threshold' => 10_000,
};

my $json = JSON->new->allow_nonref;

my $url_regexp = qr/$url_pattern/;  # prepared regexp

### -- go

while (my $q = CGI::Fast->new) {
    my $ticket_id = $q->param("ticket");
    my $remote_ip = $q->remote_addr();
    my $request_url = $q->url();

    my $status;

    if ($request_url =~ /$url_regexp/) {

        my $requested_resources = $1;

	my $ticket_content = $memd -> get($ticket_id);

	$status = CheckTicket::returnStatusCodeFor($json, $ticket_content, $remote_ip, $requested_resources, $resource_type);
    } else {
	$status = "200";
    }

    print("Status: $status\n\n");
}
