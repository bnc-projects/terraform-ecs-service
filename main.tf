data "aws_iam_policy_document" "service_assume_role" {
  statement {
    sid    = "AllowTravisCIToAssumeTheRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  deregistration_delay = var.deregistration_delay
  health_check {
    healthy_threshold   = var.healthy_threshold
    interval            = 10
    matcher             = "200-299"
    path                = var.healthcheck_path
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = var.unhealthy_threshold
  }
  name                 = substr(format("tg-%s", var.service_name), 0, min(length(format("tg-%s", var.service_name)), 32))
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  tags                 = var.tags
}

resource "aws_lb_listener_rule" "https_listener_rule" {
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  condition {
    field  = "path-pattern"
    values = [
      format("%s/*", var.application_path),
    ]
  }
  listener_arn = var.is_exposed_externally ? var.external_lb_listener_arn : var.internal_lb_listener_arn
}

resource "aws_iam_role" "service" {
  name               = var.service_name
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy" {
  role       = aws_iam_role.service.name
  policy_arn = var.service_role_arn
}

resource "aws_ecs_service" "ec2_service" {
  count                             = var.launch_type == "EC2" ? 1 : 0
  name                              = var.service_name
  cluster                           = var.cluster_name
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.healthcheck_grace_period
  iam_role                          = aws_iam_role.service.arn
  task_definition                   = var.task_definition_arn
  launch_type                       = var.launch_type
  scheduling_strategy               = var.scheduling_strategy
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags
  ordered_placement_strategy        = var.placement_strategy
  placement_constraints             = var.placement_constraints
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      "desired_count"
    ]
  }
}

resource "aws_ecs_service" "fargate_service" {
  count                             = var.launch_type == "FARGATE" ? 1 : 0
  name                              = var.service_name
  cluster                           = var.cluster_name
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.healthcheck_grace_period
  iam_role                          = aws_iam_role.service.arn
  task_definition                   = var.task_definition_arn
  platform_version                  = var.platform_version
  launch_type                       = var.launch_type
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags
  ordered_placement_strategy        = var.placement_strategy
  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      "desired_count"
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "http_target_5xx_alarm" {
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s HTTP 500 response code alarm", var.service_name)
  alarm_name          = format("%s-HTTP-5XX-Alarm", var.service_name)
  comparison_operator = "GreaterThanThreshold"
  dimensions          = {
    LoadBalancer = var.is_exposed_externally ? var.external_lb_name : var.internal_lb_name
    TargetGroup  = aws_lb_target_group.target_group.arn_suffix
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
  alarm_actions       = var.alarm_actions
  alarm_description   = format("%s service has no healthy instances", var.service_name)
  alarm_name          = format("%s-not-healthy", var.service_name)
  comparison_operator = "LessThanThreshold"
  dimensions          = {
    LoadBalancer = var.is_exposed_externally ? var.external_lb_name : var.internal_lb_name
    TargetGroup  = aws_lb_target_group.target_group.arn_suffix
  }
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Minimum"
  tags                = var.tags
  threshold           = 0
  treat_missing_data  = "breaching"
}