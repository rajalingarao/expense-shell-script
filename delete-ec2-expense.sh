#!/bin/bash

instances=("frontend" "backend" "db")
domain_name="lithesh.shop"
hosted_zone_id="Z012785114HGZTDQ8KSQH"

for name in ${instances[@]}; do

echo "Finding instance for: $name"

instance_id=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$name" "Name=instance-state-name,Values=running,pending,stopped" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text)

if [ -z "$instance_id" ]; then
  echo "No instance found for $name"
  continue
fi

echo "Instance found: $instance_id"

if [ "$name" == "frontend" ]; then
    ip_to_use=$(aws ec2 describe-instances \
      --instance-ids $instance_id \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
else
    ip_to_use=$(aws ec2 describe-instances \
      --instance-ids $instance_id \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)
fi

echo "Deleting Route53 record for $name"

aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
{
 "Comment": "Deleting record for '$name'",
 "Changes": [{
   "Action": "DELETE",
   "ResourceRecordSet": {
     "Name": "'$name.$domain_name'",
     "Type": "A",
     "TTL": 1,
     "ResourceRecords": [{
        "Value": "'$ip_to_use'"
     }]
   }
 }]
}'

echo "Terminating EC2 instance: $instance_id"

aws ec2 terminate-instances --instance-ids $instance_id

done