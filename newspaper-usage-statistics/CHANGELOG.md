2016-09-13:

* Initial version.

2017-12-12: 

Version 1.0.1

* Replaced client IP-number with "-".
* Log files are sorted when processed.

Known bug: JSON request may time out.  Only seen after millions of requests.

2017-12-14:

Version 1.0.2

* Now transparently supports gzipped log-files 
  (filename must end with "gz").

2017-12-22:

Version 1.0.3

* Summa is queried with the parameter "chunksize" number of id's at a time. 
  Defaults to 100 as recommended by toes@kb.dk.

* Logfiles found by the entry in the configuration file are  
  analyzed to skip processing unneccesary log files.  The assumption 
  is that if the filename of a log file contains a YYYY-MM-DD
  time stamp, that logfile does not contain other log entries 
  than from that day and the day before (empirically found).   

