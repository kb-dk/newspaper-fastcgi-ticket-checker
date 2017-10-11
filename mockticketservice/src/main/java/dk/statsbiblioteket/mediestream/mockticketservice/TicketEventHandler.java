package dk.statsbiblioteket.mediestream.mockticketservice;

import net.spy.memcached.MemcachedClient;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.slf4j.Logger;
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
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.InetSocketAddress;
import java.util.Objects;
import java.util.UUID;

/**
 * <p><code> Input: http://localhost:7950/ticket-system-service/tickets/issueTicket?id=doms_aviser_page:uuid:...&type=Stream&ipAddress=1.2.3.4&SBIPRoleMapper=inhouse
 * </code></p> <p><code> Return: {"doms_aviser_page:uuid:...":"196c4536-9fee-44ea-a52c-d918dc5aff14"} </code></p>
 */
@Path("issueTicket")
public class TicketEventHandler {

    Logger log = LoggerFactory.getLogger(getClass());

    /**
     * Location of memcached server.  The mock only uses a single memcached server so we just use a single value
     * directly.
     */
    protected final String memcachedLocation;

    protected MemcachedClient memcachedClient;

    @Inject
    public TicketEventHandler(@Named("memcached.location") String memcachedLocation) throws IOException {
        this.memcachedLocation = memcachedLocation;
        String[] splitted = memcachedLocation.split(":");
        if (splitted.length < 2) {
            throw new IllegalArgumentException("memcachedLocation.split(':').length < 2");
        }
        memcachedClient = new MemcachedClient(new InetSocketAddress(splitted[0], Integer.valueOf(splitted[1])));
    }

    ;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response createTicketAndStoreInMemcached(//@Context Request request,
                                                    @QueryParam("id") String domsId,
                                                    @QueryParam("type") String type,
                                                    @QueryParam("ipAddress") String ipAddress,
                                                    @QueryParam("SBIPRoleMapper") String sbipRoleMapper) throws JSONException, IOException {
        try {
            Objects.requireNonNull(domsId, "id");
            Objects.requireNonNull(type, "type");
            Objects.requireNonNull(ipAddress, "ipAddress");
            Objects.requireNonNull(sbipRoleMapper, "sbipRoleMapper");
            Objects.requireNonNull(memcachedLocation, "memcachedLocation"); // ensure injection works.
            Objects.requireNonNull(memcachedClient, "memcachedClient");

            // We always grant the ticket!

            final UUID ticketId = UUID.randomUUID();
            final String ticketContent = new MockTicketContentGenerator().ticketContentFrom(domsId).toString();

            // Store the new ticket in memcached using the specific ticketId (allowing memcached to let the ticket time out)
            memcachedClient.add(ticketId.toString(), 60 * 60 * 24 * 30 - 1, ticketContent);

            log.debug("domsId: {}, ticketId: {}, memcachedLocation: {}", domsId, ticketId, memcachedLocation);

            // Generate a "{domsId: ticketId}" response -- https://stackoverflow.com/q/41590303/53897
            JSONObject object = new JSONObject();
            object.put(domsId, ticketId);
            Response response = Response.status(Response.Status.OK).entity(object.toString()).build();
            log.trace("Response: {}", response);
            return response;
        } catch (Throwable e) {
            LoggerFactory.getLogger(TicketEventHandler.class).error("Throwable thrown :-/", e);
            final StringWriter sw = new StringWriter();
            final PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            Response response = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(sw.toString()).build();
            return response;

        }
    }

}
