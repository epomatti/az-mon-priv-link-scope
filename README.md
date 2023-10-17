# Azure Monitor - Private Link Scope (AMPLS)

Logging and instrumentation with Monitor services network isolation using Private Link.

This service connection allow an application to send logs, telemetry, and other data, to Azure Monitor via a private connection.

It is possible to control `send data` and `query` public connectivity separately.

<img src=".assets/ampls.png" />

## Running on the cloud

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

Run the script to build and push the docker image to ACR:

```
bash app/acrBuildPush.sh
```

Once AppSrv pulls and runs the container, call the application endpoint `/monitor` to check metrics and logs being sent to Azure Monitor via a private connection.

## Local development

Create the Azure Monitor resources for testing locally:

```sh
# Upgrade Bicep
az bicep upgrade

# Create the resources
az deployment sub create \
  --location brazilsouth \
  --template-file dev/main.bicep \
  --parameters rgLocation=brazilsouth
```

For local development, enter the `app` directory:

```sh
cd app
```

Configure and connect your local session to Azure Monitor:

```sh
bash appiSetup.sh
```

Start the application:

```sh
./mvnw spring-boot:run
```

Test the endpoint:

```sh
# Basic check
curl localhost:8080/hello

# Write to standard out and check Monitor
curl localhost:8080/monitor
```
