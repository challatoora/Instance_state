#!/bin/bash

INSTANCE_ID="$1"

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <instance-id>"
    exit 1
fi

# Check if instance ID exists and get current state
STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text)

# if [ $? -ne 0 ] || [ "$STATE" = "None" ]; then
#     echo "Invalid EC2 Instance ID: $INSTANCE_ID"
#     exit 1
# fi

echo "Current instance state: $STATE"

if [ "$STATE" = "stopped" ]; then
    echo "Starting instance..."
    aws ec2 start-instances --instance-ids "$INSTANCE_ID"

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

elif [ "$STATE" = "running" ]; then
    echo "Instance is already running."

else
    echo "Instance is in '$STATE' state. No action taken."
fi

FINAL_STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text)

echo "Final instance state: $FINAL_STATE"