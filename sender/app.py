import argparse
import json
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from termcolor import colored

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--connection_string", required=True, help="The connection string for the Azure Service Bus namespace.")
parser.add_argument("--topic_name", required=True, help="The name of the topic to send messages to.")
parser.add_argument("--num_messages", required=True, type=int, help="The number of messages to send.")
args = parser.parse_args()

# Create a ServiceBusClient
servicebus_client = ServiceBusClient.from_connection_string(args.connection_string)

# Get a reference to the topic
topic = servicebus_client.get_topic_sender(args.topic_name)

# Send messages
num_messages_sent = 0
for i in range(args.num_messages):
    message = ServiceBusMessage(json.dumps({"message_number": i}))
    topic.send_messages(message)
    num_messages_sent += 1

# Print the number of messages sent
print(colored(f"Sent {num_messages_sent} messages", "green"))
