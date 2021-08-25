output "target_group_name" {
  value = var.attach_load_balancer ? join("", aws_lb_target_group.target_group[*].name) : ""
}

output "ecs_service_name" {
  value = var.launch_type == "EC2" ? join("", aws_ecs_service.ec2_service[*].id) : join("", aws_ecs_service.fargate_service[*].id)
}