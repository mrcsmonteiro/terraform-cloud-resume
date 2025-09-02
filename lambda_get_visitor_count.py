import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        response = table.get_item(Key={'id': 'global_count'})
        current_count = int(response.get('Item', {}).get('visits', 0))
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'count': current_count})
        }
    except Exception as e:
        print(f"Error retrieving visitor count: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Could not retrieve visitor count.'})
        }