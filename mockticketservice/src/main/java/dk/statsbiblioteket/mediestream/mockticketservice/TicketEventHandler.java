package dk.statsbiblioteket.mediestream.mockticketservice;

import net.spy.memcached.MemcachedClient;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.inject.Named;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.Objects;
import java.util.UUID;

/**
 * <p><code> Input: http://localhost:7950/ticket-system-service/tickets/issueTicket?id=doms_aviser_page:uuid:...&type=Stream&ipAddress=1.2.3.4&SBIPRoleMapper=inhouse
 * </code></p> <p><code> Return: {"doms_aviser_page:uuid:...":"196c4536-9fee-44ea-a52c-d918dc5aff14"} </code></p>
 */
@Path("issueTicket")
public class TicketEventHandler {


    /**
     * Location of memcached server.  The mock only uses a single memcached server so we just use a single value
     * directly.
     */
    protected final String memcachedLocation;

    protected MemcachedClient memcachedClient;

    @Inject
    public TicketEventHandler(@Named("memcached.location") String memcachedLocation) {
        this.memcachedLocation = memcachedLocation;
    }

    ;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response createTicketAndStoreInMemcached(//@Context Request request,
                                                    @QueryParam("id") String id,
                                                    @QueryParam("type") String type,
                                                    @QueryParam("ipAddress") String ipAddress,
                                                    @QueryParam("SBIPRoleMapper") String sbipRoleMapper) throws JSONException, IOException {
        try {
            Objects.requireNonNull(id, "id");
            Objects.requireNonNull(type, "type");
            Objects.requireNonNull(id, "ipAddress");
            Objects.requireNonNull(sbipRoleMapper, "sbipRoleMapper");
            Objects.requireNonNull(memcachedLocation, "memcachedLocation"); // ensure injection works.

            if (memcachedClient == null) {
                synchronized (this.getClass()) {
                    if (memcachedClient == null) {
                        String[] splitted = memcachedLocation.split(":");
                        if (splitted.length < 2) {
                            throw new IllegalArgumentException("memcachedLocation.split(':').length < 2");
                        }
                        memcachedClient = new MemcachedClient(new InetSocketAddress(splitted[0], Integer.valueOf(splitted[1])));
                    }
                }
            }
            Objects.requireNonNull(memcachedClient, "memcachedClient");

            System.out.println(new java.util.Date() + " : " + id + " " + memcachedLocation);

            // https://stackoverflow.com/q/41590303/53897
            final UUID ticketId = UUID.randomUUID();

            memcachedClient.add(ticketId.toString(), 60*60*24*30 - 1, "BAD TICKET");
            JSONObject object = new JSONObject();
            object.put(id, ticketId);
            Response response = Response.status(Response.Status.OK).entity(object.toString()).build();
            return response;
        } catch (Throwable e) {
            LoggerFactory.getLogger(TicketEventHandler.class).error("Throwable thrown :-/", e);
            throw e;
        }
    }
}
