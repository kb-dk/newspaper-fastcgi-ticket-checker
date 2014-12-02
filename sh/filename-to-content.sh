#!/bin/sh

# pipe filename list into script, returns content resolver output

# sample input:
# ./c/c/5/5/cc55bd3d-19ee-4295-847c-bba90d5081fd.pdf

# sample output:
# {"doms_aviser_edition:uuid:cc55bd3d-19ee-4295-847c-bba90d5081fd":{"resource":[{"type":"Download","url":["http://achernar.statsbiblioteket.dk/newspaper-pdf-auth/c/c/5/5/cc55bd3d-19ee-4295-847c-bba90d5081fd.pdf?ticket=[ticketId]"]}]}}


#UUID_PREFIX='doms_aviser_page:uuid:'
UUID_PREFIX='doms_aviser_edition:uuid:' # FIXME:  Make configurable

URL="http://iapetus:9311/content-resolver/content?id=${UUID_PREFIX}{}"

xargs -i -n 1 basename '{}' .pdf | xargs -i -n 1 curl -s -w"\\n" "${URL}"
