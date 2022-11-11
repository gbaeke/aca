import os, requests, json, uuid, time

# retrieve FQDN environment variable
fqdn = os.environ.get('FQDN')


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
    r = requests.post("https://" + fqdn + "/call", json=payload)
