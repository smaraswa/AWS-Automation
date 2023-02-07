#!/bin/bash

echo -e "\t\t\tULA Certification Details Collection Status for EC2"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

echo -e "instance_name\t\tinstance_type\tcpu_threads\tcpu_cores\thyper_threading_status\tEc2-launchtime\t\tTotal Uptime(Days | Hrs | Min | Sec)\t\tApplication Owner"

echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

#Get EC2 Instance ids

for instance in `cat instanceid.txt`;

do

# Get Instance Name

instance_name=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)

# Get Instance Type

instance_type=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[InstanceType]' --output text)

# Get CPU Threads

cpu_threads=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[CpuOptions.ThreadsPerCore]' --output text)

# Get CPU Cores

cpu_cores=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[CpuOptions.CoreCount]' --output text)

# Get HyperThreading

hyper_threading_status=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[CpuOptions.HyperThreadingOptions.Enabled]' --output text)

# Get Network interface attached

network_interface_attached_time=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[NetworkInterfaces[*].Attachment.AttachTime]' --output text)

# If the number of threads is more than one, then hyperthreading is enabled

if [ $cpu_threads -gt 1 ]; then
HT="Enabled"
else
HT="NotEnabled"
fi

# Get the network interface attached time
attached_time=$(aws ec2 describe-network-interfaces --filters Name=attachment.instance-id,Values=${instance} --query 'NetworkInterfaces[].Attachment.AttachTime' --output text)


#Calculate the uptime
current_time=$(date -d "5/31/22" +%s)
#current_time=$(date +%s)
attached_time_in_sec=$(date --date="$attached_time" +%s)
uptime_in_sec=$(( current_time - attached_time_in_sec ))

#Convert the time in days, hours, minutes and seconds
##printf "%d days, %d hours, %d minutes, %d seconds\n" $(($uptime_in_sec/86400)) $(($uptime_in_sec%86400/3600)) $(($uptime_in_sec%3600/60)) $(($uptime_in_sec%60))

totaldays=$(($uptime_in_sec/86400))
totalhrs=$(($uptime_in_sec%86400/3600))
totalmin=$(($uptime_in_sec%3600/60))
totalsec=$(($uptime_in_sec%60))

# Print the instance ID and application owner tag value in table format
owner=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" "Name=key,Values=application_owner" --query "Tags[0].Value" )


echo -e "$instance_name\t\t$instance_type\t\t$cpu_threads\t\t$cpu_cores\t\t$HT\t\t$network_interface_attached_time\t\t$totaldays\t$totalhrs\t$totalmin\t$totalsec\t\t$owner"

done
