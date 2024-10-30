from datetime import datetime
import json
import boto3

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    num_messages = str(len(event['Records']))
    print("Found " + num_messages + " messages to process.")

    requests = []

    for message in event['Records']:
        requests.append({
            'PutRequest': {
                'Item': {
                    'MessageId': message['messageId'],
                    'Body': message['body'],
                    'Timestamp': datetime.now().isoformat()
                }
            }
        })

    response = dynamodb.batch_write_item(
        RequestItems={
            'Activity': requests
        }
    )

    print("Wrote messages to DynamoDB:", json.dumps(response))
