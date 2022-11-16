import threading
import os
import logging
import time
import signal
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

from azure.appconfiguration.provider import (
    AzureAppConfigurationProvider,
    SettingSelector,
    AzureAppConfigurationKeyVaultOptions
)

logging.basicConfig(encoding='utf-8', level=logging.WARNING)

def get_config(endpoint):
  selects = {SettingSelector(key_filter=f"myapp:*", label_filter="prd")}
  trimmed_key_prefixes = {f"myapp:"}
  key_vault_options = AzureAppConfigurationKeyVaultOptions(secret_resolver=retrieve_secret)
  app_config = {}
  try:
    app_config = AzureAppConfigurationProvider.load(
            endpoint=endpoint, credential=CREDENTIAL, selects=selects, key_vault_options=key_vault_options, 
            trimmed_key_prefixes=trimmed_key_prefixes)
  except Exception as ex:
    logging.error(f"error loading app config: {ex}")

  return app_config

def run():
    try:
      global CREDENTIAL 
      CREDENTIAL = DefaultAzureCredential(exclude_visual_studio_code_credential=True)
    except Exception as ex:
      logging.error(f"error setting credentials: {ex}")

    endpoint = os.getenv('AZURE_APPCONFIGURATION_ENDPOINT')

    if not endpoint:
        logging.error("Environment variable 'AZURE_APPCONFIGURATION_ENDPOINT' not set")

    app_config =  {}
    while True:
        if not app_config:
            logging.warning("trying to load app config")
            app_config = get_config(endpoint)
        else:
            config_value=app_config['appkey']
            logging.warning(f"doing useful work with {config_value}")
            # if key exists in app_config, do something with it
            if 'mysecret' in app_config:
                logging.warning(f"and hush hush, there's a secret: {app_config['mysecret']}")
        time.sleep(5)


class GracefulKiller:
  kill_now = False
  def __init__(self):
    signal.signal(signal.SIGINT, self.exit_gracefully)
    signal.signal(signal.SIGTERM, self.exit_gracefully)

  def exit_gracefully(self, *args):
    self.kill_now = True


def retrieve_secret(uri):
    try:
        # uri is in format: https://<keyvaultname>.vault.azure.net/secrets/<secretname>
        # retrieve key vault uri and secret name from uri
        vault_uri = "https://" + uri.split('/')[2]
        secret_name = uri.split('/')[-1]
        logging.warning(f"Retrieving secret {secret_name} from {vault_uri}...")

        # retrieve the secret from Key Vault; CREDENTIAL was set globally
        secret_client = SecretClient(vault_url=vault_uri, credential=CREDENTIAL)

        # get secret value from Key Vault
        secret_value = secret_client.get_secret(secret_name).value

    except Exception as ex:
        print(f"retrieving secret: {ex}")
    
    return secret_value

# main function
def main():
    # create a Daemon tread
    t = threading.Thread(daemon=True, target=run, name="worker")
    t.start()
    

    killer = GracefulKiller()
    while not killer.kill_now:
        time.sleep(1)

    logging.info("Doing some important cleanup before exiting")
    logging.info("Gracefully exiting")


if __name__ == "__main__":
    main()


