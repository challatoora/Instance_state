#!/bin/bash

INSTANCE_ID="$@"

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <instance-id>"
    exit 1
fi

# Check if instance ID exists and get current state
STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text 2>/dev/null)

if [ $? -ne 0 ] || [ "$STATE" = "None" ]; then
    echo "Invalid EC2 Instance ID: $INSTANCE_ID"
    exit 1
fi

echo "Current instance state: $STATE"

if [ "$STATE" = "running" ]; then
    echo "Stopping instance..."
    aws ec2 stop-instances --instance-ids "$INSTANCE_ID" >/dev/null

    aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"

elif [ "$STATE" = "stopped" ]; then
    echo "Instance is already stopped."

else
    echo "Instance is in '$STATE' state. No action taken."
fi

FINAL_STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text)

echo "Final instance state: $FINAL_STATE"