output "target_group_name" {
  index = 0
  value = var.attach_load_balancer ? aws_lb_target_group.target_group[index].name : ""
}

output "ecs_service_name" {
  index = 0
  value = var.launch_type == "EC2" ? aws_ecs_service.ec2_service[index].id : aws_ecs_service.fargate_service[index].id
}