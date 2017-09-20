package dk.statsbiblioteket.mediestream.ticketcheckerintegrationtests;

import com.palantir.docker.compose.DockerComposeRule;
import com.palantir.docker.compose.configuration.ProjectName;
import com.palantir.docker.compose.configuration.ShutdownStrategy;
import com.palantir.docker.compose.connection.ContainerName;
import com.palantir.docker.compose.connection.waiting.HealthChecks;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import ticketcheckerintegrationtests.MavenProjectsHelper;

import java.io.IOException;
import java.util.List;

/**
 *
 */
public class InitialSimpleTest {

    private static DockerComposeRule docker;

    @BeforeClass
    public static void beforeClass() throws IOException, InterruptedException {
        docker = DockerComposeRule.builder()
                .file(MavenProjectsHelper
                        .getRequiredPathTowardsRoot(InitialSimpleTest.class, "docker-compose.yml")
                        .toAbsolutePath().toString())
                .waitingForService("memcached", HealthChecks.toHaveAllPortsOpen())
                .waitingForService("web", HealthChecks.toHaveAllPortsOpen())
                .removeConflictingContainersOnStartup(true)
                .shutdownStrategy(ShutdownStrategy.GRACEFUL)
                .projectName(ProjectName.fromString("ticketcheckerintegrationtest"))
                .build();

        docker.before();

        // Emergency cleanup.
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            docker.after();
            List<ContainerName> ps = null;
            try {
                ps = docker.dockerCompose().ps();
            } catch (Exception e) {
                throw new IllegalStateException("Could not ask docker for ps", e);
            }
            if (ps.isEmpty() == false){
                throw new IllegalStateException("Containers still running: " + ps);
            }
        }));
    }


    @Test
    public void simpleTest() {
        Assert.assertTrue(true);
    };
}
