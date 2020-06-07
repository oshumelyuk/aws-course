#!/bin/bash

cd /home/ec2-user
aws s3 cp s3://ac-buk/rds-script.sql rds-script.sql
aws s3 cp s3://ac-buk/dynamodb-script.sh dynamodb-script.sh 
aws configure set region us-east-1