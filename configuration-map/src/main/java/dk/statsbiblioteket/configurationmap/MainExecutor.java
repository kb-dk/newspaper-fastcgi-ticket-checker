package dk.statsbiblioteket.configurationmap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;
import java.util.concurrent.Callable;
import java.util.function.Function;
import java.util.regex.Pattern;

import static java.lang.management.ManagementFactory.getRuntimeMXBean;
import static java.time.LocalDate.now;

/**
 * Adapted from AutonomousPreservationToolHelper in DPA.  Establish a configuration map, and a logging fault
 * barrier and invoke the passed-in function.
 */
public class MainExecutor {

    public static final Logger LOGGER = LoggerFactory.getLogger(MainExecutor.class);

    public static final String KB_GIT_ID = "kb.git.id";

    /**
     * Expect a argument array (like passed in to "main(String[] args)"), create a configuration map from first the
     * resource and then the configuration file denoted by args[0], plus the remaining arguments interpreted as
     * "key=value" lines, and pass it into the given function returning a Tool, which is then executed.  It is not
     * expected to return.  If any error but FileNotFoundException is thrown it is rethrown as a RuntimeException.
     *
     * @param args     like passed in to "main(String[] args)"
     * @param function function creating a populated Tool from a configuration map.
     */

    public static <T extends Callable> void execute(String[] args, Function<ConfigurationMap, T> function) {
        Objects.requireNonNull(args, "args == null");
        // args: ["config.properties",  "a=1", "b=2", "c=3"]
        if (args.length < 1 || "-h".equals(args[0]) || "--help".equals(args[0])) {
            throw new IllegalArgumentException("usage: configuration-file/url [key1=value1 [key2=value2 ..]]");
        }

        ConfigurationMap map = new ConfigurationMap(Collections.emptyMap());

        // "config.properties"
        String configurationName = args[0];

        // First read the resource if present (probably baked into the jar files)
        {
            InputStream inputStream = Thread.currentThread().getContextClassLoader().getResourceAsStream(configurationName);
            if (inputStream == null) {
                LOGGER.debug("resource not found: {}", configurationName);
            } else {
                try (InputStreamReader inputStreamReader = new InputStreamReader(inputStream, StandardCharsets.UTF_8)) {
                    ConfigurationMapHelper.propertiesAsMap(inputStreamReader).ifPresent(map::add);
                } catch (IOException e) {
                    throw new RuntimeException("could not read resource " + configurationName, e);
                }
            }
        }

        // Then read the property file of the file system if present (keys here override keys already loaded)
        {
            File configurationFile = new File(configurationName);
            try (Reader fileReader = Files.newBufferedReader(configurationFile.toPath(), StandardCharsets.US_ASCII)) {
                ConfigurationMapHelper.propertiesAsMap(fileReader).ifPresent(map::add);
            } catch (NoSuchFileException e) {
                LOGGER.info("not found: {}", configurationFile.getAbsolutePath());
            } catch (IOException e) {
                throw new RuntimeException("could not read " + configurationFile.getAbsolutePath(), e);
            }
        }

        // Then add the git id, as added by the launcher scripts generator
        {
            map.add(ConfigurationMapHelper.systemPropertiesAsMap(KB_GIT_ID));
        }

        // Finally, add "key=value" pairs from the command line, overriding any previous values
        {
            Map<String, String> argsMap = new TreeMap<>();

            // remainingArgs: ["a=1", "b=2", "c=3"]
            String[] remainingArgs = Arrays.copyOfRange(args, 1, args.length);
            for (String keyValue : remainingArgs) {
                String[] splitKeyValue = keyValue.split(Pattern.quote("="), 2);
                if (splitKeyValue.length > 1) {
                    String key = splitKeyValue[0];
                    String value = splitKeyValue[1];
                    argsMap.put(key, value);
                }
            }
            map.add(argsMap);
        }

        // -- and go.
        execute(map, function);
    }

    /**
     * Expect a argument array (like passed in to "main(String[] args)"), create a configuration map from args[0], and
     * pass it into the given function returning a Tool, which is then executed.  It is not expected to return.
     *
     * @param map          configuration map to pass into <code>function</code>
     * @param mapToT_Function function creating a populated Tool from a configuration map.
     */
    public static <T extends Callable> void execute(ConfigurationMap map, Function<ConfigurationMap, T> mapToT_Function) {
        Objects.requireNonNull(map, "map == null");
        final Logger log = LoggerFactory.getLogger(MainExecutor.class);

        final String gitId = map.get(KB_GIT_ID).orElse("(non-production)");

        log.info("*** Started at {} - {} ms since JVM start. git: {} ", now(), getRuntimeMXBean().getUptime(), gitId);
        log.debug("configuration: {}", map);
        log.trace("------------------------------------------------------------------------------");

        Runtime.getRuntime().addShutdownHook(new Thread(
                () -> { // Ensure we have an "end of log"-marker.
                    log.trace("------------------------------------------------------------------------------");
                    log.info("*** Stopped at {} - {} ms since JVM start.", now(), getRuntimeMXBean().getUptime());
                }));

        try {
            final T tool = mapToT_Function.apply(map);
            final Object result = tool.call();
            log.info("Result: {}", result);
        } catch (Throwable e) {  // Outermost fault barrier - any cause must be logged.
            log.error("Runnable threw exception:", e);
        }
    }
}
