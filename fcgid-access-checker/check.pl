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
    use File::Spec::Functions qw(rel2abs);
    use File::Basename qw(dirname);
    my $path = rel2abs($0);
    our $directory = dirname($path);
}

use lib $directory;

use CheckTicket;


### -- configuration start

my $cfg = new Config::Simple("$directory/../fcgid-access-checker.ini");

### -- configuration end

my $memcached_server = $cfg->param("memcached.server") or die "no memcached.server";
my $resource_type = $cfg->param("doms.resource_type") or die "no doms.resource_type";
my $uuid_pattern = $cfg->param("checker.uuid_pattern") or die "no checker.uuid_pattern";
my $ticket_param = $cfg->param("checker.ticket_param") or die "no checket.ticker_param (empty means look in url path)";

#

my $memd = new Cache::Memcached {
    'servers' => [$memcached_server],
    'compress_threshold' => 10_000,
};

my $json = JSON->new->allow_nonref;

my $uuid_regexp = qr/$uuid_pattern/;  # prepared regexp

### -- go

# http://achernar/iipsrv-auth/?DeepZoom=/net/zone1.isilon.sblokalnet/ifs/archive/avis-show-devel/symlinks/e/6/4/4/e644015b-f72b-4e20-8e99-7d7587e8c03e.dzi

while (my $q = CGI::Fast->new) {
    my $ticket_id = "";
    if ($ticket_param eq "") {
	$q->url(-absolute=>1) =~ /$uuid_regexp/;
	$ticket_id = $1;
    } else {
	$ticket_id = $q->param($ticket_param);
    }
    
    my $dz = $q -> param("DeepZoom");
    my $remote_ip = $q->remote_addr();
    my $request_url = $q->url();

    my $status;

    if (defined $dz && $dz =~ /$uuid_regexp/) {

        my $requested_resources = $1;

	my $ticket_content = $memd -> get($ticket_id);

	$status = CheckTicket::returnStatusCodeFor($json, $ticket_content, $remote_ip, $requested_resources, $resource_type);
    } else {
	$status = "200";
    }

    print("Status: $ticket_id $status\n\n");
}
