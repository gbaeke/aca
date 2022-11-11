# Deploy Service Bus

```bash
RG=aca-demo
SBNAME=academogeba
LOCATION=westeurope

az servicebus namespace create --resource-group $RG --name $SBNAME --location $LOCATION --sku Standard

# create topic
az servicebus topic create --resource-group $RG --namespace-name $SBNAME --name mytopic

```

# Deploy container app with Bicep
    
```bash
RG=aca-demo
LOCATION=westeurope

az deployment group create --resource-group $RG --template-file ./main.bicep --parameters parLocation=$LOCATION
```