FROM centos/httpd

MAINTAINER tra@kb.dk

# Add internal repo
RUN rpm -ivh https://deimos.statsbiblioteket.dk/mrepo/centos7-x86_64/RPMS.sbtools/sb-repotools-0.4-12.el7.sb.noarch.rpm
RUN rpm -ivh https://deimos.statsbiblioteket.dk/mrepo/centos7-x86_64/RPMS.sbtools/yum-config-sb-centos-0.4-12.el7.sb.noarch.rpm
# Cannot disable others, as epel-release is needed.
# RUN sed -i '/^gpgkey/a\enabled=0' /etc/yum.repos.d/CentOS-Base.repo

# Now load the needed packages.

RUN yum -y install epel-release
RUN yum -y install autoconf automake krb5-workstation krb5-devel git httpd httpd-devel gcc fcgi-perl bzip2 perl-JSON perl-Config-Simple perl-Cache-Memcached perl-CGI mod_fcgid

# Add our prepared and protected folder to Apache.

COPY docker/newspaper-fcgi.conf /etc/httpd/conf.d

# Check all needed modules installed by yum
RUN perl -MCGI -MCache::Memcached -MConfig::Simple -MJSON -MCGI::Fast  -e1

EXPOSE 80
CMD ["/run-httpd.sh"]





 

