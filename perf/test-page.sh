#!/usr/bin/env bash
# invoke with uuid embedded lines piped in.
date
mkdir -p tmp
# resolve 
perl filename-to-content.pl doms_aviser_page:uuid: | pv -l > tmp/content.txt

# get tickets
<tmp/content.txt perl content-to-url.pl $(hostname -I) | pv -l  >tmp/ticket-urls.txt

sed 's/\-auth\//\//' < tmp/ticket-urls.txt > tmp/no-ticket-urls.txt 

# get ticket urls
date
(cd tmp; /usr/bin/time -p wget -q -i ticket-urls.txt)
date


    
