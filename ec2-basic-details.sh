#!/bin/bash

# Define table headers
echo -e "Name\t\t\tIPAddress\t\tInstance Type\t\tState\t\t\tInstance Creation Time\t\tCPU Threads\t\tCPU Cores"

# Generate table
for instance in $(aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId')
do
  # Get Name
  name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" --query 'Tags[?Key==`Name`].Value' --output text)

  # Get IP
  ip=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].PublicIpAddress')

  # Get Instance Type
  type=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].InstanceType')

  # Get State
  state=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].State.Name')

  # Get Root Volume Created
  root_vol_created=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].BlockDeviceMappings[0].Ebs.VolumeId')
  root_vol_created=$(aws ec2 describe-volumes --volume-ids $root_vol_created | jq -r '.Volumes[].CreateTime')

  # Get CPU Threads
  cpu_threads=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].CpuOptions.ThreadsPerCore')

  # Get CPU Cores
  cpu_cores=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].CpuOptions.CoreCount')

  # Output
  echo -e "$name\t\t$ip\t\t$type\t\t$state\t\t$root_vol_created\t\t$cpu_threads\t\t$cpu_cores"
done

