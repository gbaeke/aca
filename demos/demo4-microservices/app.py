import os, requests, json, uuid, time

# retrieve FQDN environment variable
fqdn = os.environ.get('FQDN')

if not fqdn:
    print("Please set FQDN to URL of container app\n")
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
        r = requests.post(fqdn + "/call", json=payload)
        if r.status_code == 200:
            print("Successfully posted payload")
        else:
            print("Error posting payload:" + str(r.status_code) + " " + r.text)
    except Exception as e:
        print("Error: " + str(e))
        exit(1)
