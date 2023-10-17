# syntax=docker/dockerfile:1

### Builder ###
FROM eclipse-temurin:21-jdk-jammy as builder
WORKDIR /opt/app
COPY . .
RUN ./mvnw dependency:go-offline
RUN ./mvnw clean install

# Application Insights
RUN mkdir /opt/appi
ARG agentVersion="3.4.17"
RUN curl -L https://github.com/microsoft/ApplicationInsights-Java/releases/download/$agentVersion/applicationinsights-agent-$agentVersion.jar --output /opt/appi/appi-agent.jar
# TODO: Configure instrumentation settings
# COPY ./applicationinsights.json /opt/appi/


### Runtime ###
# https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot

FROM eclipse-temurin:21-jre-jammy
WORKDIR /opt/app
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar
COPY --from=builder /opt/appi /opt/appi
EXPOSE 8080
ENTRYPOINT ["java", "-javaagent:/opt/appi/appi-agent.jar", "-jar", "/opt/app/*.jar" ]
