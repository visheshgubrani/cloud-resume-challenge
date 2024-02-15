import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitors')


def lambda_handler(event, context):
    response = table.get_item(
        Key={"id": "1"}
    )

    if 'Item' not in response:
        table.put_item(
            Item={
                "id": "1",
                "visitor_count": 1
            }
            
        )
        visitor_count = 1
    else:
        response = table.update_item(
            Key={"id": "1"},
            UpdateExpression="set visitor_count = visitor_count + :val",
            ExpressionAttributeValues={
                ":val": 1
            },
            ReturnValues="UPDATED_NEW"
        )
        visitor_count = response['Attributes']['visitor_count']

    return {
        'statusCode': 200,
        'body': str(visitor_count)
    }