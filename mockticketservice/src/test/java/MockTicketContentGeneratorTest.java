import dk.statsbiblioteket.mediestream.mockticketservice.MockTicketContentGenerator;
import org.codehaus.jettison.json.JSONObject;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 *
 */
public class MockTicketContentGeneratorTest {

    @Test
    public void test1() {
        JSONObject s = new MockTicketContentGenerator()
                .ticketContentFrom("id", "Stream", "http://foobar", "Thumbnail", "http://fum");
        assertEquals("{\"id\":{\"resource\":[{\"type\":\"Stream\",\"url\":\"http://foobar\"}," +
                        "{\"type\":\"Thumbnail\",\"url\":\"http://fum\"}]}}",
                s.toString());

    }

}
