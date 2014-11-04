#!/usr/bin/perl -l

use JSON;
use Data::Dumper;

$ticket = '{"id":"dcf8246d-8097-4e84-9e8c-eb4a37858115","type":"Stream","ipAddress":"172.18.229.232","resources":["doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be","doms_radioTVCollection:uuid:0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c","doms_radioTVCollection:uuid:8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d"],"userAttributes":{"SBIPRoleMapper":["inhouse"]},"properties":null}';

$json = JSON->new->allow_nonref;

$j = $json->decode($ticket);

$pretty_printed = $json->pretty->encode($j);

print $pretty_printed; 

print $j->{id};
print $j->{ipAddress};
$resources = $j->{resources};

print join(", ", @$resources);

my $requested_resource = "uuid:853a0b31-c944-44a5-8e42-bc9b5bc697b1";

if (!( @$resources ~~ m/$requested_resource$/)) {
    print("Status: 403\n\n");
} else {
    print "match";
}

