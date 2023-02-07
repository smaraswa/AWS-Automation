#! /bin/bash
for i in `cat m4_instances`; do

# Verify ENASupport enabled
aws ec2 --profile ansadm describe-instances  --instance-ids $i  --query "Reservations[].Instances[].EnaSupport" --output table
aws ec2 --profile ansadm modify-instance-attribute --instance-id $i --ena-support --output table

# Validate the instance stopped state
aws ec2 --profile ansadm stop-instances --instance-id $i --output table
aws ec2 describe-instances --profile ansadm --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --filters Name=instance-state-name,Values=running --output table

# Change the AWS instance type
aws ec2 --profile ansadm modify-instance-attribute --instance-id $i --instance-type m5.large --output table
aws ec2 --profile ansadm start-instances --instance-id $i --output table

#  Validate if the instance type is changed
aws ec2 --profile ansadm describe-instances --instance-ids  $i --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId,Instancetype:InstanceType}"  --output table

ethtool -i eth0
df -h
done
