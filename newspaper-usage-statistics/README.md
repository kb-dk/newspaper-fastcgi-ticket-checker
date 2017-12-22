Usage statistics for the newspaper project.
===

The Apache access checker in newspaper-fastcgi-ticket-checker logs
user data and DOMS information for each asset access check.

This module contains a small Python CGI program which reads the
generated logs, looks up information and generate a CSV with usage
information which can be post-processed in Excel.  It can
also be run directly from the command line.

The script is intented to be clear and easy to debug for a 
Java programmer unfamiliar with Python.  This mean that many
results are captured in local variables, and that naming
may be more Java than Python like.

For development purposes on local machine, copy
newspaper_statistics.py.cfg-example to
src/main/newspaper_statistics.py.cfg (the ../.. path is to get outside
the code tree when deployed).  The sample file is set up to parse the
sample-logs/thumbnails.log file.  When running standalone provide one
or more arguments on the form "fromDate=2015-06-24" to trigger
terminal mode and emulate html page parameters.

For archenar use, clone project and symlink
src/main/scripts/statistics to a CGI enabled location where "../.."
ends up outside the publicly visible pages and put a
newspaper_statistics.py.cfg file there.  The /var/log/httpd log files
are helpful in getting the configuration right.

For IntelliJ see http://stackoverflow.com/a/24769264/53897

For Ubuntu 15.04 "sudo apt-get install python-simplejson python-suds"
is needed.

For Centos "sudo yum install python-lxml python-simplejson
python-suds"

---

To make a release:

* Update changelog
* Tag the version in git, using `git tag newspaper-usage-statistics-<version>`
* Run `sh make-tarball.sh newspaper-usage-statistics-<version>` to tar up and gzip the following
    - src/main/scripts/statistics
    - src/main/newspaper_statistics.py.cfg-example
    - README.md
    - CHANGELOG.md
    
  into `newspaper-usage-statistics-<version>.tgz`.

  You may be able to simply use `sh make-tarball.sh $(git tag -l --sort=-committerdate |head -1)` 
    
* Place the file in newspaper@achernar:releases/

kfc 2016-09-13, /tra 2017-12-12

---

For Ubuntu 16.04 "sudo apt-get install python-simplejson python-suds python-lxml"
is needed.

/tra 2017-12-09

