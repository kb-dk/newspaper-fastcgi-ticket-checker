# -slim because of https://github.com/carlossg/docker-maven/issues/50
FROM maven:3-jdk-9-slim as app
MAINTAINER tra@kb.dk
WORKDIR /usr/src/root/app

COPY pom.xml .
´RUN mvn -B -f pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve

COPY . .
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml package -DskipTests

# -- run

FROM openjdk:9-jdk
WORKDIR /target
COPY --from=app /usr/src/app/target/mockticketservicecontentresolver-1.0-SNAPSHOT-jar-with-dependencies.jar:/mockticketservicecontentresolver.jar /target/mockticketservicecontentresolver.jar

CMD  [ "java -jar /target/mockticketservicecontentresolver.jar mockticketservice-docker.properties" ]
