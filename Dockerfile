FROM httpd:2.4-alpine


# -- adapted from https://gitlab.com/jdoubleu/docker-apache-fcgid/blob/master/Dockerfile
# Install some dependencies needed for build

RUN apk add --no-cache --virtual .build-deps \
    ca-certificates \
    gcc \
    gnupg \
    libc-dev \
    make \
    pcre-dev \
    perl-dev \
    tar

# Required Perl modules.  Could not get "diagnostics" to work.
RUN echo yes | perl -MCPAN -e 'CPAN::Shell->install("FCGI","Cache::Memcached","Config::Simple","JSON", "CGI:Fast")'

COPY docker/mod_fcgid-*.tar.bz2 /tmp


RUN set -e \
  && cd /tmp \
  && mkdir -p /tmp/src \
  && tar xvjf mod_* -C src --strip-components=1 \
  && cd /tmp/src/ \
  \
  && ./configure.apxs \
  && make \
  && make install \
  \
  && cd .. \
  && rm -r src

RUN apk del .build-deps

# Copy in our modified copy enabling the ticket checker.

COPY docker/httpd.conf /usr/local/apache2/conf/httpd.conf

EXPOSE 80
CMD ["httpd-foreground"]





 

