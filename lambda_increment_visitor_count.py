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
    Increments the visitor count in a DynamoDB table.
    """
    try:
        # Atomically increment the 'visits' attribute
        response = table.update_item(
            Key={'id': 'global_count'},
            UpdateExpression='SET visits = if_not_exists(visits, :start_val) + :inc',
            ExpressionAttributeValues={
                ':inc': 1,
                ':start_val': 0
            },
            ReturnValues='UPDATED_NEW'
        )
        new_count = int(response['Attributes']['visits'])

        # Return a successful response with the new count and CORS headers
        return {
            'statusCode': 200,
            # Add the CORS headers to allow cross-origin requests
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'count': new_count})
        }
    except Exception as e:
        print(f"Error incrementing visitor count: {e}")
        # Return an error response with a 500 status code and CORS headers
        return {
            'statusCode': 500,
            # It's good practice to also include CORS headers on error responses
            'headers': {
                'Access-Control-Allow-Origin': '*',
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'error': 'Could not increment visitor count.'})
        }
