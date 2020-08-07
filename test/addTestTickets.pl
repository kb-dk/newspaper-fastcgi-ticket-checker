#!/usr/bin/perl

use Cache::Memcached;
use Socket;

my $goodIP="$ARGV[0]";
my $badIP="4.4.4.4";

my $memcached_server = new Cache::Memcached {
        'servers'                => [ "memcached:11211" ],
            'debug'              => 0,
            'compress_threshold' => 10_000,
    };

# Use the memcached server for running tests (Jenkins will have to go through the exposed route, and that currently provides the load balancers ip, i.e. it won't work)
    #my $host_ip = gethostbyname("memcached");
    #my $goodIP = inet_ntoa($host_ip);

print "Host ip: $goodIP\n";

# Ticket good for the test host
my $goodTicket = '{"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d","type":"Thumbnails","ipAddress":"' . $goodIP . '","resources":["uuid:371157ee-b120-4504-bfaf-364c15a4137c"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}';
# Ticket that should not allow the test host access
my $badTicket = '{"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fcbad","type":"Thumbnails","ipAddress":"' . $badIP . '","resources":["uuid:371157ee-b120-4504-bfaf-364c15a41bad"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}';


$memcached_server->set("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d", $goodTicket);
$memcached_server->set("3d2bda8b-8b7c-47e9-85ce-f42d2e4fcbad", $badTicket);

print "good ticket: " . $memcached_server->get("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d") . "\n";
print "bad ticket: " . $memcached_server->get("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d") . "\n";



