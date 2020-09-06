# This file contains code to provision alarms and notifications.

#create alar for cpu spike
resource "aws_cloudwatch_metric_alarm" "cpu_spike" {
  alarm_name                = "${var.instance_id}-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_sns_topic.metric_alarm_topic.arn}"]
  insufficient_data_actions = []

  depends_on = [
        null_resource.install_agent,
        aws_sns_topic.metric_alarm_topic
  ]
}

# Create alarm for memory spike
resource "aws_cloudwatch_metric_alarm" "mem_spike" {
  alarm_name                = "${var.instance_id}-mem-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "mem_used_percentage"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 memory utilization"
  alarm_actions     = ["${aws_sns_topic.metric_alarm_topic.arn}"]
  insufficient_data_actions = []

  depends_on = [
        null_resource.install_agent,
        aws_sns_topic.metric_alarm_topic
  ]
}

# Create sns topic to publish the cpu and memory notifications
resource "aws_sns_topic" "metric_alarm_topic" {
  name = "metric_alarm_topic"
  delivery_policy = <<JSON
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget"    : 20,
      "maxDelayTarget"    : 600,
      "numRetries"        : 5,
      "backoffFunction"   : "exponential"
    },
    "disableSubscriptionOverrides": false
  }
}
JSON
}
