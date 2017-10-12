package dk.statsbiblioteket.mediestream.mockticketservice;

/**
 * https://technology.amis.nl/2015/05/11/publish-rest-service-from-java-se-outside-java-ee-container/
 */
public class MockTicketServiceLocalhostLauncher {

    public static void main(String... args) {
        MockTicketServiceContentResolverMain.main("mockticketservice-ide.properties");
    }
}
