# This is the centos-httpd image modified for KB usage.
#
# This is the first baby step, where focus is on the modules needed by the ticket-checker.

FROM centos/httpd

MAINTAINER tra@kb.dk

# --- Now load the needed packages. (not rigidly filtered).  Some Perl modules are only in epel.

RUN yum -y install epel-release
RUN yum -y install fcgi-perl bzip2 perl-JSON perl-Config-Simple perl-Cache-Memcached perl-CGI mod_fcgid

# -- Check all modules needed by the ticket-checker is present in the image.

RUN perl -MCGI -MCache::Memcached -MConfig::Simple -MJSON -MCGI::Fast  -e1

# -- good to go...

EXPOSE 80
CMD ["/run-httpd.sh"]





 

