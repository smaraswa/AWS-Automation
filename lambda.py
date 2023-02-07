import boto3
import datetime

def list_old_keys(email_address):
    iam = boto3.client('iam')
    today = datetime.datetime.now()

    users = iam.list_users()['Users']
    account_id = boto3.client('sts').get_caller_identity()["Account"]

    # Create an SNS client
    sns = boto3.client('sns')

    for user in users:
        for access_key in iam.list_access_keys(UserName = user['UserName'])['AccessKeyMetadata']:
            delta = (today - access_key['CreateDate'].replace(tzinfo=None)).days
            if access_key['Status'] == 'Active':
                if delta >= 60:
                    # Send an email via SNS
                    sns.publish(
                        TopicArn='arn:aws:sns:us-east-1:786504479153:access-key-expire-notification',
                        Message=f'AWS Accesskey Expire Warning Message!!! Please find the AWS Account Details below.\n\n AWS Account : {account_id}\n\n IAM User ID:  {user["UserName"]}\n\n No of Days Older now : 30 days.\n\n Please Take Necessary action',
                        Subject=f'AWS Access Key Expire Notification for user {user["UserName"]} in AWS Account {account_id}',
                        MessageStructure='string',
                        MessageAttributes={
                            'email': {
                                'DataType': 'String',
                                'StringValue': email_address
                            }
                        }
                    )

def lambda_handler(event, context):
    email_address = event.get('email_address', 'default_email_address@example.com')
    list_old_keys(email_address)



=====================

import boto3
import datetime

def list_old_keys(email_address, event):
    iam = boto3.client('iam')
    today = datetime.datetime.now()
    active_key_age = event.get('active_key_age', 60)

    users = iam.list_users()['Users']
    account_id = boto3.client('sts').get_caller_identity()["Account"]

    # Create an SNS client
    sns = boto3.client('sns')

    for user in users:
        for access_key in iam.list_access_keys(UserName = user['UserName'])['AccessKeyMetadata']:
            delta = (today - access_key['CreateDate'].replace(tzinfo=None)).days
            if access_key['Status'] == 'Active':
                if delta >= active_key_age:
                    # Send an email via SNS
                    sns.publish(
                        TopicArn='arn:aws:sns:us-east-1:813354974303:key-rotation-notification',
                        Message=f'AWS Accesskey Expire Warning Message!!! Please find the AWS Account Details below.\n\n AWS Account : {account_id}\n\n IAM User ID:  {user["UserName"]}\n\n Current Age of key is  : {delta}.\n\nAll AWS Access Keys are mandated to be rotated every 90days for security purposes',
                        Subject=f'60days AWS Access Key Expire Notification for user {user["UserName"]} in AWS Account {account_id}',
                        MessageStructure='string',
                        MessageAttributes={
                            'email': {
                                'DataType': 'String',
                                'StringValue': email_address
                            }
                        }
                    )

def lambda_handler(event, context):
    email_address = event.get('email_address', 'default_email_address@example.com')
    list_old_keys(email_address, event)