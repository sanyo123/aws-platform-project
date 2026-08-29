# ============================================================
# SNS TOPIC FOR CLOUDWATCH ALARMS
# ============================================================

resource "aws_sns_topic" "day3_alerts" {
  provider = aws.development

  name = "day3-workload-alerts"

  tags = {
    Name = "day3-workload-alerts"
  }
}


# ============================================================
# CLOUDWATCH CPU ALARM
# ============================================================

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  provider = aws.development

  alarm_name        = "day3-workload-high-cpu"
  alarm_description = "Alarm when Day 3 workload CPU exceeds 70 percent"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  statistic = "Average"

  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 70
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.workload.id
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.day3_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.day3_alerts.arn
  ]

  tags = {
    Name = "day3-workload-high-cpu"
  }
}