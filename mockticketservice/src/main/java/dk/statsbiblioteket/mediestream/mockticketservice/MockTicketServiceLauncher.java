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
        // @Named string injection does not work yet!

        // https://newfivefour.com/java-jersey-dependency-injection.html
        // https://stackoverflow.com/a/28222565/53897
        // https://psamsotha.github.io/jersey/2015/11/01/jersey-method-parameter-injection.html
        // https://jersey.github.io/documentation/latest/ioc.html

        ResourceConfig config = new ResourceConfig(TicketEventHandler.class) {

        };
        HttpServer server = JdkHttpServerFactory.createHttpServer(baseURI, config);
    }
}
