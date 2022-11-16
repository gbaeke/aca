
# Deploy Environment

```bash
LOCATION=westeurope
RG=aca-demo
ENVNAME=env-aca
LA=la-aca

az group create --name $RG --location $LOCATION

# create application insights
az monitor app-insights component create \
  --app ai-aca \
  --location $LOCATION \
  --resource-group $RG

# retrieve app insights instrumentation key
AIKEY=$(az monitor app-insights component show \
  --app ai-aca \
  --resource-group $RG \
  --query instrumentationKey -o tsv)


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
  --tags env=dev \
  --dapr-instrumentation-key $AIKEY
```

# Create API
    
```bash
APPNAME=frontend
DAPRID=frontend 
IMAGE="ghcr.io/gbaeke/super:1.0.5"
PORT=8080
RG=aca-demo
ENVNAME=env-aca

az containerapp create --name $APPNAME --resource-group $RG \
--environment $ENVNAME --image $IMAGE \
--min-replicas 0 --max-replicas 2 --enable-dapr \
--dapr-app-id $DAPRID --target-port $PORT --ingress external \
--env-vars WELCOME="Hello from frontend (v1.0.5)"

export FQDN=$(az containerapp show -n $APPNAME -g $RG | jq .properties.configuration.ingress.fqdn -r)

curl https://$FQDN
```