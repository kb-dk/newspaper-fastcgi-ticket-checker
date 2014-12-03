#!/usr/bin/env perl5 -l

# pipe filename list into script, returns cached content resolver output

# sample input:
# ./c/c/5/5/cc55bd3d-19ee-4295-847c-bba90d5081fd.pdf

# sample output:
# {"doms_aviser_edition:uuid:cc55bd3d-19ee-4295-847c-bba90d5081fd":{"resource":[{"type":"Download","url":["http://achernar.statsbiblioteket.dk/newspaper-pdf-auth/c/c/5/5/cc55bd3d-19ee-4295-847c-bba90d5081fd.pdf?ticket=[ticketId]"]}]}}


# http://perldoc.perl.org/DB_File.html#A-Simple-Example
    
use warnings;
use strict;
use DB_File;
use LWP::Simple;

our (%h, $k, $v);

tie %h, "DB_File", "content-cache.db", O_RDWR|O_CREAT, 0666, $DB_HASH 
    or die "Cannot open cache: $!\n";

my $UUID_PREFIX='doms_aviser_edition:uuid:';

while (<STDIN>) {
    my ($uuid) = /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/;
    my $key = $UUID_PREFIX . $uuid;
    
    if (!defined $h{$key}) {
	my $content = get("http://iapetus:9311/content-resolver/content?id=$key");

	$h{$key} = $content;
    }
    print $h{$key};
}
