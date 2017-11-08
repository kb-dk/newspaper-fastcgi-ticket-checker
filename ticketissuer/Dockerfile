FROM maven:3-jdk-9-slim as app
MAINTAINER abr@kb.dk

# Mirror Nexus for caching half the internet.   -s /usr/share/maven/ref/settings-docker.xml not used.
COPY docker-settings.xml /root/.m2/settings.xml

WORKDIR /usr/src/app

RUN mvn -B -q -Dproject.basedir=. -Dmdep.stripClassifier -Dmdep.stripVersion -Dartifact=dk.statsbiblioteket.medieplatform.ticketsystem:ticket-system-service:1.0.0:war dependency:copy

FROM tomcat:8.5-jre8

WORKDIR /app

COPY ticketissuer/context-default.xml /usr/local/tomcat/conf/Catalina/localhost/context.xml.default

COPY --from=app /usr/src/app/target/dependency/*.war /usr/local/tomcat/webapps/

