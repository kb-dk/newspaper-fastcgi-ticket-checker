#!/usr/bin/env perl5

# FastCGI script to be invoked with FcgidAccessChecker from Apache.
#
# If "} else" is split on two lines when reformatting the source in IntelliJ, see /README.md for instructions.
#


use warnings;
use strict;
# use diagnostics; # not present in docker image.
use Fcntl qw<LOCK_EX LOCK_UN>;

package CheckTicket;

# Parse the ticket, validates the ticket, logs the usage to the usage
# logs if relevant (see ignored resource pattern) and then returns the
# appropriate status code.

sub logUsageStatisticsAndReturnStatusCodeFor {
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

    my ($json_parser,
        $ticket,
        $remote_ip,
        $requested_resource,
        $resource_type,
        $resource_param,
        $ticket_id,
        $ignored_resource_pattern,
        $LOGHANDLE) = @_;

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

    if (!defined $resource_param) {
        print STDERR "no resource_param\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $ticket_id) {
        print STDERR "no ticket id\n";
        return $INTERNAL_SERVER_ERROR;
    }

    if (!defined $LOGHANDLE) {
        print STDERR "no logging file handle\n";
        return $INTERNAL_SERVER_ERROR;
    }

    my $json_ticket;

    # http://docstore.mik.ua/orelly/perl/cookbook/ch10_13.htm
    eval {# decode fails very hard, avoid crashing.
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

        # Fail if the requested resource uuid is not one of the
        # resources described in the ticket.
        # DOMS record ID:         doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be
        # Preservica resource ID: 1bee2176-9f62-4f66-9854-ee0e61724359
        my $found = $FALSE;

        # (Note: Array regexp requires perl 5.10 and is experimental,
        # so not used.)

        for my $resource (@resources) {
            # http://stackoverflow.com/a/6640851/53897
            if ( $resource =~ m/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/ ) {
                if ($1 eq $requested_resource) {
                    $found = $TRUE;
                    last;
                }
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

    if (length $ignored_resource_pattern and $resource_param =~ /$ignored_resource_pattern/) {
        # If the ignored resource pattern is defined and the resource
        # param matches, do NOT log this.  The ignored resource
        # pattern is meant to filter out the dzi requests from the
        # jpeg requests. DZI only get the image dimensions, and should
        # not count as an actual request to view the image
    } else {

        # -- Log information for statistics

        my $now_string = time();
        my $statisticsMap = {
            'userAttributes' => $json_ticket->{userAttributes},
            'resource_id'    => $requested_resource,
            'resource_type'  => $resource_type,
            'remote_ip'      => $remote_ip,
            'dateTime'       => $now_string,
            'ticket_id'      => $ticket_id,
        };

        my $statisticsLine = $json_parser->encode($statisticsMap);

        flock($LOGHANDLE, Fcntl::LOCK_EX);
        print $LOGHANDLE localtime() . ": $statisticsLine\n";
        flock($LOGHANDLE, Fcntl::LOCK_UN);
    }

    # -- Nothing left to do. We're good.

    return $OK;
}

1; # exit code needed for module.
