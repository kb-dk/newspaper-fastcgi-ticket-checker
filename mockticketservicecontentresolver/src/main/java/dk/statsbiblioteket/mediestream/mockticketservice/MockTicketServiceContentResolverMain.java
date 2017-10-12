package dk.statsbiblioteket.mediestream.mockticketservice;

import com.sun.net.httpserver.HttpServer;
import dk.statsbiblioteket.configurationmap.ConfigurationKeyNotSetException;
import dk.statsbiblioteket.configurationmap.ConfigurationMap;
import dk.statsbiblioteket.configurationmap.MainExecutor;
import org.glassfish.hk2.utilities.binding.AbstractBinder;
import org.glassfish.jersey.jdkhttp.JdkHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;
import org.slf4j.LoggerFactory;

import javax.ws.rs.core.UriBuilder;
import java.net.URI;
import java.util.concurrent.Callable;
import java.util.function.Function;

/**
 * https://technology.amis.nl/2015/05/11/publish-rest-service-from-java-se-outside-java-ee-container/
 */
public class MockTicketServiceContentResolverMain {

    public static final String TICKETSERVICE_BASEURL = "ticketservice.baseurl";

    public interface Tool extends Callable<String> {

    }

    public static void main(String... args) {
        // Set up configuration strings

        Function<ConfigurationMap, Tool> function = (ConfigurationMap map) -> {

            URI baseURI = UriBuilder.fromUri(
                    map.get(TICKETSERVICE_BASEURL).orElseThrow(() -> new ConfigurationKeyNotSetException(TICKETSERVICE_BASEURL))
            ).build();

            // Create @Named-key-value pairs in Jersey injections from ConfigurationMap. Cannot use lambda for this.
            final AbstractBinder namedKeyValueBinder = new AbstractBinder() {
                @Override
                protected void configure() {
                    // https://stackoverflow.com/a/28222565/53897
                    for (String key : map.keySet()) {
                        map.get(key).ifPresent(value -> {
                            LoggerFactory.getLogger(MockTicketServiceContentResolverMain.class).debug("Bind '" + key + "' to '" + value + "'");
                            bind(value).to(String.class).named(key);
                        });
                    }
                }
            };

            ResourceConfig config = new ResourceConfig();
            config.register(TicketServiceEventHandler.class);
            config.register(ContentResolverEventHandler.class);
            config.register(namedKeyValueBinder);
            Tool tool =  () -> {
                HttpServer httpServer = JdkHttpServerFactory.createHttpServer(baseURI, config); // launches non-daemon server thread and returns.
                return "httpServer returned";
            };
            return tool;
        };

        MainExecutor.execute(args, function);
    }
}
