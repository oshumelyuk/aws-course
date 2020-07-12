#!/bin/bash

sudo su
amazon-linux-extras install java-openjdk11 --assume-yes 
aws s3 cp s3://ac-buk/persist3-0.0.1-SNAPSHOT.jar persist3-0.0.1-SNAPSHOT.jar 
java -jar persist3-0.0.1-SNAPSHOT.jar 

