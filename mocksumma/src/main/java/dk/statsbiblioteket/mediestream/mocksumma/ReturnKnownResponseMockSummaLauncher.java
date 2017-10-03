package dk.statsbiblioteket.mediestream.mocksumma;

/**
 * A Launcher is responsible for invoking a Main class in the correct way when running inside
 * an IDE.  Typically this implies locating things, constructing and passing in configuration strings,
 * providing verbose logs etc.
 */
public class ReturnKnownResponseMockSummaLauncher {

    public static void main(String... argv) {
        ReturnKnownResponseMockSumma.main("http://localhost:9000/MockSearchWS?wsdl");
    }
}
