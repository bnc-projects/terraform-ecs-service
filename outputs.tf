output "target_group_name" {
  value = aws_lb_target_group.target_group.name
}

output "ecs_service_name" {
  value = var.launch_type == "EC2" ? aws_ecs_service.ec2_service.id : aws_ecs_service.fargate_service.id
}