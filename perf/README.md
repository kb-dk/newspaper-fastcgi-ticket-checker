Usage:

* Generate list of files with embedded uuid's using find.  For instance:

  	   (cd /avis-show-devel/editions/symlinks; find . -type l) > files.txt

	   
* Resolve the content for each uuid:

  	  perl filename-to-content.pl doms_aviser_edition:uuid: <files.txt >content.txt

  
* Create time restricted urls with valid tickets:

  	 perl content-to-url.pl 172.18.100.153 <content.txt >urls.txt

  (replace 172.18.100.153 with the IP-number seen by Apache)

  
* Download all urls provided in script:
  
  
     (mkdir -p download; cd download; wget -q -i ../urls.txt) 

  Note:  wget is single threaded.  The file names include ?ticket=...




Tips:

	"/usr/bin/time -p command" prints out time taken to run command.

	"... | pv -l > outputfile" prints out lines per second in pipe if installed.


/tra 2014-12-02
