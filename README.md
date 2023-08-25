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

Set the `APPLICATIONINSIGHTS_CONNECTION_STRING` environment variable:

```sh
cp sample.env .env
```
