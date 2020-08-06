#!/usr/bin/perl

use Cache::Memcached;

my $goodIP="$ARGV[0]"

my $memcached_server = new Cache::Memcached {
        'servers'                => [ "memcached" ],
            'debug'              => 0,
            'compress_threshold' => 10_000,
    };


print "Agent IP: $goodIP"

$memcached_server->set("d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d", '"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d","type":"Stream","ipAddress":"172.18.98.246","resources":["uuid:371157ee-b120-4504-bfaf-364c15a4137c"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}');

print $memcached_server->get("d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d");

#printf 'set 3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d 0 60 234\r\n{"id":"3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d","type":"Stream","ipAddress":"172.18.98.246","resources":["uuid:371157ee-b120-4504-bfaf-364c15a4137c"],"userAttributes":{"everybody":["yes"],"SBIPRoleMapper":["inhouse"]},"properties":null}\r\n' | nc $MEMCACHED_IP 11211

#printf "get 3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d" | nc $MEMCACHED_IP 11211



