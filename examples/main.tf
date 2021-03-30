terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "[REGION]"
}

module "aws_mongodb_self_healing" {
  source = "./modules/aws-mongodb-self-healing"

  key_name                    = "[AWS_KEYPAIR_NAME_TO_USE_FOR_SSH_LOGIN]"
  subnet_id                   = "[AWS_SUBNET_ID_WHERE_THE_INSTANCE_IS_CREATED]"
  instance_type               = "t2.micro"
  instance_tags               = { Name = "MongoDB Instance" }
  associate_public_ip_address = true
  autoscalling_group_name     = "MongoDB ASG"
  load_balancer_name          = "mongodb-lb"

  ebs_availability_zone = "[AWS_AZ_NAME_WHERE_THE_INSTANCE_IS_CREATED]"
  ebs_volume_size       = 10

  ami = "[AWS_AMI_ID_GENERATED_BY_THE_PACKER]"
}
