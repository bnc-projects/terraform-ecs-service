output "target_group_name" {
  value = var.attach_load_balancer ? aws_lb_target_group.target_group[count.index].name : ""
}

output "ecs_service_name" {
  value = var.launch_type == "EC2" ? aws_ecs_service.ec2_service[count.index].id : aws_ecs_service.fargate_service[count.index].id
}