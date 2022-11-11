
# Deploy Cosmos DB

```bash
uniqueId=$RANDOM
LOCATION=westeurope
RG=aca-demo

az group create --name $RG --location $LOCATION

az cosmosdb create \
  --name aca-$uniqueId \
  --resource-group $RG \
  --locations regionName=$LOCATION \
  --default-consistency-level Strong

az cosmosdb sql database create \
  -a aca-$uniqueId \
  -g $RG \
  -n aca-db

az cosmosdb sql container create \
  -a aca-$uniqueId \
  -g $RG \
  -d aca-db \
  -n statestore \
  -p '/partitionKey' \
  --throughput 400
```


# Create front-end app
    
```bash
APPNAME=frontend
DAPRID=frontend # could be different
IMAGE="ghcr.io/gbaeke/super:1.0.7" # image to deploy
PORT=8080
RG=aca-demo
ENVNAME=env-aca

az containerapp create --name $APPNAME --resource-group $RG \
--environment $ENVNAME --image $IMAGE \
--min-replicas 0 --max-replicas 5 --enable-dapr \
--dapr-app-id $DAPRID --target-port $PORT --ingress external

export FQDN=$(az containerapp show -n $APPNAME -g $RG | jq .properties.configuration.ingress.fqdn -r)

curl https://$FQDN
```

# Deploy back-end app

```bash
APPNAME=backend
export DAPRID=backend # could be different
IMAGE="ghcr.io/gbaeke/super:1.0.7" # image to deploy
PORT=8080
RG=aca-demo
ENVNAME=env-aca

export ENDPOINT=$(az cosmosdb list -g $RG | jq .[0].documentEndpoint -r)

export NAME=$(az cosmosdb list -g $RG | jq .[0].name -r)

export KEY=$(az cosmosdb keys list -g $RG -n $NAME | jq .primaryMasterKey -r)

# set environment variables in cosmosdb.yaml with envsubst
envsubst < cosmosdb-templ.yaml > cosmosdb.yaml

az containerapp env dapr-component set \
    --name $ENVNAME --resource-group $RG \
    --dapr-component-name cosmosdb \
    --yaml cosmosdb.yaml

az containerapp create --name $APPNAME --resource-group $RG \
--environment $ENVNAME --image $IMAGE \
--min-replicas 1 --max-replicas 10 --enable-dapr \
--dapr-app-port $PORT --dapr-app-id $DAPRID \
--target-port $PORT --ingress internal \
--env-vars STATESTORE=cosmosdb
```






