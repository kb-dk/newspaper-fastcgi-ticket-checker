package dk.statsbiblioteket.mediestream.mockticketservice;

import com.sun.net.httpserver.HttpServer;
import dk.statsbiblioteket.digital_pligtaflevering_aviser.harness.AutonomousPreservationToolHelper;
import dk.statsbiblioteket.digital_pligtaflevering_aviser.harness.ConfigurationMap;
import dk.statsbiblioteket.digital_pligtaflevering_aviser.harness.Tool;
import org.glassfish.hk2.utilities.binding.AbstractBinder;
import org.glassfish.jersey.jdkhttp.JdkHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;
import org.slf4j.LoggerFactory;

import javax.ws.rs.core.UriBuilder;
import java.net.URI;
import java.util.Properties;
import java.util.function.Function;

/**
 * https://technology.amis.nl/2015/05/11/publish-rest-service-from-java-se-outside-java-ee-container/
 */
public class MockTicketServiceMain {

    public static final String TICKETSERVICE_BASEURL = "ticketservice.baseurl";

    public static void main(String... args) {
        // Set up configuration strings

        Function<ConfigurationMap, Tool> function = (ConfigurationMap map) -> {

            URI baseURI = UriBuilder.fromUri(map.getRequired(TICKETSERVICE_BASEURL)).build();

            // Create @Named-key-value pairs in Jersey injections from ConfigurationMap.
            final AbstractBinder component = new AbstractBinder() {
                @Override
                protected void configure() {
                    // https://stackoverflow.com/a/28222565/53897
                    final Properties p = map.asProperties();
                    for (String key : p.stringPropertyNames()) {
                        LoggerFactory.getLogger(MockTicketServiceMain.class).debug("Bind '" + key + "' to '" + p.getProperty(key) + "'");
                        bind(p.getProperty(key)).to(String.class).named(key);
                    }
                }
            };

            ResourceConfig config = new ResourceConfig();
            config.register(TicketEventHandler.class);
            config.register(component);
            return () -> {
                HttpServer httpServer = JdkHttpServerFactory.createHttpServer(baseURI, config); // does not return
                return "httpServer returned";
            };
        };
        AutonomousPreservationToolHelper.execute(args, function);
    }
}
