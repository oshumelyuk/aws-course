#!/bin/bash

# INSTALL JAVA
sudo su
amazon-linux-extras install java-openjdk11 --assume-yes 

# RUN APP IN BACKGROUND
aws s3 cp s3://ac-buk/calc-0.0.1-SNAPSHOT.jar calc-0.0.1-SNAPSHOT.jar
nohup java -jar calc-0.0.1-SNAPSHOT.jar &