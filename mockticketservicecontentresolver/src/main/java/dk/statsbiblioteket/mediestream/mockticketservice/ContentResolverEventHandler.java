package dk.statsbiblioteket.mediestream.mockticketservice;

import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Objects;

/**
 * <p><code> Input: http://localhost:7950/mock/content?id=$key"); # FIXME: Better conf. </code></p> <p><code> Return:
 * {"doms_aviser_page:uuid:...":"196c4536-9fee-44ea-a52c-d918dc5aff14"} </code></p>
 */
@Path("content")
public class ContentResolverEventHandler {

    Logger log = LoggerFactory.getLogger(getClass());

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response resolveContentForDomsId(@QueryParam("id") String domsId) throws JSONException, IOException {
        try {
            Objects.requireNonNull(domsId, "id");

            JSONObject content = new MockTicketContentGenerator().ticketContentFrom(domsId);

            log.debug("domsId: {}", domsId);

            Response response = Response.status(Response.Status.OK).entity(content.toString()).build();
            log.trace("Response: {}", response);
            return response;
        } catch (Throwable e) {
            LoggerFactory.getLogger(ContentResolverEventHandler.class).error("Throwable thrown :-/", e);
            final StringWriter sw = new StringWriter();
            final PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            Response response = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(sw.toString()).build();
            log.trace("Throwable response: {}", response);
            return response;
        }
    }
}
