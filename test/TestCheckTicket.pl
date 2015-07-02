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
is(CheckTicket::returnStatusCodeFor($json,
                                    '{"a": "b"',
                                    "172.18.229.232",
                                    "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d",
                                    "Stream",
                                    undef,
                                    undef,
                                    undef,
                                    undef),
   "500",
   "bad json");

# -- now have a go at a real ticket.


my $remote_ip="172.18.229.232";
my $requested_resource1 = "0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c";
my $requested_resource2 = "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d";
my $resource_type = "Stream";
my $resource_param1 = "DeepZoom=/net/zone1.isilon.sblokalnet/ifs/archive/avis-show-devel/symlinks/0/c/6/a/0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c.jp2.dzi";
my $resource_param2 = "DeepZoom=/net/zone1.isilon.sblokalnet/ifs/archive/avis-show-devel/symlinks/8/e/a/c/8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d.jp2.dzi";
my $ticket_id = "dcf8246d-8097-4e84-9e8c-eb4a37858115";
my $ignored_resource_pattern = ".*\.dzi\$";
my $ticket = '{"id":"'.$ticket_id.'","type":"'.$resource_type.'","ipAddress":"'.$remote_ip.'",'
    .'"resources":["doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be",'
    .'"doms_newspaperCollection:uuid:'.$requested_resource1.'","doms_newspaperCollection:uuid:'.$requested_resource2.'"],'
    .'"userAttributes":{"SBIPRoleMapper":["inhouse"]},"properties":null}';


my $statisticsFileContent = "";
my $STDERR_output = "";

open SH, ">", \$statisticsFileContent or die $!;



is(CheckTicket::returnStatusCodeFor($json,
                                    $ticket,
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    *SH), "403", "everything is wrong");
is(CheckTicket::returnStatusCodeFor($json,
                                    $ticket,
                                    "",
                                    $requested_resource1,
                                    $resource_type,
                                    $resource_param1,
                                    $ticket_id,
                                    $ignored_resource_pattern,
                                    *SH), "403", "wrong ip");

                                    #TODO fix the rest of these tests
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, "y","", $ticket_id, $ignored_resource_pattern,*SH), "403", "wrong resource + type");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, "y",$resource_type, $ticket_id, $ignored_resource_pattern, *SH), "403", "wrong resource");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, "863a0b31-c944-44a5-8e42-bc9b5bc697be", "NotStream", $ticket_id, $ignored_resource_pattern, *SH), "403", "wrong type, wrong resource");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, "853a0b31-c944-44a5-8e42-bc9b5bc697be", "NotStream", $ticket_id, $ignored_resource_pattern, *SH), "415", "wrong type, resource 1");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, $requested_resource1, "NotStream", $ticket_id, $ignored_resource_pattern, *SH), "415", "wrong type, resource 2");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, $requested_resource2, "NotStream", $ticket_id, $ignored_resource_pattern, *SH), "415", "wrong type, resource 3");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, "853a0b31-c944-44a5-8e42-bc9b5bc697be", $resource_type, $ticket_id, $ignored_resource_pattern, *SH), "200", "all correct, resource 1");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, $requested_resource1, $resource_type, $ticket_id, $ignored_resource_pattern, *SH), "200", "all correct, resource 2");
is(CheckTicket::returnStatusCodeFor($json, $ticket, $remote_ip, $requested_resource2, $resource_type, $ticket_id, $ignored_resource_pattern, *SH), "200", "all correct, resource 3");

close(*SH); # for now we do not test the statistics or stderr logged.

#print $statisticsFileContent;

# Local Variables:
# compile-command: "perl TestCheckTicket.pl 2>/dev/null"
# End:


is(CheckTicket::returnStatusCodeFor($json,
                                    $ticket,
                                    $remote_ip,
                                    $requested_resource1,
                                    $resource_type,
                                    $resource_param1,
                                    $ticket_id,
                                    $ignored_resource_pattern,
                                    *SH), "403", "everything is wrong");
