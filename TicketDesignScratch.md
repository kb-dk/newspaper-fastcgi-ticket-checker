
## Docker for Ticket Service

Tomcat

War file from Ticket System


    
    <context-param>
        <param-name>
            dk.statsbiblioteket.medieplatform.ticketsystem.auth-checker
        </param-name>
        <param-value>
            http://devel06:9612/licensemodule/services/
        </param-value>
    </context-param>

    <context-param>
        <param-name>
            dk.statsbiblioteket.medieplatform.ticketsystem.memcacheServer
        </param-name>
        <param-value>
            localhost
        </param-value>
    </context-param>

    <context-param>
        <param-name>
            dk.statsbiblioteket.medieplatform.ticketsystem.memcachePort
        </param-name>
        <param-value>
            11211
        </param-value>
    </context-param>


License module

    AuthorizationRequest authorizationRequest = new AuthorizationRequest(resources, type, transform(userAttributes));


    WebResource webResource = client.resource(service);
    AuthorizationResponse authorizationResponse = webResource.path("/checkAccessForIds")
            .type(MediaType.TEXT_XML)
            .post(AuthorizationResponse.class, authorizationRequest);

    return authorizationResponse.getResources();
    
Returns xml like this
    
    <checkAccessForIdsInputDTO>
      <!--1 or more repetitions:-->
      <attributes>
        <attribute>SBIPRoleMapper</attribute>
        <!--Zero or more repetitions:-->
        <values>inhouse</values>
      </attributes>
      <!--1 or more repetitions:-->
      <ids>doms_aviser_page:uuid:cca6e5a6-a635-49f0-8f26-0e05ac9dd8c2</ids>
      <presentationType>Stream</presentationType>
    </checkAccessForIdsInputDTO>
    
