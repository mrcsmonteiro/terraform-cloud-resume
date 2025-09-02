import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
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
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'count': new_count})
        }
    except Exception as e:
        print(f"Error incrementing visitor count: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Could not increment visitor count.'})
        }