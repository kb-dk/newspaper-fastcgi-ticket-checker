#!/usr/bin/env perl5

# FastCGI script to be invoked with FcgidAccessChecker from Apache.

use warnings;
use strict;
use diagnostics;

package CheckTicket;

sub usageLogger {
    my ($msg,$resource_type,$log_folder) = @_;
    my @t = localtime;
    $t[5] += 1900;
    $t[4]++;
    my $today = sprintf("%04d-%02d-%02d", @t[5,4,3]);
    my $path = "$log_folder/${resource_type}UsageStatistics_${today}.log";
    open(my $filehandle, '+>>', $path) or do {
        warn "$0: open $path: $!";
        return;
    };
    chomp $msg;
    print $filehandle "$msg\n";
    close $filehandle;
}

sub returnStatusCodeFor {
    #
    # Code is deliberately unoptimized to keep it as simple as possible!
    # Please don't improve without profiling information proving it to be necessary.

    my $TRUE = (1 == 1);
    my $FALSE = (1 == 0);
    
    # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    my $OK = "200";
    my $BAD_REQUEST = "400";
    my $UNAUTHORIZED = "401";
    my $FORBIDDEN = "403";
    my $BAD_MEDIA_TYPE = "415";
    my $INTERNAL_SERVER_ERROR = "500";
    my $SERVICE_UNAVAILABLE = "503";
    
    my ($json_parser, $ticket, $remote_ip, $requested_resource, $resource_type, $ticket_id, $LOGHANDLE) = @_;

    if (!defined $json_parser) {
        print STDERR "no json\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $ticket) {
        print STDERR "no ticket\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $remote_ip) {
        print STDERR "no remote_ip\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $requested_resource) {
        print STDERR "no requested_resource\n";
        return $INTERNAL_SERVER_ERROR;
    }
    
    if (!defined $resource_type) {
        print STDERR "no resource_type\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $LOGHANDLE) {
        print STDERR "no logging file handle\n";
        return $INTERNAL_SERVER_ERROR;
    }

    my $json_ticket;

    # http://docstore.mik.ua/orelly/perl/cookbook/ch10_13.htm
    eval { # decode fails very hard, avoid crashing.
    	$json_ticket = $json_parser->decode($ticket);
    };

    if ($@) {
	print STDERR "decode croaked - most likely bad JSON\n";
	return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $json_ticket) {
        print STDERR "no json_ticket\n";
	return $INTERNAL_SERVER_ERROR;
    }

    # -- Check IP number is defined and correct.
    
    if (!defined $remote_ip) {
        print STDERR "bad remote_ip\n";
	return $INTERNAL_SERVER_ERROR;
    }

    my $json_ticket_ipaddress = $json_ticket->{ipAddress};

    if (!defined $json_ticket_ipaddress) {
        print STDERR "bad json_ticket_ipaddress\n";
	return $INTERNAL_SERVER_ERROR;
    }
    
    if ($remote_ip ne $json_ticket_ipaddress) {
	print STDERR "IP different: " . $remote_ip . " != " . $json_ticket_ipaddress . "\n";
	return $FORBIDDEN;
    }
    
    # -- Check requested UUID is in list of resources inside ticket.

    my $resource_scalar = $json_ticket->{resources};
    my @resources = @$resource_scalar;

    if (@resources) {

        # Fail if the requested resource uuid is not one of the resources described in the ticket.
        # doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be

        my $found = $FALSE;

        # (Note: Array regexp requires perl 5.10 and is experimental,
        # so not used.)

        for my $resource (@resources) {
            # http://stackoverflow.com/a/6640851/53897
            $resource =~ m/uuid:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/;
            if ($1 eq $requested_resource) {
                $found = $TRUE;
                last;
            }
        }
        if ($found == $FALSE) {
            print STDERR "bad resource: $requested_resource not in \[@resources\]\n";
            return $FORBIDDEN;
	}
    } else {
        print STDERR "bad memcached entry\n";
        return $INTERNAL_SERVER_ERROR;
    }
    
    # -- Check content type

    if ($resource_type ne $json_ticket->{type}) {
        print STDERR "different media requested than approved for: resource_type $resource_type != json_ticket{type} " . $json_ticket->{type} . "\n";
	return $BAD_MEDIA_TYPE;
    }

    my $now_string = time();
    my $authlogEntry = {
        'userAttributes' => $json_ticket->{userAttributes},
        'resource_id' => $requested_resource,
        'resource_type' => $resource_type,
        'remote_ip' => $remote_ip,
        'dateTime' =>$now_string,
        'ticket_id' => $ticket_id,
    };
    my $userAttributes = $json_parser->encode($authlogEntry);
    usageLogger($userAttributes,$resource_type,$log_folder);
    # -- Nothing left to check. We're good.
    
    return $OK;
}

1;
