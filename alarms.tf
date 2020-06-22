resource "aws_cloudwatch_metric_alarm" "http_target_5xx_alarm" {
  count               = var.attach_load_balancer ? 1 : 0
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s HTTP 500 response code alarm", var.service_name)
  alarm_name          = format("%s-HTTP-5XX-Alarm", var.service_name)
  comparison_operator = "GreaterThanThreshold"
  dimensions          = {
    LoadBalancer = var.is_exposed_externally ? var.external_lb_name : var.internal_lb_name
    TargetGroup  = aws_lb_target_group.target_group[count.index].arn_suffix
  }
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  tags                = var.tags
  threshold           = 0
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "service_not_healthy_alarm" {
  count               = var.attach_load_balancer ? 1 : 0
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s service is below desired running count", var.service_name)
  alarm_name          = format("%s-not-healthy", var.service_name)
  comparison_operator = "LessThanThreshold"
  dimensions          = {
    LoadBalancer = var.is_exposed_externally ? var.external_lb_name : var.internal_lb_name
    TargetGroup  = aws_lb_target_group.target_group[count.index].arn_suffix
  }
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Minimum"
  tags                = var.tags
  threshold           = var.desired_count
  treat_missing_data  = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "service_not_healthy_alarm_no_lb" {
  count               = var.attach_load_balancer ? 0 : 1
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s service is below desired running count", var.service_name)
  alarm_name          = format("%s-not-healthy", var.service_name)
  comparison_operator = "LessThanThreshold"
  dimensions          = {
    ServiceName = var.service_name
    ClusterName = var.cluster
  }
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "SampleCount"
  tags                = var.tags
  threshold           = var.desired_count
  treat_missing_data  = "breaching"
}


resource "aws_cloudwatch_metric_alarm" "service_cpu_utilization_alarm" {
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s service cpu utilization is greater than %s percent of reserved cpu", var.service_name, var.cpu_utilization_alarm_threshold)
  alarm_name          = format("%s-cpu-utilization-alarm", var.service_name)
  comparison_operator = "GreaterThanThreshold"
  dimensions          = {
    ServiceName = var.service_name
    ClusterName = var.cluster
  }
  evaluation_periods  = var.cpu_utilization_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = var.cpu_utilization_alarm_statistic
  tags                = var.tags
  threshold           = var.cpu_utilization_alarm_threshold
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "service_memory_utilization_alarm" {
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s service memory utilization is greater than %s percent of reserved cpu", var.service_name, var.memory_utilization_alarm_threshold)
  alarm_name          = format("%s-memory-utilization-alarm", var.service_name)
  comparison_operator = "GreaterThanThreshold"
  dimensions          = {
    ServiceName = var.service_name
    ClusterName = var.cluster
  }
  evaluation_periods  = var.memory_utilization_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = var.memory_utilization_alarm_statistic
  tags                = var.tags
  threshold           = var.memory_utilization_alarm_threshold
  treat_missing_data  = "breaching"
}