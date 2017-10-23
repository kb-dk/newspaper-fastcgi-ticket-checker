FROM maven:3-jdk-9-with-newspaper-fastcgi-parent as app
MAINTAINER tra@kb.dk
WORKDIR /usr/src/app

COPY pom.xml .
RUN mvn -B -f pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve

COPY . .
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml package -DskipTests


FROM openjdk:9-jdk
WORKDIR /target
# no dependencies
COPY --from=app /usr/src/app/target/mocksumma-*.jar /target/mocksumma.jar

CMD [ "java --add-modules java.se.ee -jar /target/mocksumma.jar 'http://0.0.0.0:56808/mediehub/search/services/SearchWS'" ]
