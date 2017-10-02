#!/usr/bin/perl -l

use JSON;
use Data::Dumper;
use Cache::Memcached;

my $memd = new Cache::Memcached {
            'servers'                => [ "alhena:11211" ],
                'compress_threshold' => 10_000,
        };

my $ticket = "48a6f480-ebef-47d9-896e-2fda9e7a3168";

my $rawticket = $memd->get($ticket);

$json = JSON->new->allow_nonref;

$j = $json->decode($rawticket);

$pretty_printed = $json->pretty->encode($j);

print $pretty_printed;

print $j->{id};
print $j->{ipAddress};
$resources = $j->{resources};

print join(", ", @$resources);

my $requested_resource = "uuid:853a0b31-c944-44a5-8e42-bc9b5bc697b1";

if (!(@$resources ~~ m/$requested_resource$/)) {
    print("Status: 403\n\n");
} else {
    print "match";
}

