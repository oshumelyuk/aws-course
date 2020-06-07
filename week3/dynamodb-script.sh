aws dynamodb list-tables > output.txt
aws dynamodb put-item \
    --table-name AwsCourse \
    --item '{"week": {"N": "1"}, "title": {"S": "Intoduction"}}' 

aws dynamodb put-item \
    --table-name AwsCourse \
    --item '{"week": {"N": "2"}, "title": {"S": "Compute services: EC2, Auto Scaling, Security Groups"}}' 

aws dynamodb put-item \
    --table-name AwsCourse \
    --item '{"week": {"N": "3"}, "title": {"S": "Storage: Simple Storage Service (S3), Terraform"}}' 

aws dynamodb put-item \
    --table-name AwsCourse \
    --item '{"week": {"N": "4"}, "title": {"S": "Databases: RDS, Dynamo DB"}}' 

aws dynamodb scan --table-name AwsCourse > output-dynamotable.txt

#aws dynamodb query --table-name AwsCourse \
#    --key-condition-expression "week = :weeknum" \
#    --expression-attribute-values  '{":weeknum":{"N":"3"}}' > output-dynamotable.txt