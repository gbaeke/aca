# Deploy Cosmos DB

```bash
uniqueId=$RANDOM
LOCATION=westeurope
RG=rg-aca

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

# Deploy Azure Container Apps

```bash
LOCATION=westeurope
RG=rg-aca
ENVNAME=env-aca
LA=la-aca

az group create --name $RG --location $LOCATION

az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $LA

LA_ID=`az monitor log-analytics workspace show --query customerId -g $RG -n $LA -o tsv | tr -d '[:space:]'`
 
LA_SECRET=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RG -n $LA -o tsv | tr -d '[:space:]'`

echo $LA_ID
echo $LA_SECRET

az containerapp env create \
  --name $ENVNAME \
  --resource-group $RG \
  --logs-workspace-id $LA_ID \
  --logs-workspace-key $LA_SECRET \
  --location $LOCATION \
  --tags env=test owner=geert
```

# Create front-end app
    
```bash
APPNAME=frontend
DAPRID=frontend # could be different
IMAGE="ghcr.io/gbaeke/super:1.0.7" # image to deploy
PORT=8080
RG=rg-aca
ENVNAME=env-aca

az containerapp create --name $APPNAME --resource-group $RG \
--environment $ENVNAME --image $IMAGE \
--min-replicas 0 --max-replicas 5 --enable-dapr \
--dapr-app-id $DAPRID --target-port $PORT --ingress external

APPID=$(az containerapp list -g $RG | jq .[].id -r)

FQDN=$(az containerapp show --ids $APPID | jq .properties.configuration.ingress.fqdn -r)

curl https://$FQDN
```

# Deploy back-end app

```bash
APPNAME=backend
export DAPRID=backend # could be different
IMAGE="ghcr.io/gbaeke/super:1.0.7" # image to deploy
PORT=8080
RG=rg-aca
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
--min-replicas 1 --max-replicas 1 --enable-dapr \
--dapr-app-port $PORT --dapr-app-id $DAPRID \
--target-port $PORT --ingress internal \
--env-vars STATESTORE=cosmosdb
```






