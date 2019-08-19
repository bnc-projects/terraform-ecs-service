output "target_group_name" {
  value = aws_lb_target_group.target_group.name
}

output "ecs_service_name" {
  value = var.launch_type == "EC2" ? aws_ecs_service.ec2_service[0].id : aws_ecs_service.fargate_service[0].id
}

output "ecs_service_execution_role" {
  value = var.launch_type == "EC2" ? aws_iam_role.service[0].arn : aws_iam_role.fargate[0].arn
}
