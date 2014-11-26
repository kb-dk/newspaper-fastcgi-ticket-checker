#!/usr/bin/env perl5

use warnings;
use strict;
use diagnostics;

package CheckTicket;

sub returnStatusCodeFor {
    #
    # Code is deliberately unoptimized! Please don't improve without good reason.
    #
    # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    # 200 = ok
    # 400 = bad request
    # 401 = unauthorized (not allowed)
    # 403 = forbidden
    # 415 = bad media type
    # 500 = internal server error
    # 503 = service unavailable
    
    my ($json, $ticket, $remote_ip, $requested_resource, $resource_type) = @_;

    if (!defined $json) {
	return "500"; # bad environment
    }

    if (!defined $ticket) {
	return "500"; # bad environment
    }

    if (!defined $remote_ip) {
	return "500"; # bad environment
    }

    if (!defined $requested_resource) {
	return "500"; # bad environment
    }
    
    if (!defined $resource_type) {
	return "500"; # bad environment
    }

    my $json_ticket;

    # http://docstore.mik.ua/orelly/perl/cookbook/ch10_13.htm
    eval {
	$json_ticket = $json->decode($ticket);
    };
    if ($@) {
	return "500"; # decode croaked - most likely bad JSON.
    }

    if (!defined $json_ticket) {
	return "500"; # bad ticket
    }

    # -- Check IP number is defined and correct.
    
    if (!defined $remote_ip) {
	return "500"; # bad environment
    }

    my $json_ticket_ipaddress = $json_ticket->{ipAddress};
    if (!defined $json_ticket_ipaddress) {
	return "500"; # bad memcached entry
    }
    
    if (!($remote_ip eq $json_ticket_ipaddress)) {
	return "403"; # different IP-number
    }
    
    # -- Check requested UUID is in list of resources inside ticket.

    my $resource_scalar = $json_ticket->{resources};
    my @resources = @$resource_scalar;

    if (@resources) {

	# look at each resource to extract uuids.
	# doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be
	my $found = (1 == 0);
	
	# NOTE: Possible bottleneck because we need to do string
	# manipulation of the resources array to verify credentials.
	# A simpler string match would most likely be faster.
	
	for my $resource (@resources) {
	    # http://stackoverflow.com/a/6640851/53897
	    $resource =~ m/uuid:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/;
	    if ($1 eq $requested_resource) {
		$found = (1 == 1);
		last;
	    }
	}
	if ($found == (1 == 0)) {
	    return "403"; # not an approved resource
	}
    } else {
	return "500"; # bad memcached entry
    }
    
    # -- Check content type

    if (! ($resource_type eq $json_ticket->{type})) {
	return "415"; # different media requested than approved for
    }      

    # -- Nothing left to check. We're good.
    
    return "200";
}

1;
