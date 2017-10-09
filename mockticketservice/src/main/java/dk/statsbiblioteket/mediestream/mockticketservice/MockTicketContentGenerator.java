package dk.statsbiblioteket.mediestream.mockticketservice;

import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;

import java.util.Arrays;

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
    public JSONObject ticketContentFrom(String ticketId, String type1, String url1, String type2, String url2) {
        try {

            final JSONObject jsonObject = new NonSlashEscapingJSONObject();
            jsonObject.put(ticketId,
                    new NonSlashEscapingJSONObject().put(
                            "resource", Arrays.asList(
                                    new NonSlashEscapingJSONObject().put("type", type1).put("url", url1),
                                    new NonSlashEscapingJSONObject().put("type", type2).put("url", url2))));
            return jsonObject;
        } catch (JSONException e) {
            throw new RuntimeException("put", e);
        }

    }
}
