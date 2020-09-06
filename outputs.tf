# This file contains outputs of the module

output "instance_id" {
  value = var.instance_id
}


output "ip_address" {
  value = var.ip_address
}

output "region" {
  value = var.region
}

output "user" {
  value = var.user
}

output "stage" {
  value = var.stage
}

output "pem_key" {
  value = var.pem_key
}

output "logs_config" {
  value = var.logs_config
}

output "sns_topic_arn" {
  value = "${aws_sns_topic.metric_alarm_topic.arn}"
}
