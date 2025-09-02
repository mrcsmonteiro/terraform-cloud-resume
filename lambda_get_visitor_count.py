import json
import boto3
import os

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
# Get the table name from environment variables
TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """
    Retrieves the visitor count from a DynamoDB table.
    """
    try:
        # Get the item with the key 'global_count'
        response = table.get_item(Key={'id': 'global_count'})
        current_count = int(response.get('Item', {}).get('visits', 0))

        # Return a successful response with the count and CORS headers
        return {
            'statusCode': 200,
            # Add the CORS headers to allow cross-origin requests
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'count': current_count})
        }
    except Exception as e:
        print(f"Error retrieving visitor count: {e}")
        # Return an error response with a 500 status code and CORS headers
        return {
            'statusCode': 500,
            # It's good practice to also include CORS headers on error responses
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'error': 'Could not retrieve visitor count.'})
        }
