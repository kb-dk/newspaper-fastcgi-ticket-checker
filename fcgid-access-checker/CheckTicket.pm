#!/usr/bin/env perl5

use warnings;
use strict;
use diagnostics;

package CheckTicket;

# Currently logs cause for rejection.  Discuss if this is needed/wanted in production.

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
	print STDERR "no json\n";
	return "500"; 
    }

    if (!defined $ticket) {
	print STDERR "no ticket\n";
	return "500"; 
    }

    if (!defined $remote_ip) {
	print STDERR "no remote_ip\n";
	return "500"; 
    }

    if (!defined $requested_resource) {
	print STDERR "no requested_resource\n";
	return "500"; 
    }
    
    if (!defined $resource_type) {
	print STDERR "no resource_type\n";
	return "500"; 
    }

    my $json_ticket;

    # http://docstore.mik.ua/orelly/perl/cookbook/ch10_13.htm
    eval {
	$json_ticket = $json->decode($ticket);
    };

    if ($@) {
	print STDERR "decode croaked - most likely bad JSON\n";
	return "500"; 
    }

    if (!defined $json_ticket) {
        print STDERR "no json_ticket\n";
	return "500"; 
    }

    # -- Check IP number is defined and correct.
    
    if (!defined $remote_ip) {
        print STDERR "bad remote_ip\n";
	return "500";
    }

    my $json_ticket_ipaddress = $json_ticket->{ipAddress};

    if (!defined $json_ticket_ipaddress) {
        print STDERR "bad json_ticket_ipaddress\n";
	return "500";
    }
    
    if (!($remote_ip eq $json_ticket_ipaddress)) {
	print STDERR "IP different: " . $remote_ip . " != " . $json_ticket_ipaddress;
	return "403"; 
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
	    print STDERR "bad resource: $requested_resource not in @resources\n";
	    return "403"; 
	}
    } else {
	print STDERR "bad memcached entry\n";
	return "500";
    }
    
    # -- Check content type

    if (! ($resource_type eq $json_ticket->{type})) {
        print STDERR "different media requested than approved for: resource_type $resource_type != json_ticket{type} " . $json_ticket->{type} . "\n";
	return "415";
    }      

    # -- Nothing left to check. We're good.
    
    return "200";
}

1;
