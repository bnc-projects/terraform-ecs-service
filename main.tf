resource "aws_lb_target_group" "target_group" {
  count = var.attach_load_balancer ? 1 : 0
  deregistration_delay = var.deregistration_delay
  health_check {
    healthy_threshold = var.healthy_threshold
    interval = 30
    matcher = "200-299"
    path = var.healthcheck_path
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = var.unhealthy_threshold
  }
  name = substr(format("tg-%s", var.service_name), 0, min(length(format("tg-%s", var.service_name)), 32))
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  tags = var.tags
  target_type = var.launch_type == "EC2" ? "instance" : "ip"
}

resource "aws_lb_listener_rule" "https_listener_rule" {
  target_group_index = 0
  count = var.attach_load_balancer ? 1 : 0
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group[target_group_index].arn
  }
  condition {
    path_pattern {
      values = [
        format("%s/*", var.application_path),
      ]
    }
  }
  priority = var.priority
  listener_arn = var.is_exposed_externally ? var.external_lb_listener_arn : var.internal_lb_listener_arn
}

resource "aws_ecs_service" "ec2_service" {
  target_group_index = 0
  count = var.launch_type == "EC2" ? 1 : 0
  name = var.service_name
  cluster = var.cluster
  desired_count = var.desired_count
  health_check_grace_period_seconds = var.attach_load_balancer ? var.healthcheck_grace_period : null
  iam_role = var.attach_load_balancer ? aws_iam_role.service[target_group_index].arn : null
  task_definition = var.task_definition_arn
  launch_type = var.launch_type
  scheduling_strategy = var.scheduling_strategy
  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  propagate_tags = var.propagate_tags

  dynamic "ordered_placement_strategy" {
    for_each = var.placement_strategy
    iterator = placement_strategy
    content {
      type = placement_strategy.value.type
      field = placement_strategy.value.field
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    iterator = placement_constraints
    content {
      type = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "load_balancer" {
    target_group_index = 0
    for_each = var.attach_load_balancer ? list(var.attach_load_balancer) : []

    content {
      target_group_arn = aws_lb_target_group.target_group[target_group_index].arn
      container_name = var.service_name
      container_port = var.container_port
    }
  }

  lifecycle {
    ignore_changes = [
      "desired_count"
    ]
  }

  tags = var.tags
}

resource "aws_ecs_service" "fargate_service" {
  target_group_index = 0
  count = var.launch_type == "FARGATE" ? 1 : 0
  name = var.service_name
  cluster = var.cluster
  desired_count = var.desired_count
  health_check_grace_period_seconds = var.attach_load_balancer ? var.healthcheck_grace_period : null
  task_definition = var.task_definition_arn
  platform_version = var.platform_version
  launch_type = var.launch_type
  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  propagate_tags = var.propagate_tags

  network_configuration {
    subnets = var.subnets
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.attach_load_balancer ? list(var.attach_load_balancer) : []

    content {
      target_group_arn = aws_lb_target_group.target_group[target_group_index].arn
      container_name = var.service_name
      container_port = var.container_port
    }
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  tags = var.tags
}