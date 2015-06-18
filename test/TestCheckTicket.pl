#!/usr/bin/env perl5

package TestCheckTicket;

use lib "../fcgid-access-checker";
use warnings;
use strict;

use CheckTicket 'returnStatusCodeFor';
use JSON;

use Test::More tests => 14;

my $json = JSON->new->allow_nonref;

is($json->decode('{"a": "b"}')->{a}, "b", "json decoding");

# -- first check robustness against bad data

is(CheckTicket::returnStatusCodeFor(), "500", "no args");
is(CheckTicket::returnStatusCodeFor($json, '{"a": "b"', "172.18.229.232", "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d", "Stream"), "500", "bad json");

# -- now have a go at a real ticket.

my $ticket_id = "dcf8246d-8097-4e84-9e8c-eb4a37858115";
my $ticket = '{"id":"'.$ticket_id.'","type":"Stream","ipAddress":"172.18.229.232",'
    .'"resources":["doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be",'
    .'"doms_radioTVCollection:uuid:0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c","doms_radioTVCollection:uuid:8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d"],'
    .'"userAttributes":{"SBIPRoleMapper":["inhouse"]},"properties":null}';


my $statisticsFileContent = "";
my $STDERR_output = "";

open SH, ">", \$statisticsFileContent or die $!;

is(CheckTicket::returnStatusCodeFor($json, $ticket, "", "", "", $ticket_id, *SH), "403", "everything is wrong");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "", "853a0b31-c944-44a5-8e42-bc9b5bc697be", "Stream", $ticket_id, *SH), "403", "wrong ip");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "y","", $ticket_id, *SH), "403", "wrong resource + type");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "y","Stream", $ticket_id, *SH), "403", "wrong resource");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "863a0b31-c944-44a5-8e42-bc9b5bc697be", "NotStream", $ticket_id, *SH), "403", "wrong type, wrong resource");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "853a0b31-c944-44a5-8e42-bc9b5bc697be", "NotStream", $ticket_id, *SH), "415", "wrong type, resource 1");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c", "NotStream", $ticket_id, *SH), "415", "wrong type, resource 2");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d", "NotStream", $ticket_id, *SH), "415", "wrong type, resource 3");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "853a0b31-c944-44a5-8e42-bc9b5bc697be", "Stream", $ticket_id, *SH), "200", "all correct, resource 1");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c", "Stream", $ticket_id, *SH), "200", "all correct, resource 2");
is(CheckTicket::returnStatusCodeFor($json, $ticket, "172.18.229.232", "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d", "Stream", $ticket_id, *SH), "200", "all correct, resource 3");

close(*SH); # for now we do not test the statistics or stderr logged.

#print $statisticsFileContent;

# Local Variables:
# compile-command: "perl TestCheckTicket.pl 2>/dev/null"
# End:
