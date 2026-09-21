#!/usr/bin/env bash

set -Eeuo pipefail

REGION="${AWS_REGION:-us-east-1}"

echo "======================================"
echo " AWS Resource Check"
echo "======================================"
echo "Region: $REGION"
echo

if ! command -v aws >/dev/null 2>&1; then
    echo "ERROR: AWS CLI is not installed."
    exit 1
fi

echo "[1] AWS Identity"
echo "--------------------------------------"

aws sts get-caller-identity

echo
echo "[2] EC2 Instances"
echo "--------------------------------------"

aws ec2 describe-instances \
    --region "$REGION" \
    --query 'Reservations[].Instances[].{
        InstanceId:InstanceId,
        State:State.Name,
        Type:InstanceType,
        PrivateIP:PrivateIpAddress,
        PublicIP:PublicIpAddress
    }' \
    --output table

echo
echo "[3] Security Groups"
echo "--------------------------------------"

aws ec2 describe-security-groups \
    --region "$REGION" \
    --query 'SecurityGroups[].{
        GroupId:GroupId,
        Name:GroupName,
        VPC:VpcId
    }' \
    --output table

echo
echo "[4] S3 Buckets"
echo "--------------------------------------"

aws s3 ls

echo
echo "[5] EKS Clusters"
echo "--------------------------------------"

aws eks list-clusters \
    --region "$REGION" \
    --output table

echo
echo "[6] RDS Instances"
echo "--------------------------------------"

aws rds describe-db-instances \
    --region "$REGION" \
    --query 'DBInstances[].{
        Identifier:DBInstanceIdentifier,
        Engine:Engine,
        Status:DBInstanceStatus,
        Class:DBInstanceClass
    }' \
    --output table

echo
echo "======================================"
echo " AWS resource check completed"
echo "======================================"