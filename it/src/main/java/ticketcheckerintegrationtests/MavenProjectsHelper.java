package ticketcheckerintegrationtests;

import java.io.FileNotFoundException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * <p>MavenProjectsHelper allows a Java snippet to locate its own .class file and from there navigate towards the root
 * of that file system, looking for a specifik path.  This can allow test code to refer to files and directories in the
 * project outside java/.../resources which can be useful for launchers to correctly configure the code to call. </p>
 * <p>Copied from DPA project 2017-09-20.</p>
 */
public class MavenProjectsHelper {
    /**
     * A launcher or a test may have to locate a given path in a project. We traverse from startDir to the root using
     * getParent() looking for the path.  If not found, throw runtime exception.  The first one found is returned.
     *
     * @param startPath  Folder which is located somewhere in the project "beneath" the path to find.
     * @param pathToFind relative path name which must resolve when traversing towards the root.
     * @return
     */
    public static Path getRequiredPathTowardsRoot(Path startPath, String pathToFind) {
        final Path pathFound = one.util.streamex.StreamEx
                .iterate(startPath, p -> p != null, p -> p.getParent()) // walk up to root
                .map(p -> p.resolve(pathToFind))
                .filter(p -> p.toFile().exists())
                .findFirst()
                .orElseThrow(() ->
                        new RuntimeException(pathToFind + " not found towards root of " + startPath.toAbsolutePath(),
                                new FileNotFoundException("..." + pathToFind)
                        ));
        return pathFound;
    }

    /**
     * A launcher may have to locate a given path in a project. We traverse from startDir to the root using getParent()
     * looking for the path.  If not found, throw runtime exception.
     *
     * @param clazz      Class which is located somewhere in the project "beneath" the path to find.
     * @param pathToFind relative path name which must resolve when traversing towards the root.
     * @return
     */
    public static Path getRequiredPathTowardsRoot(Class<?> clazz, String pathToFind) {
        try {
            // http://stackoverflow.com/a/320595/53897
            URI uri = clazz.getProtectionDomain().getCodeSource().getLocation().toURI();
            Path startFolder = Paths.get(uri);
            return getRequiredPathTowardsRoot(startFolder, pathToFind);
        } catch (URISyntaxException e) {
            throw new RuntimeException("JVM will not tell location for " + clazz.getCanonicalName(), e);
        }
    }

    /**
     * A launcher may have to locate a given path in a project. We traverse from startDir to the root using getParent()
     * looking for the path.  If not found, throw runtime exception.
     *
     * @param o          Object which class is located somewhere in the project "beneath" the path to find.
     * @param pathToFind relative path name which must resolve when traversing towards the root.
     * @return
     */
    public static Path getRequiredPathTowardsRoot(Object o, String pathToFind) {
        return getRequiredPathTowardsRoot(o.getClass(), pathToFind);
    }
}
