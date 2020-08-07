#!/usr/bin/perl

use Cache::Memcached;

my $goodIP="$ARGV[0]";
my $badIP="4.4.4.4";

my $memcached_server = new Cache::Memcached {
        'servers'                => [ "memcached:11211" ],
            'debug'              => 0,
            'compress_threshold' => 10_000,
    };


print "Agent IP: $goodIP\n";

# Ticket good for the jenkins agent node
my $goodTicket = '"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d","type":"Stream","ipAddress":"' . $goodIP . '","resources":["uuid:371157ee-b120-4504-bfaf-364c15a4137c"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}';
# Ticket that should not allow the jenkins agent node access
my $badTicket = '"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fcbad","type":"Stream","ipAddress":"' . $badIP . '","resources":["uuid:371157ee-b120-4504-bfaf-364c15a41bad"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}';


$memcached_server->set("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d", $goodTicket);
$memcached_server->set("3d2bda8b-8b7c-47e9-85ce-f42d2e4fcbad", $badTicket);
#$memcached_server->set("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d", '"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d","type":"Stream","ipAddress":"172.18.98.246","resources":["uuid:371157ee-b120-4504-bfaf-364c15a4137c"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}');

print "good ticket: " . $memcached_server->get("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d") . "\n";
print "bad ticket: " . $memcached_server->get("3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d") . "\n";



