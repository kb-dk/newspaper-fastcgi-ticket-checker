#!/usr/bin/env perl5

package TestCheckTicket;

use lib "../fcgid-access-checker";
use warnings;
use strict;

use CheckTicket 'returnStatusCodeFor';
use JSON;

use Test::More tests => 10;

my $json = JSON->new->allow_nonref;



my $remote_ip="172.18.229.232";

my $requested_newspaper_page1 = "0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c";

my $requested_newspaper_page2 = "8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d";

my $requested_radio_tv_resource = "853a0b31-c944-44a5-8e42-bc9b5bc697be";

my $resource_type = "Stream";

my $resource_param1 = "DeepZoom=/net/zone1.isilon.sblokalnet/ifs/archive/"
	. "avis-show-devel/symlinks/0/c/6/a/$requested_newspaper_page1.jp2.dzi";

my $resource_param2 = "DeepZoom=/net/zone1.isilon.sblokalnet/ifs/archive/"
	. "avis-show-devel/symlinks/8/e/a/c/$requested_newspaper_page2.jp2.dzi";

my $ticket_id = "dcf8246d-8097-4e84-9e8c-eb4a37858115";

my $ignored_resource_pattern = ".*\.dzi\$";

my $ticket = '{"id":"' . $ticket_id
	. '","type":"' . $resource_type
	. '","ipAddress":"' . $remote_ip
	. '","resources":['
		. '"doms_radioTVCollection:uuid:' . $requested_radio_tv_resource . '",'
		. '"doms_newspaperCollection:uuid:' . $requested_newspaper_page1 . '",'
		. '"doms_newspaperCollection:uuid:' . $requested_newspaper_page2
	. '"],'
    . '"userAttributes":{"SBIPRoleMapper":["inhouse"]},"properties":null}';

my $disallowed_resource = 'aaaaaab8-a3c4-4dfc-9ece-1d7c8ffc908c';


my $statisticsFileContent = "";
my $STDERR_output = "";

# Print to string
open SH, ">", \$statisticsFileContent or die $!;


# The parameters for CheckTicket::returnStatusCodeFor are:
#    $json_parser,
#    $ticket,
#    $remote_ip,
#    $requested_resource,
#    $resource_type,
#    $resource_param,
#    $ticket_id,
#    $ignored_resource_pattern,
#    $LOGHANDLE


# Test "json decoding": Ensure that the JSON library's decoder works
is($json->decode('{"a": "b"}')->{a}, "b", "json decoding");


# -- first check robustness against bad data

# Test "no args": Check that a call with no args gives an error 500
is(CheckTicket::returnStatusCodeFor(), "500", "no args");

# Test "bad json": Check that invalid JSON gives an error 500
is(CheckTicket::returnStatusCodeFor($json,
		'{"a": "b"',
		$remote_ip,
		$requested_newspaper_page2,
		$resource_type,
		undef,
		undef,
		undef,
		undef),
	"500",
	"bad json");


# -- now have a go at a real ticket.

# Test "everything is wrong": Check that many missing parameters => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		"",
		"",
		"",
		"",
		"",
		"",
		*SH),
	"403",
	"everything is wrong");

# Test "wrong ip": Check that missing remote ip => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		"",
		$requested_newspaper_page1,
		$resource_type,
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"403",
	"wrong ip");

# Test "wrong resource + type": Check that bad resource and type => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		$remote_ip,
		"wrong ressource",
		"no type",
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"403",
	"wrong resource + type");

# Test "wrong resource": Check that bad resource => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		$remote_ip,
		"wrong ressource",
		$resource_type,
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"403",
	"wrong resource");

# Test "wrong type, wrong resource": Check that non-matching resource => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		$remote_ip,
		$disallowed_resource,
		$resource_type,
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"403",
	"wrong type, wrong resource");

# Test "wrong type, resource 3": Check that non-allowed resource type => a 415
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		$remote_ip,
		$requested_radio_tv_resource,
		"NotStream",
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"415",
	"wrong type, resource 3");

# Test "all correct, resource 1": Check that bad resource => a 403
is(CheckTicket::returnStatusCodeFor($json,
		$ticket,
		$remote_ip,
		$requested_newspaper_page1,
		$resource_type,
		$resource_param1,
		$ticket_id,
		$ignored_resource_pattern,
		*SH),
	"200",
	"all correct, resource 1");

close(*SH); # for now we do not test the statistics or stderr logged.

#print $statisticsFileContent;

# Local Variables:
# compile-command: "perl TestCheckTicket.pl 2>/dev/null"
# End:

