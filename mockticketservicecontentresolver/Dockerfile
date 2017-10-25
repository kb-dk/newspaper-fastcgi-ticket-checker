# -slim because of https://github.com/carlossg/docker-maven/issues/50
FROM maven:3-jdk-9-slim AS app
MAINTAINER tra@kb.dk

# Mirror Nexus for caching half the internet.  -s /usr/share/maven/ref/settings-docker.xml not used
COPY docker-settings.xml /root/.m2/settings.xml

WORKDIR /usr/src/app

# Prepopulate - add more as needed (no pom.xml at this time)
RUN mvn -B compiler:help

# All poms.xml manually maintained for now.
COPY pom.xml .
COPY configuration-map/pom.xml configuration-map/
COPY it/pom.xml it/
COPY mocksumma/pom.xml mocksumma/
COPY mocksumma-ide/pom.xml mocksumma-ide/
COPY mockticketservicecontentresolver/pom.xml mockticketservicecontentresolver/
COPY mockticketservicecontentresolver-ide/pom.xml mockticketservicecontentresolver-ide/

RUN find . -type f -print

# cache as many artifacts as we reasonably can.
RUN mvn -B -fae -f mockticketservicecontentresolver/pom.xml dependency:go-offline || true

COPY . .
# https://stackoverflow.com/a/3899772/53897
RUN mvn -B -fae --projects mockticketservicecontentresolver --also-make package -DskipTests
RUN find . -type f -print
# -- run

FROM openjdk:9-jdk
WORKDIR /target
COPY --from=app /usr/src/app/mockticketservicecontentresolver/target/mockticketservicecontentresolver-1.0-SNAPSHOT-jar-with-dependencies.jar /target/mockticketservicecontentresolver.jar
COPY mockticketservicecontentresolver/docker.properties docker.properties
CMD java -jar /target/mockticketservicecontentresolver.jar /target/docker.properties
