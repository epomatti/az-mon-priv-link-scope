#!/bin/bash

localTag="javaapp-local"
acr=acrexamplefactory
image="$acr.azurecr.io/javaapp:latest"

docker build -t $localTag .
az acr login --name $acr
docker tag $localTag $image
docker push $image
