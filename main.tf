resource "aws_lb_target_group" "target_group" {
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
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = [
        "${var.application_path}/*",
      ]
    }
  }
  priority = var.priority
  listener_arn = var.is_exposed_externally ? var.external_lb_listener_arn : var.internal_lb_listener_arn
}

resource "aws_ecs_service" "ec2_service" {
  name = var.service_name
  cluster = var.cluster
  desired_count = var.desired_count
  health_check_grace_period_seconds = var.attach_load_balancer ? var.healthcheck_grace_period : null
  iam_role = var.attach_load_balancer ? aws_iam_role.service.arn : null
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
    for_each = var.attach_load_balancer ? list(var.attach_load_balancer) : []

    content {
      target_group_arn = aws_lb_target_group.target_group.arn
      container_name = var.service_name
      container_port = var.container_port
    }
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
    create_before_destroy=true
  }

  tags = var.tags
}
