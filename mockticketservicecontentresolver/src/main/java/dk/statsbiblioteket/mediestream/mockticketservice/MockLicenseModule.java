package dk.statsbiblioteket.mediestream.mockticketservice;


import dk.statsbiblioteket.mediestream.mockticketservice.authorization.AuthorizationRequest;
import dk.statsbiblioteket.mediestream.mockticketservice.authorization.AuthorizationResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.Objects;

/**
 * https://github.com/statsbiblioteket/ticket-system/blob/master/ticket-system-libs/src/main/java/dk/statsbiblioteket/medieplatform/ticketsystem/Authorization.java#L48
 */
@Path("checkAccessForIds")
public class MockLicenseModule {

    Logger log = LoggerFactory.getLogger(getClass());

    /**
     * https://github.com/statsbiblioteket/licensemodule/blob/master/src/main/java/dk/statsbiblioteket/doms/licensemodule/service/LicenseModuleResource.java#L62
     */
    @POST
    @Consumes(MediaType.TEXT_XML)
    @Produces(MediaType.TEXT_XML)
    public AuthorizationResponse checkAccessForIds(AuthorizationRequest input) {
        Objects.requireNonNull(input, "auth request");
        Objects.requireNonNull(input.getResources(), "id");
        Objects.requireNonNull(input.getType(), "type");
        Objects.requireNonNull(input.getUserAttributes(), "user attributes");

        AuthorizationResponse response = new AuthorizationResponse();

        response.setType(input.getType());
        response.setQuery("Mock Solr query");

        //Grant access to all all the time forever and ever
        response.getResources().addAll(input.getResources());

        return response;
    }

}
