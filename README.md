newspaper-fastcgi-ticket-checker
================================

Newspaper access ticker checker - Perl script running via fastcgi

In order to validate access to most resources (full pages, thumbnails
etc) we must check that the given request corresponds to the
credentials stored in JSON format in memcached for the ticket included
with the request.

As the estimated initial workload were around 600 requests pr second
we decided that the best place to do this was inside the Apache server
itself, where the FcgidAccessChecker feature is a logical choice.
This requires a good FastCGI program which limits the technology
choices quite a bit.  We looked into a Java solution that turned out
to be premature, and then settled on using Perl.  TRA wrote the
initial version as simple as possible, and ABR, JRG and KFC later
adding writing the usage log.  TRA then updated the sources for Perl
5.16 used in production and did the initial Docker work.

Statistics of usage logs are processed by 
https://github.com/statsbiblioteket/newspaper-usage-statistics

From version 0.4 development is facilitated using Docker!

First build the kb/centos-httpd image

    cd kb-centos-httpd-docker && sh build.sh
    
Then use

    docker-compose up
    
to get a development system running.

See

    http://localhost:8080/x
    
for protected items.  (This is not done at the time of this writing. 
Also the statistics module needs to be merged with this project).


Remote testing:
---

(to be rewritten)'

Apache on achernar is configured to use this project cloned to the
home directory.  When check.pl or CheckTicket.pm is updated run

    sudo /usr/local/sbin/restart_httpd.sh

to reload the script, and then run 

    perf/test-page.sh
     
which expects one or more lines containing a DOMS uuid on stdin, does
the proper voodoo, and then downloads the corresponding assets to the
"perf/tmp" folder.  As of 2015-06-19 this is hardcoded to the test
environment including achernar.


Use
http://achernar:7880/fedora/risearch?type=triples&lang=spo&format=N-Triples&limit=&dt=on&stream=on&query=*+*+%3Cinfo%3Afedora%2Fdoms%3AContentModel_EditionPage%3E&template=
to ask DOMS for test uuids.


Deployment:
---

Run

    sh create-deployment-targz-sh
    
on a clean checkout to create tmp/newspaper-fastcgi-ticket-checker-$(head -n 1 CHANGELOG.md).tgz,
which can be sent to stage.

/tra 2017-09-19
