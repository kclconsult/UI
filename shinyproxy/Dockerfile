FROM openjdk:8-jre

RUN mkdir -p /opt/shinyproxy/
RUN wget https://www.shinyproxy.io/downloads/shinyproxy-2.2.2.jar -O /opt/shinyproxy/shinyproxy.jar
COPY ./application.yml /opt/shinyproxy/application.yml

WORKDIR /opt/shinyproxy/
COPY ./certs/ certs/
RUN (keytool -import -file certs/consult.crt -alias consult -storepass changeit -noprompt -keystore "$JAVA_HOME/lib/security/cacerts")
EXPOSE 8080
CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
