# Starting situation

Resource group: `aca-demo`

👉 Deploy App Configuration and Key Vault with `./deploy/deploy_kv.sh`

👉 Deploy ACA Environment, Log Analytics and App Insights with commands in `./demos/demo1-single/commands.md`
([link](./demos/demo1-single/commands.md))


# Demo 1: Deploy single container app

👉 Deploy container app with commands from `./demos/demo1-single/commands.md`
([link](./demos/demo1-single/commands.md))

Demonstrate:
- Container App is deployed
- Logs are streamed to Log Analytics
- Ingress is configured
    - HTTP ingress
    - TCP ingress requires a vnet
- There is one revision
- Making a change to the container results in a new revision
    - change the container `tag` and `environment variable` WELCOME
- Explain single and multiple revision mode
- Enable multiple revisions
- Split traffic 50/50 between revisions

# Demo 2: Deploy a worker

👉 Deploy worker with `az containerapp up` (see `./worker/README.md`)
([link](./worker/README.md))

Example command:

```bash
az containerapp up -n worker -g $RG --environment $ENVNAME \
    --source . -l westeurope
```

Demonstrate:
- Python image with the code is built by a new ACR instance
- Worker is deployed with image from ACR 
- There is no ingress
- Look at the realtime logs and point out there are errors
- Look at the worker code in `app.py`
    - it needs an environment variable `AZURE_APPCONFIGURATION_ENDPOINT`
    - that variable needs the endpoint of the App Configuration instance
    - show the App Configuration instance in the portal and the value to retrieve
- Demonstrate the use of Linked Services (preview)
    - add the App Configuration instance as a linked service
    - it configures `managed identity` and the environment variable
    - the environment variable gets it value from the Container App secret
    - show the logs: useful work is done with the value 😉

**Note:** we can modify the source code and run `az containerapp up` again to update the container app


# Demo 3: Deploy envent driven container app

👉 Deploy service bus with commands from `./demos/demo3-scale/commands.md`
([link](./demos/demo3-scale/commands.md))

👉 Deploy container app with commands from `./demos/demo3-scale/commands.md`
([link](./demos/demo3-scale/commands.md))

Deployment is done with Bicep:

```bash
RG=aca-demo
LOCATION=westeurope

az deployment group create --resource-group $RG --template-file ./main.bicep --parameters parLocation=$LOCATION
```

Demonstrate:
- Service Bus namespace is deployed and topic created (mytopic)
- Container App is deployed
- Dapr component is deployed and scoped to the container app
- There is no ingress
- Scaling is configured with a custom service bus topic scaler
- Show the logs, including the Dapr logs
- Send messages to the topic

# Demo 4: Deploy microservices

👉 Deploy Cosmos DB with commands from `./demos/demo4-multi/commands.md`
([link](./demos/demo4-multi/commands.md))

👉 Deploy frontend container app with commands from `./demos/demo4-multi/commands.md`
([link](./demos/demo4-multi/commands.md))

👉 Deploy backend container app with commands from `./demos/demo4-multi/commands.md`
([link](./demos/demo4-multi/commands.md))

⚠️ Backend needs Cosmos DB to be **fully deployed**; frontend can be deployed any time

Demonstrate:
- Cosmos DB is deployed with a container to save state with key/value pairs
- Dapr component is deployed and scoped to the container app
- Frontend is deployed with ingress
- Backend is deployed without ingress
- Frontend will call backend to store data in Cosmos DB
- Show the logs
- Start `app.py` to send messages to the front end

⚠️ For `app.py` to work, you need the FQDN of the frontend container app:

Retrieve the FQDN from an Azure Container Apps with the Azure CLI:
    
```bash
RG=rg-aca
APPID=$(az containerapp show -g $RG -n frontend | jq .[].id -r)
EXPORT FQDN=$(az containerapp show --ids $APPID | jq .properties.configuration.ingress.fqdn -r)
```

# Tips

Use the VS Code [markdown command runner](https://marketplace.visualstudio.com/items?itemName=qbik.markdown-command-runner-fork) to run markdown code snippets in terminal.

