newspaper-fastcgi-ticket-checker
================================

Newspaper access ticker checker - Perl script running via fastcgi

In order to validate access to most resources (full pages, thumbnails
etc) we must check that the given request corresponds to the
credentials stored in JSON format in memcached for the ticket included
with the request.

What needs to be done in the ticket-checker to accept or decline a given URL:

1. Extract the ticket id from the URL.    The exact rule depends on the mediatype.
2. Look up the ticket id in memcached, to get a JSON snippet containing the ip-address, resource name, and
   resource type for which the ticket is valid.  All of these must be the same as in the URL for access to be
   allowed.
3. If not or if anything fails what so ever, access is denied.

Then (unless it is a DZI request which just pollutes the log) a log line is written containing information
needed for the usage statistics module (see /stats).




As the estimated initial workload were around 600 requests pr second
we decided that the best place to do this was inside the Apache server
itself, where the FcgidAccessChecker feature is a logical choice.
This requires a good FastCGI program which limits the technology
choices quite a bit.  We looked into a Java solution that turned out
to be premature, and then settled on using Perl.  TRA wrote the
initial version as simple as possible, and ABR, JRG and KFC later
adding writing the usage log.  TRA then updated the sources for Perl
5.16 used in production and did the initial Docker work.

Statistics of usage logs are processed by `newspaper-usage-statistics` in this repository 

Testing of the code requires quite a bit of infrastructure (tickets, content, etc.) which is why it have been delegated to Jenkins and and containers running in an OpenShift cluster.
Instructions for running the test can thus be found in the file `Jenkinsfile` in this repository. 

Basic integration tests can be found in the `test` dir (which is also those used by Jenkins).


Test setup deployment:
---

Apache on achernar is configured to use this project cloned to the
home directory.  When check.pl or CheckTicket.pm is updated run

    sudo /usr/local/sbin/restart_httpd.sh

Deployment:
---

Run

    sh create-deployment-targz-sh
    
on a clean checkout to create tmp/newspaper-fastcgi-ticket-checker-$(head -n 1 CHANGELOG.md).tgz,
which can be sent to stage.

