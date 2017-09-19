0.4
===

Building necessary docker infrastructure to do local integration tests.

/tra 2017-09-19

0.3.1
===

"ignored_resource_pattern" is now a required configuration parameter
(which defines what to log to the usage log).

Added create-deployment-targz.sh which transparently adds the versioned
extraction directory. 

/tra 2017-09-11

0.3 (2017-08-31)
===

Incorrect usage of "or" triggered by Perl 5.16 in stage changed to
intended meaning (and minor refactoring).


2016-09-08:
====

* New configuration file entry "statistics_file" needs to point to
  location of statistics file, where JSON entries are written to for
  each request for later analysis.  flock and +>> is used to have
  multiple fcgid instances write to the same file without dataloss.

* New optional configuration file entry "ignored_resource_pattern"
  defines a regexp of ignored resources when logging statistics.

* Remove temporary time logging

2014-12-15:
====

 * ini-files are now expected to be next to a symbolic link
   pointing to check.pl.  If the symbolic link is named "/foo/a.pl",
   the ini-file is "/foo/a.ini".

 * The cause for a given rejection is printed to STDERR which goes
   in the Apache error_log.

 * (TEMPORARY) The time taken to do the memcached lookup is
   unconditionally logged to STDERR.

 * (TEMPORARY) The total time taken in our code is unconditionally
   logged to STDERR.

Known issues:
----

 * Currently supports exactly _one_ memcached server.

 * Performance scripts are single threaded.
