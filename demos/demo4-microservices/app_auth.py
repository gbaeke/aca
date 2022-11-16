import os, requests, json, uuid, time, sys, json, logging
import requests, msal

# retrieve FQDN environment variable
fqdn = os.environ.get('FQDN')
client_secret = os.environ.get('CLIENT_SECRET')

if not fqdn:
    print("Please set FQDN to URL of container app\n")
    exit(1)

if not client_secret:
    print("Please set CLIENT_SECRET to client secret in app registration\n")
    exit(1)

app = msal.ConfidentialClientApplication(
    "0da6c562-cb35-4058-85b3-3160fdf78e1a",
    authority="https://login.microsoftonline.com/484588df-21e4-427c-b2a5-cc39d6a73281",
    client_credential=client_secret
    )

result = None

if not result:
    print("No suitable token exists in cache. Let's get a new one from AAD.")
    result = app.acquire_token_for_client(scopes=["api://0da6c562-cb35-4058-85b3-3160fdf78e1a/.default"])

if "access_token" in result:
    print("Access token is available.")
    print(result["access_token"])
else:
    print(result.get("error"))
    print(result.get("error_description"))
    print(result.get("correlation_id"))  # You may need this when reporting a bug
    exit(1)


while True:
    # create a guid for the key name
    guid = str(uuid.uuid4())
    
    print("Generate payload with key: " + guid)

    # generate payload
    payload = {
        "appId":"backend",
        "method":"savestate",
        "httpMethod":"POST",
        "payload": '{"key": "' + guid + '", "data": "{ \\"name\\": \\"geert\\" }" }'
    }

    # post payload to FQDN
    try:
        # add authentification header
        headers = {'Authorization': 'Bearer ' + result['access_token']}
        r = requests.post("https://" + fqdn + "/call", json=payload, headers=headers)
        if r.status_code == 200:
            print("Successfully posted payload")
        else:
            print("Error posting payload:" + str(r.status_code) + " " + r.text)
    except Exception as e:
        print("Error: " + str(e))
        exit(1)
