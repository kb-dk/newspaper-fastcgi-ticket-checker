# -slim because of https://github.com/carlossg/docker-maven/issues/50
FROM maven:3-jdk-9-slim as app
MAINTAINER tra@kb.dk
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

RUN mvn -B -fae -s /usr/share/maven/ref/settings-docker.xml -f mocksumma/pom.xml dependency:go-offline

COPY . .
RUN mvn -B -fae -s /usr/share/maven/ref/settings-docker.xml -f mocksumma/pom.xml package -DskipTests
RUN find . -type f -print


FROM openjdk:9-jdk-slim
WORKDIR /target
# no dependencies
COPY --from=app /usr/src/app/mocksumma/target/mocksumma-*.jar /target/mocksumma.jar

CMD java --add-modules java.se.ee -jar /target/mocksumma.jar 'http://0.0.0.0:56808/mediehub/search/services/SearchWS'
