FROM openjdk:8-jre

RUN mkdir -p /opt/shinyproxy/
RUN wget https://www.shinyproxy.io/downloads/shinyproxy-2.2.0.jar -O /opt/shinyproxy/shinyproxy.jar
COPY application.yml /opt/shinyproxy/application.yml
COPY certs/ certs/

WORKDIR /opt/shinyproxy/
COPY certs/ certs/
EXPOSE 8080
CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
