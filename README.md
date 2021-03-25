# Overview

This a terraform module + image used to deploy a fault tolerant single node mongodb instance in AWS EC2. It creates an autoscalling group with a single member that has an EBS volume attached to it. In case of error due to EC2 the instance gets terminated and the autoscaller ensures it creates another instance with the same image having the same EBS volume attach to it. This results in self healing mongodb single node configuration.

# Usage

1. Copy `./examples/main.tf` to `./main.tf` and modify it to your use case.

2. Build the AMI with `mongodb 3.6` and `awscli` installed 

`packer build -var 'region=[REGION]' -var 'subnet_id=[SUBNET_ID]' ./images/aws-mongodb-self-healing/image.pkr.hcl`

3. Modify your `./main.tf` to include the proper `AMI` id generated from `Packer`

4. Initialize the terraform play

`terraform init`

5. Apply the terraform play

`terraform apply`

6. Log in to your mongodb instance and execute

`mongo test --eval 'db.x.insertOne({x: 1})'`

7. Terminate forcefully your instance to validate the autoscalling group is working

`aws autoscaling terminate-instance-in-auto-scaling-group --instance-id [INSTANCE_ID] --no-should-decrement-desired-capacity`

8. Log to the newly created instance and execute

`mongo test --eval 'db.x.findOne()'`

The output should be `{ "_id" : ObjectId("..."), "x" : 1 }`
