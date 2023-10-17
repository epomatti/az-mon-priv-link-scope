#!/bin/bash

# Application Insights Connection String
connectionString=$(az monitor app-insights component show --app 'appi-myjavaapp' -g 'rg-myjavaapp' --query 'connectionString' -o tsv)
export APPLICATIONINSIGHTS_CONNECTION_STRING=$connectionString

# Java Agent
appiver="3.4.17"
appiOutput="applicationinsights-agent-$appiver.jar"
appiUri="https://github.com/microsoft/ApplicationInsights-Java/releases/download/$appiver/applicationinsights-agent-$appiver.jar"

curl -L -o $appiOutput $appiUri
export MAVEN_OPTS="-javaagent:applicationinsights-agent-$appiver.jar"

# Output
echo "APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING"
echo "MAVEN_OPTS=$MAVEN_OPTS"
