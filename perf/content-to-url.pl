#!/usr/bin/env perl5

use warnings;
use strict;
use diagnostics;
use LWP::Simple;

use 5.010;

# Sample input:
# {"doms_aviser_page:uuid:c6cae90b-546a-4c6e-b5ca-40c3a29624a8":{"resource":[{"type":"Download","url":["http://achernar.statsbiblioteket.dk/newspaper-pdf-auth/c/6/c/a/c6cae90b-546a-4c6e-b5ca-40c3a29624a8.pdf?ticket=[ticketId]"]}]}}
#
# {"doms_aviser_page:uuid:d5b2f340-c996-4869-8b0b-6420cc6dfb3f":{"resource":[]}}


# Sample output:
# http://alhena:7950/ticket-system-service/tickets/issueTicket?id=doms_aviser_edition:uuid:000a772b-e060-4add-8e0e-fb47bf90bbf1&type=Download&ipAddress=127.0.0.1&SBIPRoleMapper=inhouse

my $ticketurlprefix = "http://alhena:7950/ticket-system-service/tickets/issueTicket"; # FIXME, make configurable

while (<STDIN>) {
    if (/\{\"([^"]+[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})":\{"resource":\[\{"type":"([^"]+)","url":\["([^"]+).*/) {
        my $url = $3;
        print STDERR "0. $url\n";
        my $ticketurl = "$ticketurlprefix?id=$1&type=$2&ipAddress=$ARGV[0]&SBIPRoleMapper=inhouse";
        my $content = get($ticketurl);

        # Sample content:
        # {"doms_aviser_edition:uuid:000a772b-e060-4add-8e0e-fb47bf90bbf1":"55bb859c-8973-4438-a18c-7fcc90522bf0"}

        my $ticket;
        if (($ticket) = $content =~ m/\:"([^"]+)"}/) {
            print STDERR "1 - $ticket\n";
            $url =~ s/\Q%5BticketId%5D/$ticket/;
            print STDERR "2 - $url\n";
            $url =~ s/\Q[ticketId]/$ticket/;
            print STDERR "3 - $url\n";
            print "$url\n";
        } else {
            print STDERR "No ticket for $_ - content = $content\n";
        }
    }
}
