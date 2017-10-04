package dk.statsbiblioteket.mediestream.mockticketservice;

import com.sun.net.httpserver.HttpServer;
import org.glassfish.jersey.jdkhttp.JdkHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;

import javax.ws.rs.core.UriBuilder;
import java.net.URI;

/**
 * https://technology.amis.nl/2015/05/11/publish-rest-service-from-java-se-outside-java-ee-container/
 */
public class MockTicketServiceLauncher {

    public static void main(String... argv) {
        URI baseURI = UriBuilder.fromUri("http://localhost:7950/").build();
        ResourceConfig config = new ResourceConfig(TicketEventHandler.class);
        HttpServer server = JdkHttpServerFactory.createHttpServer(baseURI, config);
    }
}
