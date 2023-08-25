# Azure Monitor Private Link Scope

Logging and instrumentation with network isolation.

## Local development

```sh
az deployment sub create \
  --location brazilsouth \
  --template-file dev/main.bicep \
  --parameters rgLocation=brazilsouth
```

```sh
az monitor app-insights component show --app 'appi-myjavaapp' -g 'rg-myjavaapp' --query 'connectionString' -o tsv
```

```sh
export APPLICATIONINSIGHTS_CONNECTION_STRING='<Your Connection String>'
```

In the `app` directory, download the latest release of the agent: 

```
curl -L -o applicationinsights-agent-3.4.14.jar https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.4.14/applicationinsights-agent-3.4.14.jar
```

Setup the 

```
export MAVEN_OPTS=-javaagent:applicationinsights-agent-3.4.14.jar
```

Run the application:

```sh
./mvnw spring-boot:run
```