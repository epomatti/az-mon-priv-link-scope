# syntax=docker/dockerfile:1

### Builder ###
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY . .
RUN ./mvnw dependency:go-offline
RUN ./mvnw clean install

# Application Insights
RUN mkdir /opt/appi
ARG agentVersion="3.4.14"
RUN curl -L https://github.com/microsoft/ApplicationInsights-Java/releases/download/$agentVersion/applicationinsights-agent-$agentVersion.jar --output /opt/appi/appi-agent.jar
COPY ./applicationinsights.json /opt/appi/


### Runtime ###
FROM eclipse-temurin:17-jre-jammy
WORKDIR /opt/app
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar
COPY --from=builder /opt/appi /opt/appi
EXPOSE 8080
# ENTRYPOINT ["java", "-javaagent:/opt/appi/appi-agent.jar", "-jar", "/opt/app/*.jar" ]
ENTRYPOINT ["java", "-javaagent:/opt/appi/appi-agent.jar", "-jar", "/opt/app/*.jar" ]

# https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot