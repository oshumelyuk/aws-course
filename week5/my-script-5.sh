#!/bin/bash
# put sqs url received in terraform output as an first argument
# put sns arn received in terraform output as an second argument
aws sqs send-message --queue-url $1 --message-body "Simple text message" 
aws sqs receive-message --queue-url  $1

aws sns publish --topic-arn $2 --message "Hello World"