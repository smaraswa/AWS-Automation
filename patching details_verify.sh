#!/bin/bash
echo -e "Instance_Name\t\tPatch_Method\t\tPatch_Group\t\tLatest_Version\t\tSSM_Status"

for INSTANCE in `cat instanceid.txt`;
do
# Get instance name tag
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE" "Name=key,Values=Name" --query 'Tags[*].Value' --output text)

# Get patch method tag
PATCH_METHOD=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE" "Name=key,Values=Patch_Method" --query 'Tags[*].Value' --output text)

# Get patch group tag
PATCH_GROUP=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE" "Name=key,Values=Patch Group" --query 'Tags[*].Value' --output text)

# Get the latest patch version
LATEST_VERSION=$(aws ssm describe-instance-patches --instance-id $INSTANCE --query 'Patches[*].Version' --output text | sort -r | head -n 1)

# Get the SSM status
SSM_STATUS=$(aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE" --query 'InstanceInformationList[*].PingStatus' --output text)

# Print the results in a table
echo -e "$INSTANCE_NAME\t\t$PATCH_METHOD\t\t$PATCH_GROUP\t\t$LATEST_VERSION\t\t$SSM_STATUS"

done