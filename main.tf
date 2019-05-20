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

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definitions/service.json")}"
  vars {
    container_healthcheck    = "${var.container_healthcheck}"
    container_name           = "${var.service_name}"
    container_port           = "${var.container_port}"
    cpu_reservation          = "${var.cpu_reservation}"
    docker_image_url         = "${var.docker_image}"
    healthcheck_grace_period = "${var.healthcheck_grace_period}"
    java_options             = "${var.java_options}"
    memory_limit             = "${var.memory_limit}"
    memory_reservation       = "${var.memory_reservation}"
    splunk_token             = "${var.splunk_token}"
    splunk_url               = "${var.splunk_url}"
    spring_profile           = "${var.spring_profile}"
  }
}

resource "aws_lb_target_group" "target_group" {
  deregistration_delay = "${var.deregistration_delay}"
  health_check {
    healthy_threshold   = "${var.healthy_threshold}"
    interval            = 10
    matcher             = "200-299"
    path                = "${var.healthcheck_path}"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = "${var.unhealthy_threshold}"
  }
  name                 = "${substr("tg-${var.service_name}", 0, min(length("tg-${var.service_name}"), 32))}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  tags                 = "${var.tags}"
}

resource "aws_lb_listener_rule" "https_listener_rule" {
  count        = "${var.is_exposed_externally ? 1 : 0}"
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = [
      "${var.application_path}/*",
    ]
  }
  listener_arn = "${var.is_exposed_externally ? var.external_lb_listener_arn : var.internal_lb_listener_arn}"
}

resource "aws_iam_role" "service" {
  name               = "${var.service_name}"
  assume_role_policy = "${data.aws_iam_policy_document.service_assume_role.json}"
  tags               = "${var.tags}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "${var.service_role_arn}"
}

resource "aws_ecs_task_definition" "service" {
  container_definitions = "${data.template_file.task_definition.rendered}"
  family                = "${var.service_name}-Task"
  task_role_arn         = "${var.task_role_arn}"
  tags                  = "${var.tags}"
}

resource "aws_ecs_service" "service" {
  name                              = "${var.service_name}"
  cluster                           = "${var.cluster_name}"
  desired_count                     = "${var.desired_count}"
  health_check_grace_period_seconds = "${var.healthcheck_grace_period}"
  iam_role                          = "${aws_iam_role.service.arn}"
  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.container_port}"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
  task_definition                   = "${aws_ecs_task_definition.service.arn}"
  lifecycle {
    ignore_changes = [
      "desired_count"
    ]
  }
}