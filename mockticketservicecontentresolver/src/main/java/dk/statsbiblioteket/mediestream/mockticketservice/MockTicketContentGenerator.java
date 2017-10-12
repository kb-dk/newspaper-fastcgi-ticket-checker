package dk.statsbiblioteket.mediestream.mockticketservice;

import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;

import javax.validation.constraints.NotNull;
import java.util.Arrays;
import java.util.List;

/**
 *
 */

/**
 * The default behavior of jettison is to escape slashes (apparently to protect against some script exploit) but the
 * JSON stored in memcached does not have escaped slashes.  To get identical output we use the setter introduced for
 * https://github.com/codehaus/jettison/issues/2 but which is not compatible with the fluent interface otherwise used in
 * jettison.  Easiest way is just to subclass JSONObject with the boolean turned off.
 */
class NonSlashEscapingJSONObject extends JSONObject {
    public NonSlashEscapingJSONObject() {
        setEscapeForwardSlashAlways(false);
    }
}

public class MockTicketContentGenerator {

    public List<List<String>> knownTicketContents = Arrays.asList(
            Arrays.asList("doms_aviser_page:uuid:11111111-1111-1111-1111-111111111111", "Stream","http://localhost", "Thumbnails", "http://localhost"),
            Arrays.asList("doms_aviser_page:uuid:bcfd6c77-6b5e-471b-a6f2-2ddaaacea791", "Stream","http://localhost", "Thumbnails", "http://localhost"),
            Arrays.asList("doms_aviser_page:uuid:3c83fe89-2462-4471-b76d-50cd67928465", "Stream","http://localhost", "Thumbnails", "http://localhost"),
            Arrays.asList("doms_aviser_page:uuid:de3745c9-a731-49ab-ad71-440fdabe7faa", "Stream","http://localhost", "Thumbnails", "http://localhost")
    );

    public JSONObject ticketContentFrom(String domsId, String type1, String url1, String type2, String url2) {
        try {
            final JSONObject jsonObject = new NonSlashEscapingJSONObject();
            jsonObject.put(domsId,
                    new NonSlashEscapingJSONObject().put(
                            "resource", Arrays.asList(
                                    new NonSlashEscapingJSONObject().put("type", type1).put("url", url1),
                                    new NonSlashEscapingJSONObject().put("type", type2).put("url", url2))));
            return jsonObject;
        } catch (JSONException e) {
            throw new RuntimeException("put", e);
        }

    }

    public JSONObject ticketContentFrom(@NotNull String domsId) {
        List<String> line = knownTicketContents.stream()
                .filter(l -> l.get(0).equals(domsId))
                .findAny()
                .orElseThrow(() -> new IllegalArgumentException("domsID not known: " + domsId));
        return ticketContentFrom(line.get(0), line.get(1), line.get(2), line.get(3), line.get(4));

    }
}
