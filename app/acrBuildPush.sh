#!/bin/bash

localTag="javaapp-local"
acr=acrepicservicex.azurecr.io
image="$acr/javaapp:latest"

docker build -t $localTag .
az acr login --name $acr
docker tag $localTag $image
docker push $image