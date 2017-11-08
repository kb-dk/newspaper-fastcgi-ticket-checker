# -slim because of https://github.com/carlossg/docker-maven/issues/50
FROM maven:3-jdk-8-slim AS app
MAINTAINER tra@kb.dk

# Mirror Nexus for caching half the internet.  -s /usr/share/maven/ref/settings-docker.xml not used
COPY docker-settings.xml /root/.m2/settings.xml

WORKDIR /usr/src/app

COPY . .
# https://stackoverflow.com/a/3899772/53897
RUN mvn -B -fae --projects mockticketservicecontentresolver --also-make package -DskipTests
#RUN find . -type f -print
# -- run

FROM tomcat:8.5-jre8
COPY --from=app /usr/src/app/mockticketservicecontentresolver/target/mockticketservicecontentresolver-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/licensemodule.war
