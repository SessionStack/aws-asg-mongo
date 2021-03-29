variable "instance_type" {
  description = "Instance type used to create the MongoDB server"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Flag indicating whether the MongoDB server has a public ip address"
  type        = bool
  default     = false
}

variable "ami" {
  description = "AMI ID used as a base to create new mongodb images"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where we want to host the instance"
  type        = string
}

variable "key_name" {
  description = "Name of keypair that will be used for logging into instance"
  type        = string
}

variable "ebs_availability_zone" {
  description = "Availablity zone name where the EBS used for data is stored"
  type        = string
}

variable "ebs_volume_size" {
  description = "Size of EBS used for data"
  type        = number
}
