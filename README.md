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

Statistics of usage logs are processed by newspaper-usage-statistics.


To get needed Perl dependencies, ensure the `cpan` command is
correctly set up, and then use

     cpan -i FCGI Cache::Memcached Config::Simple JSON

(sudo may be needed on some platforms to install for all users).

Note:  For now, only a single memcached server is supported.


Local development using Docker
---

Development is now done using docker (on a suitably configured
developer machine) and testing is done on achernar.

Use

        docker????

to bring up a small environment with an Apache HTTPD talking to a
memcached which is populated with simple test data.

TODO:  Add information on how to access test resources.


Restart the docker environment using TODO after each source change, as
httpd does not pick this up automatically.



Remote development:
---


Apache on achernar is configured to use this as cloned in the
homedirectory.  When check.pl or CheckTicket.pm is updated run

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


Under Ubuntu 14.10 adapt `/etc/apache2/apache2.conf` similarly to

    <Directory /var/www/>
            Options Indexes FollowSymLinks
            AllowOverride None
            FcgidAccessChecker /home/ravn/git/newspaper-fastcgi-ticket-checker/fcgid-access-checker/check.pl
	    Require all granted
    </Directory>

and ensure that the appropriate module is installed and activated.


/tra 2017-08-31
