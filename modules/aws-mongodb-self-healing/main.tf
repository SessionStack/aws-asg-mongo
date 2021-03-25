data "aws_caller_identity" "current" {}

locals {
  autoscalling_group_name = "tf-asg-${replace(timestamp(), "/[- TZ:]/", "")}"
}

resource "aws_ebs_volume" "mongodb_data_storage" {
  availability_zone = var.ebs_availability_zone
  size              = var.ebs_volume_size
}

resource "aws_iam_role" "mongodb_storage_iam_role" {
  name = "MongoDBRoleStorageEBSAttachDetach"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "MongoDBStorageEBSAttachDetachPolicy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "MongoDBStorageEBSAttachDetach",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DetachVolume",
            "ec2:AttachVolume",
            "autoscaling:CompleteLifecycleAction"
          ],
          "Resource" : [
            "arn:aws:ec2:*:${data.aws_caller_identity.current.id}:instance/*",
            aws_ebs_volume.mongodb_data_storage.arn,
            "arn:aws:autoscaling:*:${data.aws_caller_identity.current.id}:autoScalingGroup:*:autoScalingGroupName/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "mongodb_storage_iam_instance_profile" {
  role = aws_iam_role.mongodb_storage_iam_role.name
}

resource "aws_launch_template" "mongodb_launch_template" {
  name          = "mongodb_fault_tolerant_launch_template"
  instance_type = var.instance_type
  key_name      = var.key_name
  image_id      = var.ami

  iam_instance_profile {
    arn = aws_iam_instance_profile.mongodb_storage_iam_instance_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  user_data = base64encode(
    templatefile("${path.module}/on_startup.sh.tmpl", {
      volume_id               = aws_ebs_volume.mongodb_data_storage.id
      autoscalling_group_name = local.autoscalling_group_name
    })
  )
}

resource "aws_autoscaling_group" "mongodb_asg" {
  name                = local.autoscalling_group_name
  vpc_zone_identifier = [var.subnet_id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.mongodb_launch_template.id
    version = aws_launch_template.mongodb_launch_template.latest_version
  }

  initial_lifecycle_hook {
    name                 = "attach-storage-volume-and-launch"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 0
    }
  }
}
