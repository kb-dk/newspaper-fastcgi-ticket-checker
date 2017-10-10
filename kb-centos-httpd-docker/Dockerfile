# This is the centos-httpd image modified for KB usage.
#
# This is the first baby step, where focus is on the modules needed by the ticket-checker.

FROM centos/httpd

MAINTAINER tra@kb.dk

# --- Now load the needed packages. (not rigidly filtered).  Some Perl modules are only in epel.

RUN yum -y install epel-release

# Make life easier when inside
RUN yum -y install less traceroute
# Things needed by FastCGI Perl script
RUN yum -y install fcgi-perl bzip2 perl-JSON perl-Config-Simple perl-Cache-Memcached perl-CGI mod_fcgid
# Things needed by Statistics CGI Python script
RUN yum -y install python-lxml python-suds

# Delete welcome page module
RUN rm /etc/httpd/conf.d/welcome.conf

# Ensure target directory exists.
RUN mkdir -p /var/www/html/statistics/

# -- Check all modules needed by the ticket-checker is present in the image.

RUN perl -MCGI -MCache::Memcached -MConfig::Simple -MJSON -MCGI::Fast  -e1

# -- good to go...

EXPOSE 80
CMD ["/run-httpd.sh"]





 

