#!/bin/bash

# INSTALL JAVA
sudo su
amazon-linux-extras install java-openjdk11 --assume-yes 

# SET RDS_HOST ENV VARIABLE
aws s3 cp s3://ac-buk/persist3-0.0.1-SNAPSHOT.jar persist3-0.0.1-SNAPSHOT.jar  
RDS_HOST=$(aws ec2 describe-tags --region us-east-1 --filters Name=key,Values=RDSHost | grep -oP '(?<="Value": ")[^"]*') java -jar persist3-0.0.1-SNAPSHOT.jar &


