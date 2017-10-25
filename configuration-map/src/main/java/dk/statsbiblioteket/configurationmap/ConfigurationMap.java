package dk.statsbiblioteket.configurationmap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.Iterator;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;

/**
 * <p>Copied from DPA, dedaggerized and adapted to use Optional (inspired by https://dzone.com/articles/requirements-for-a-configuration-library)
 * </p> <p> ConfigurationMap holds a map of string to string (i.e. the general form of java properties) <strike>and can
 * be used directly as a Dagger 2 module</strike>.  The toString() method list the keys in alphabetical order. The
 * toString() explicitly protects passwords from being printed.  FIXME:  Full technical explanation pending.</p>
 */

public class ConfigurationMap {

    final Logger log = LoggerFactory.getLogger(ConfigurationMap.class);

    protected Map<String, String> map = new TreeMap<>();

    /**
     * The argument ensures that a dependency injection framework (notably Dagger) cannot create this automatically.
     *
     * @param initialMap initial map to populate with.  Use <code>Collections.emptymap()</code> if no initial entries
     *                   are needed.
     */

    public ConfigurationMap(Map<String, String> initialMap) {
        map.putAll(Objects.requireNonNull(initialMap, "initialMap == null"));
    }

    /**
     * get(key) returns an Optional to make it easier for the caller to decide what to do if not present.  This replaces
     * getRequired and getDefault.
     *
     * @param key key to get value for
     * @return value if present, throws exception if not.
     */
    public Optional<String> get(String key) {
        return Optional.ofNullable(map.get(key));
    }

    /**
     * Adds all entries in mapToAdd to the current configuration map.
     */

    public void add(Map<String, String> mapToAdd) {
        map.putAll(mapToAdd);
    }

    /**
     * Return an unmodifiable set of keys in the configuration map.  It is intentional not to expose the whole map - this
     * mean <code>get</code> <em>must</em> be called to get the value.
     *
     * @return <code>Collections.unmodifiableSet(map.keySet())</code>
     */
    public Set<String> keySet() {
        return Collections.unmodifiableSet(map.keySet());

    }

    /**
     * toString() is overwritten to ensure that keys with "password" are shown as "***" instead of their actual value.
     * Adapted from the AbstractMap implementation.  Final to ensure that it is not re-overwritten.
     *
     * @return Normal Map toString() but with password values given as "***"
     */
    @Override
    public final String toString() {
        // Adapted as closely as possible from AbstractMap
        Iterator<Map.Entry<String, String>> i = map.entrySet().iterator();
        if (!i.hasNext())
            return "{}";

        StringBuilder sb = new StringBuilder();
        sb.append('{');
        while (true) {
            Map.Entry<String, String> e = i.next();
            String key = e.getKey();
            String value = e.getValue();
            sb.append(key);
            sb.append('=');
            sb.append(key.contains("password") ? "***" : value);
            if (!i.hasNext())
                return sb.append('}').toString();
            sb.append(',').append(' ');
        }
    }
}
