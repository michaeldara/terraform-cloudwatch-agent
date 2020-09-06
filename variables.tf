# List of variables this module will receive as input

variable "instance_id" {
  type = string
  default = "test-instance-id"
}

variable "ip_address" {
  type = string
  default = "no ip address"
}

variable "pem_key" {
  type = string
  default = "no pem key"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "user" {
  type = string
  default = "ec2-user"
}


variable "logs_config" {
  type = string
  default = "no awslogs"
}

variable "stage" {
  type = string
  default = "none"
}
