output "target_group_name" {
  value = var.attach_load_balancer ? aws_lb_target_group.target_group.name : ""
}

output "ecs_service_name" {
  value = aws_ecs_service.ec2_service.id
}
