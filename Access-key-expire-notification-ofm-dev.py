import boto3
import datetime

def list_old_keys(event):
    iam = boto3.client('iam')
    today = datetime.datetime.now()
    active_key_age = event.get('active_key_age', 60)

    users = iam.list_users()['Users']
    account_id = boto3.client('sts').get_caller_identity()["Account"]

    # Create an SES client
    ses = boto3.client('ses')

    for user in users:
        for access_key in iam.list_access_keys(UserName = user['UserName'])['AccessKeyMetadata']:
            delta = (today - access_key['CreateDate'].replace(tzinfo=None)).days
            if access_key['Status'] == 'Active':
                if delta >= active_key_age:
                    user_tags = iam.list_user_tags(UserName=user['UserName'])['Tags']
                    email = None
                    for tag in user_tags:
                        if tag['Key'] == 'email':
                            email = tag['Value']
                            break
                    
                    if email:
                        # Send an email via SES
                        ses.send_email(
                            Destination={
                                'ToAddresses': [
                                    email,
                                ],

                                'CcAddresses': [
                                'smaraswa@gmail.com',
                            ]

                            },
                            Message={
                                'Body': {
                                    'Text': {
                                        'Charset': 'UTF-8',
                                        'Data': f'**************** AWS Accesskey Expire Warning Message **************** \n\nPlease find the AWS Account Details below.\n\n AWS Account : {account_id}\n\n IAM User ID:  {user["UserName"]}\n\n Current Age of key is  : {delta} Days\n\n ********** All AWS Access Keys are mandated to be rotated every **90 Days** for security purpose **********'
                                    }
                                },
                                'Subject': {
                                    'Charset': 'UTF-8',
                                    'Data': f'Attention!  AWS Access Key Expire Notification for the user  "{user["UserName"]}" in "OFM-DEV-AWS Account {account_id}"'
                                }
                            },
                            Source='smaraswa@gmail.com'
                        )

def lambda_handler(event, context):
    list_old_keys(event)