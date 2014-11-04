#!/usr/bin/perl
#java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 -jar t1.jar 

use CGI::Fast;
use Cache::Memcached;
use IO::Handle;
use JSON;

my $memd = new Cache::Memcached {
    'servers' => ["alhena:11211"],
    'compress_threshold' => 10_000,
};

$json = JSON->new->allow_nonref;
#resource_type should be read from some kind of config
$resource_type = "Stream";

while (my $q = CGI::Fast->new) {
   	my $ticket = $q->param("ticket");
        my $remote_ip = $q->remote_addr();
        my $request_url = $q->url();

        # Should come from config..
        my $resource_pattern = "uuid:";

        my $requested_resource = $request_url ~= $resource_pattern;

        if (!defined $remote_ip) {
            print("Status: 500\n\n");
            next;
        }
   
        if (!defined $request_url) {
            print("Status: 500\n\n");
            next;
        }

	if (defined $ticket) {

	    my $rawticket = $memd -> get($ticket);

	    if (defined $rawticket) {
                my $json_ticket = $json->decode($rawticket);

                #Check IP
                if ( ! $remote_ip eq $json_ticket->{ipAddress}) {
                    print("Status: 403\n\n");
                    next;
                }
                # Check requested UUID is in tickets list of resources
                # http://stackoverflow.com/questions/1719529/matching-a-string-against-a-list-of-words
		if ( ! (@$json_ticket->{resources} ~~ m/$requested_resource$/)) {
                    print("Status: 403\n\n");
                }
                #Check content type
                if( ! $resource_type eq $json_ticket->{type}) {
                    print("Status: 500\n\n");
                }      

		print("Status: 200\n\n");
	    } else {
		print("Status: 404\n\n");
	    }
	} else {
	    print("Status: 400\n\n");
	}
}

