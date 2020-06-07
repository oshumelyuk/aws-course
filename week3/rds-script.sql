CREATE TABLE lectures(id integer PRIMARY KEY, title varchar(250));
INSERT INTO lectures (id, title) VALUES(1, 'Introduction');
INSERT INTO lectures (id, title) VALUES(2, 'Compute services: EC2, Auto Scaling, Security Groups');
INSERT INTO lectures (id, title) VALUES(3, 'Storage: Simple Storage Service (S3), Terraform');
INSERT INTO lectures (id, title) VALUES(4, 'Databases: RDS, Dynamo DB');
INSERT INTO lectures (id, title) VALUES(5, 'Networking: VPC, ELB');
INSERT INTO lectures (id, title) VALUES(6, 'Application Integration: SQS, SNS');
INSERT INTO lectures (id, title) VALUES(7, 'Week 6-8 – Final Task');

SELECT * FROM lectures;
