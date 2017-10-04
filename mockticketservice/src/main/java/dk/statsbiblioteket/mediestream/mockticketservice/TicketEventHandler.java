package dk.statsbiblioteket.mediestream.mockticketservice;

import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;

import javax.inject.Inject;
import javax.inject.Named;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Objects;
import java.util.UUID;

/**
 * <p><code> Input: http://localhost:7950/ticket-system-service/tickets/issueTicket?id=doms_aviser_page:uuid:...&type=Stream&ipAddress=1.2.3.4&SBIPRoleMapper=inhouse
 * </code></p> <p><code> Return: {"doms_aviser_page:uuid:...":"196c4536-9fee-44ea-a52c-d918dc5aff14"} </code></p>
 */
@Path("/ticket-system-service/tickets/issueTicket")
public class TicketEventHandler {
    private final String memcachedLocation;

    @Inject
    public TicketEventHandler(@Named("memcached.location") String memcachedLocation) {

        this.memcachedLocation = memcachedLocation;
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response createTicketAndStoreInMemcached(//@Context Request request,
                                                    @QueryParam("id") String id,
                                                    @QueryParam("type") String type,
                                                    @QueryParam("ipAddress") String ipAddress,
                                                    @QueryParam("SBIPRoleMapper") String sbipRoleMapper) throws JSONException {
        Objects.requireNonNull(id, "id");
        Objects.requireNonNull(type, "type");
        Objects.requireNonNull(id, "ipAddress");
        Objects.requireNonNull(sbipRoleMapper, "sbipRoleMapper");

        System.out.println(new java.util.Date() + " : " + id + " " + memcachedLocation);

        // https://stackoverflow.com/q/41590303/53897
        JSONObject object = new JSONObject();
        object.put(id, UUID.randomUUID());
        Response response = Response.status(Response.Status.OK).entity(object.toString()).build();
        return response;
    }
}
