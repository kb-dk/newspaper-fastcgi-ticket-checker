package dk.statsbiblioteket.mediestream.mocksumma;

import javax.jws.WebParam;
import javax.xml.ws.Endpoint;

/**
 *
 */
@javax.jws.WebService
public class MockSummaForStatistics {
    /**
     * @noinspection unused
     */
    @javax.jws.WebMethod
    public String directJSON(@WebParam(name = "json") String json) {
        throw new UnsupportedOperationException("argh " + json);
    }

    public static void main(String[] argv) {
        Object implementor = new MockSummaForStatistics();
        String address = "http://localhost:9000/MockSearchWS?wsdl";
        Endpoint.publish(address, implementor);
    }
}
