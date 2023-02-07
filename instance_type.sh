#!/bin/bash

echo -e "InstanceName\t\tInstance Type\t\tOperatingSystem"

for instance in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text); do

instance_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" --query "Tags[?Key=='Name'].Value" --output text)

instance_type=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].InstanceType' --output text)

operating_system=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" "Name=key,Values=operating_system" --query "Tags[0].Value" --output text)

echo -e "$instance_name\t\t$instance_type\t\t$operating_system"

done