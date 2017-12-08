#docker run -p 8081:8081 --name nexus sonatype/nexus3

# https://help.sonatype.com/display/NXRM3/REST+and+Integration+API

# Uploads scripts to nexus and runs them

curl -v -X POST -u admin:admin123 --header "Content-Type: application/json" 'http://172.17.0.1:8081/service/siesta/rest/v1/script' -d @sbforge.json

curl -v -X POST -u admin:admin123 --header "Content-Type: text/plain" 'http://172.17.0.1:8081/service/siesta/rest/v1/script/sbforge/run'

curl -v -X POST -u admin:admin123 --header "Content-Type: application/json" 'http://172.17.0.1:8081/service/siesta/rest/v1/script' -d @sbforge_central.json

curl -v -X POST -u admin:admin123 --header "Content-Type: text/plain" 'http://172.17.0.1:8081/service/siesta/rest/v1/script/sbforge_central/run'
