package dk.statsbiblioteket.mediestream.mockticketservice;


import dk.statsbiblioteket.mediestream.mockticketservice.authorization.CheckAccessForIdsInputDTO;
import dk.statsbiblioteket.mediestream.mockticketservice.authorization.CheckAccessForIdsOutputDTO;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * https://github.com/statsbiblioteket/ticket-system/blob/master/ticket-system-libs/src/main/java/dk/statsbiblioteket/medieplatform/ticketsystem/Authorization.java#L48
 */
@Path("/")
public class MockLicenseModule {

    /**
     * https://github.com/statsbiblioteket/licensemodule/blob/master/src/main/java/dk/statsbiblioteket/doms/licensemodule/service/LicenseModuleResource.java#L62
     */
    @POST
    @Consumes(MediaType.TEXT_XML)
    @Path("checkAccessForIds")
    @Produces(MediaType.TEXT_XML)
    public CheckAccessForIdsOutputDTO checkAccessForIds(CheckAccessForIdsInputDTO input) {
        Objects.requireNonNull(input, "auth request");
        Objects.requireNonNull(input.getIds(), "id");
        Objects.requireNonNull(input.getPresentationType(), "type");
        Objects.requireNonNull(input.getAttributes(), "user attributes");

        CheckAccessForIdsOutputDTO response = new CheckAccessForIdsOutputDTO();

        response.setPresentationType(input.getPresentationType());
        response.setQuery("Mock Solr query");


        // License module returns those DomsId's which the license allows access.  Here
        // we just select on the domsIds themselves.  In the real license module we compare
        // the user attributes to properties on the actual items in DOMS.
        List<String> accessableDomsIDs = input.getIds().stream().filter(id -> !id.endsWith("1")).collect(Collectors.toList());
        response.setAccessIds(new ArrayList<>(accessableDomsIDs));


        return response;
    }

}
