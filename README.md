# aws-course

# Week 0 –  preliminary

Tasks:

-	Create AWS account, use US West Oregon (US_WEST_2) region
-	Setup MFA for AWS account
-	Get familiar with common AWS services (see Services to learn)
-	Setup billing alert using Cloud Watch (via AWS Console in UI)

Week 0 output:

-	AWS account created, and all account checks are green (Fig. 1)
-	Cloud Watch billing alert configured and enabled (Fig. 2)


# Week 1 – Compute services: EC2, Auto Scaling, Security Groups

Tasks:

-	Create Cloud Formation script which will deploy next infrastructure:
  -	Auto-scaling group (ASG) with two EC2 instances within it
  -	SSH and HTTP access to EC2 instances (you could use Security Groups for this)
-	Optionаal: add the ability for EC2 instances to install Java 8 during startup (you can use the UserData section for this)
-	Log into EC2 instances via SSH and manually install Java 8 on it

Week 1 output:

-	CloudFormation script which will create all described infrastructure
-	When the CF stack is up and running – go to the EC2 dashboard and terminate one of the instances. After some time after termination, a new EC2 instance should be launched automatically (since EC2 instances were created within ASG)


# Week 2 – Storage: Simple Storage Service (S3), Terraform

Tasks:

-	Create an init-s3.sh script which will do the next things:
  -	Create a simple small text file
  -	Create AWS S3 bucket
  -	Add versioning to S3 bucket
  -	Upload file to S3
-	Verify that uploaded file is not publicly available (you could not rich it from your working machine)
-	Create a Cloud Formation script which will deploy the next infrastructure:
  -	EC2 instance, which will have access to S3 service (you could use Policies and Roles for this). Implement file downloading from S3 during instance startup (you can use the UserData section for this)
  -	SSH access to the EC2 instance (you could use Security Group for this)
-	Log in to create EC2 instance and check that downloaded file is there
-	Create a Terraform script that will create an infrastructure from Week 1 and Week 2

Week 2 output:

- init-s3.sh script which will create S3 bucket, enabled versioning and upload some file to S3
-	Verify that uploaded file is not accessible from your machine
-	CloudFormation script which will create all described infrastructure
-	Terraform scripts which will create an infrastructure from Week-1 and Week-2
-	When the infrastructure is up and running – use SSH to connect to a created EC2 instance and check that the file from S3 is there


# Week 3 – Databases: RDS, Dynamo DB

Tasks:

-	Create a simple SQL script rds-script.sql which will describe next things:
  -	Database creation
  -	Creation of one simple table for tests
  -	Adding some dummy data to the table
  -	A simple select statement which will return all entries from the table
-	Create a simple dynamodb-script.sh which will do the next things:
  -	Display existing Dynamo DB tables
  -	Add a few entries in the table
  -	Read entries from the table 
-	Create a init-s3.sh script which will do the next things:
  -	Create AWS S3 bucket
  -	Upload the rds-script.sql and the dynamodb-script.sh to an S3 bucket
-	Create a Terraform script which will create the next infrastructure:
  -	One Dynamo DB table
  -	One RDS database (postgres or mysql for example)
  -	Create an EC2 instance with all needful access permissions (to S3, DynamoDB and RDS)
  -	All scripts from S3 should be copied to the instance during startup
  -	Add access permissions for HTTP, SSH, and to selected RDS database
  -	An RDS endpoint and port should be available in the script output
-	SSH to a created EC2 instance and execute both scripts in order to test your solution

Week 3 output:

-	rds-script.sql – a simple SQL script for creating a RDS database, table with dummy data with a simple select statement 
-	dynamodb-script.sh – a simple AWS commands to add data into the DynamoDB 
-	init.sh – create an S3 bucket and copy there two scripts above 
-	A Terraform script which will generate all described infrastructure
-	When CF stack is up and running – SSH to the created EC2 instance and run checks (scripts which are already available on EC2) for RDS and Dynamo DB


# Week 4 – Networking: VPC, ELB

Tasks (all flow is explained in corresponding presentation AWS-VPC.pptx):

-	Create a Terraform script which will create the next infrastructure:
  -	Virtual Public Cloud (VPC) with two subnets private and public, each with one EC2 instance with Apache Web server installed and with simple index.html
  -	NAT EC2 instance which will give HTTP access for the private subnet
  -	Application Load Balancer targeting to both private and public subnets
-	Use load balancer TTTP URL to check your solution - load balancer should return as a response these pages per extern HTTP-request. So you have to see pages from both servers

Week 4 output:

-	A Terraform script which will generate all described infrastructure
-	When the stack is up and running – copy load balancer URL from the script output and paste into the browser (or curl command) – you should see pages from both servers randomly 

