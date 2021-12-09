FROM anapsix/alpine-java
MAINTAINER Farzana Razia S
VOLUME /tmp
EXPOSE 8888
ARG JAR_FILE=target/bootcamp-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} bootcamp.jar
ENTRYPOINT ["java","-jar", "bootcamp.jar"]
