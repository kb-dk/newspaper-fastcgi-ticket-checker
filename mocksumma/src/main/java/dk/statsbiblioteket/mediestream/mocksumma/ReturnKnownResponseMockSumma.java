package dk.statsbiblioteket.mediestream.mocksumma;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * Mock summa for statistics
 */
@javax.jws.WebService
public class ReturnKnownResponseMockSumma {
    /**
     * Given the "json" input string, we look for a "X.request" resource, where X is a number from 0 upwards. If exactly
     * equal, we return the "X.response" resource.  If none is found, throw an IllegalArgumentException.
     *
     * @noinspection unused, UnnecessaryLocalVariable
     */
    @javax.jws.WebMethod
    public String directJSON(@javax.jws.WebParam(name = "json") String json) {
        Objects.requireNonNull(json, "json==null");

        long i = 0;
        InputStream is;

        // look for "0.request", "1.request"... until no more
        while ((is = getClass().getResourceAsStream("/" + i + ".request")) != null) {
            // http://www.adam-bien.com/roller/abien/entry/reading_inputstream_into_string_with
            String thisRequest = new BufferedReader(new InputStreamReader(is))
                    .lines()
                    .collect(Collectors.joining("\n"));

            // If found, then return the response.
            if (json.equals(thisRequest)) {
                InputStream responseStream = getClass().getResourceAsStream("/" + i + ".response");
                String response = new BufferedReader(new InputStreamReader(responseStream))
                        .lines()
                        .collect(Collectors.joining("\n"));
                return response;
            }
            i++;
        }
        throw new IllegalArgumentException("not found: " + json);
    }

    public static void main(String... argv) {
        if (argv.length < 1) {
            System.err.println("arguments:  address-to-publish-to");
            System.exit(1);
        }
        Object implementor = new ReturnKnownResponseMockSumma();
        javax.xml.ws.Endpoint.publish(argv[0], implementor);
    }
}
