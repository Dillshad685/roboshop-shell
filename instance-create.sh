#will create ec2 instances using shell with AMI ID, SG name. instance type, key-pair we needed

#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f" 
SG_ID="sg-0c30fff245cb18154"
ZONE_ID="Z0375645LTAC4FZXZR6K"
DOMAIN_NAME="dillshad.space"

for instance in $@ 
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)  #to create EC2 instance using shell here instance name which we give dynamically is stored in $instance

        #to get private IP
        if [ $instance != frontend ]; then
             IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
             RECORD_NAME="$instance.$Domain_name"
        else
             IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
             RECORD_NAME="$instance.$Domain_name"
        fi

        echo '$instance:$IP

         aws route53 change-resource-record-sets \
       --hosted-zone-id $Zone_ID \
       --change-batch '
       {
         "Comment": "Updating record set"
         ,"Changes": [{
           "Action"              : "UPSERT"
           ,"ResourceRecordSet"  : {
             "Name"              : "'$RECORD_NAME'" 
             ,"Type"             : "A"
             ,"TTL"              : 1
             ,"ResourceRecords"  : [{
                 "Value"         : "'$IP'"
             }]
           }
          }]
        }
         '
done