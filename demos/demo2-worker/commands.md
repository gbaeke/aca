
# Create worker app
    
```bash
APPNAME=worker
IMAGE="docker.io/gbaeke/acaworker:v6" # image to deploy
RG=aca-demo
ENVNAME=env-aca

az containerapp create --name $APPNAME --resource-group $RG \
--environment $ENVNAME --image $IMAGE \
--min-replicas 1 --max-replicas 1

```