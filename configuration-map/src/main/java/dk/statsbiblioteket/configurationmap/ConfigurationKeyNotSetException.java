package dk.statsbiblioteket.configurationmap;

/**
 * The purpose of this class is to give a telling name to the exception.  Hence only the String constructor is
 * implemented.
 */
public class ConfigurationKeyNotSetException extends RuntimeException {
    public ConfigurationKeyNotSetException(String key) {
        super(key);
    }
}
