package dk.statsbiblioteket.configurationmap;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

/**
 * Conversion utilities to pull in from sources.  Consider rewriting as lambda expression which can be inlined.
 */
public class ConfigurationMapHelper {
    /**
     * Creates and returns a plain map based on the system properties with the provided keys that actually exist (value
     * != null). Non-existing values silently ignored.
     *
     * @param propertyKeys property key names
     */

    public static Map<String, String> systemPropertiesAsMap(String... propertyKeys) {
        Map<String, String> map = new HashMap<>();
        for (String key : propertyKeys) {
            String value = System.getProperty(key);
            if (value != null) {
                map.put(key, value);
            }
        }
        return map;
    }

    /**
     * Creates and retuns a plain map based on the environment variables with the provided keys that actually exist
     * (value != null).
     *
     * @param variableKeys environment variable names
     */
    public static Map<String, String> environmentVariablesAsMap(String... variableKeys) {
        Map<String, String> map = new HashMap<>();
        for (String key : variableKeys) {
            String value = System.getenv(key);
            if (value != null) {
                map.put(key, value);
            }
        }
        return map;
    }

    /**
     * Reads in a property file from the provided reader, and returns an <code>Optional.of(map)</code>.  Keys and values
     * are trimmed. If an IOException is thrown, <code>Optional.empty()</code> is returned.
     */

    public static Optional<Map<String, String>> propertiesAsMap(Reader reader) {
        Properties p = new Properties();

        try (BufferedReader bufferedReader = new BufferedReader(reader)) {
            p.load(bufferedReader);
        } catch (IOException e) {
            return Optional.empty();
        }

        Map<String, String> map = new HashMap<>();
        for (Map.Entry<Object, Object> entry : p.entrySet()) {
            String key = String.valueOf(entry.getKey()).trim();
            String value = String.valueOf(entry.getValue()).trim();
            map.put(key, value);
        }
        return Optional.of(map);
    }

    /**
     * Get the configuration value for <code>key</code> from <code>map</code>.  If not present, throw a {@link
     * ConfigurationKeyNotSetException} with <code>key</code> as the message.
     *
     * @param map configuration map to use
     * @param key key to look up
     * @return value for key in configuration map
     */
    public String getRequired(ConfigurationMap map, String key) {
        return map.get(key).orElseThrow(() -> new ConfigurationKeyNotSetException(key));
    }
}
