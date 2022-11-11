# Deploy with containerapp up

Deploy from the source files in the current directory:

```bash
RG=aca-demo
ENVNAME=env-aca

az containerapp up -n worker -g $RG --environment $ENVNAME \
    --source . -l westeurope
```
