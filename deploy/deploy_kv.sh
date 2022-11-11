az group create -n aca-demo -l westeurope

# retrieve user object id with azure cli
OBJECTID=$(az ad signed-in-user show --query id -o tsv)

# create without pe
az deployment group create -g aca-demo -f main.bicep --parameters parKVReaderObjectId=$OBJECTID \
    parKVAdminObjectId=$OBJECTID  parSubnetId='' \
    parKVPrivateDNSZoneId='' parACPrivateDNSZoneId='' \
    parEnablePrivateLink=false parPrincipalType='User'