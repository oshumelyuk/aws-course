#!/bin/bash

# INSTALL JAVA
sudo su
amazon-linux-extras install java-openjdk11 --assume-yes 

# SET RDS_HOST ENV VARIABLE
HOST=aws ec2 describe-tags --region us-east-1 --filters Name=key,Values=RDSHost | grep -oP '(?<="Value": ")[^"]*'
export RDS_HOST=$HOST

# RUN JAVA APP IN BACKGROUND
aws s3 cp s3://ac-buk/persist3-0.0.1-SNAPSHOT.jar persist3-0.0.1-SNAPSHOT.jar 
nohup java -jar persist3-0.0.1-SNAPSHOT.jar &


