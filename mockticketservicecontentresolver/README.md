Test with this curl command

    curl -H "Accept: text/xml" -H "Content-Type: text/xml" http://localhost:9612/licensemodule/services/checkAccessForIds -d '<checkAccessForIdsInputDTO><attributes><attribute>SBIPRoleMapper</attribute><values>inhouse</values>  </attributes><ids>doms_aviser_page:uuid:cca6e5a6-a635-49f0-8f26-0e05ac9dd8c2</ids><presentationType>Stream</presentationType></checkAccessForIdsInputDTO>'
    
Expected output is then
        
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?><checkAccessForIdsOutputDTO><accessIds>doms_aviser_page:uuid:cca6e5a6-a635-49f0-8f26-0e05ac9dd8c2</accessIds><presentationType>Stream</presentationType><query>Mock Solr query</query></checkAccessForIdsOutputDTO>



The module is a warfile, which should be renamed to licensemodule.war and run as any other war file 