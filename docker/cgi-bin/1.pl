#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

# http://perldoc.perl.org/CGI.html#PROGRAMMING-STYLE
use CGI qw/:standard/;
use JSON;
use Cache::Memcached;
use URI::URL;

# http://www.perlmonks.org/?node_id=320253
BEGIN { $SIG{'__DIE__'} = sub { print <<__WARN__ and exit 1 } }
Content-Type: text/html; charset=ISO-8859-1\n
Fatal Error in @{[(caller(2))[1]||__FILE__]} at ${\ scalar localtime }
while responding to request from ${\ $ENV{'REMOTE_ADDR'} || 'localhost
+' }
${\ join("\n",$!,$@,@_) }
__WARN__


print header('text/html'),
    start_html('Hello world');

my $query = CGI->new;  # parameter "id" is domsId.

# -- First get the content for the id.



# -- Then get a ticket for each type.

#"http://alhena:7950/ticket-system-service/tickets/issueTicket";
#"http://localhost:7950/mock/issueTicket?id=doms_aviser_page:uuid:11111111-1111-1111-1111-111111111111&type=Stream&ipAddress=172.20.0.1&SBIPRoleMapper=inhouse""


# --

my $memcached_servers = "memcached:11211";
my $memcached_server = new Cache::Memcached {
        # Workaround.  TRA could not figure out how to get an array out of
        # the configuration module.  So only one server supported for now.
        # 'servers' => @memcached_servers,
        'servers'                => [ $memcached_servers ],
            'debug'              => 0,
            'compress_threshold' => 10_000,
    };

my $json_parser = JSON->new->allow_nonref;

# -


print "<body>\n";
print "<h1>Hello, world!</h1>\n";
print "" . localtime(). "\n\n<br/>\n";
my $ticket_id = $query -> param("id");
my $ticket_content = $memcached_server->get($ticket_id);

if (!defined $ticket_content) {
    print "No ticket\n<hr/>";
} else {
    print "Ticket: $ticket_content\n<hr/>";
}

# no eval, crash if you want.
my $json_ticket = $json_parser->decode($ticket_content);

print "." . $json_ticket . "."; # FIXME:  Got to here.

print "xxy</body> </html>\n";