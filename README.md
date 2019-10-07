# terraform-ecs-service

**This module currently only supports deploying a single task per service.**

Terraform module which creates a ECS service to be deployed Fargate or EC2.

## Examples

### EC2 Service using a Application Load Balancer
```
module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  application_path         = "/v1/service" 
  attach_load_balancer     = true
  cluster_name             = "ecs-cluster-name"
  external_lb_listener_arn = ""
  external_lb_name         = ""
  internal_lb_listener_arn = "arn:aws:elasticloadbalancing:region:account-id:listener/app/intlb"
  internal_lb_name         = "intlb"
  is_exposed_externally    = false
  priority                 = 1
  service_name             = var.service_name
  task_definition_arn      = aws_ecs_task_definition.bar.arn
  vpc_id                   = "vpc-124552462"
  tags                     = merge(local.common_tags, var.tags)
}
```

### EC2 Service without a Application Load Balancer
```
module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  cluster_name             = "ecs-cluster-name"
  service_name             = var.service_name
  task_definition_arn      = aws_ecs_task_definition.bar.arn
  vpc_id                   = "vpc-124552462"
  tags                     = merge(local.common_tags, var.tags)
}
```

### Fargate Service using a Application Load Balancer
```
module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  assign_public_ip         = true
  application_path         = "/v1/service" 
  attach_load_balancer     = true
  cluster_name             = "ecs-cluster-name"
  external_lb_listener_arn = "arn:aws:elasticloadbalancing:region:account-id:listener/app/extlb"
  external_lb_name         = "extlb"
  internal_lb_listener_arn = ""
  internal_lb_name         = ""
  is_exposed_externally    = true
  launch_type              = "FARGATE"
  priority                 = 5
  security_groups          = var.security_groups.*.id
  service_name             = var.service_name
  subnets                  = var.subnets.*.id
  task_definition_arn      = aws_ecs_task_definition.bar.arn
  vpc_id                   = "vpc-124552462"
  tags                     = merge(local.common_tags, var.tags)
}
```
### Fargate Service without a Application Load Balancer
```
module "ecs_service" {
  source              = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=fargate"
  assign_public_ip    = true
  cluster_arn         = data.terraform_remote_state.btse_cluster.outputs.ecs_cluster_id
  desired_count       = "1"
  launch_type         = "FARGATE"
  security_groups     = var.security_groups.*.id
  service_name        = var.service_name
  subnets             = var.subnets.*.id
  task_definition_arn = aws_ecs_task_definition.bar.arn
  vpc_id              = "vpc-124552462"
  tags                = merge(local.common_tags, var.tags)
}
```

### Fargate External Service
```
module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  assign_public_ip         = true
  application_path         = "/v1/service" 
  attach_load_balancer     = true
  cluster_name             = "ecs-cluster-name"
  external_lb_listener_arn = "arn:aws:elasticloadbalancing:region:account-id:listener/app/extlb"
  external_lb_name         = "extlb"
  internal_lb_listener_arn = ""
  internal_lb_name         = ""
  is_exposed_externally    = true
  launch_type              = "FARGATE"
  priority                 = 5
  security_groups          = var.security_groups.*.id
  service_name             = var.service_name
  subnets                  = var.subnets.*.id
  task_definition_arn      = aws_ecs_task_definition.bar.arn
  vpc_id                   = "vpc-124552462"
  tags                     = merge(local.common_tags, var.tags)
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_actions | The list of actions to execute when this alarm transitions into an ALARM state from any other state | list(string) | `[]` | no |
| assign_public_ip | Assign a public IP address to the ENI. Required for Fargate services | boolean | `false` | no |
| application_path | The path which the load balancer will route to. /* will be appended | string | - | no |
| attach_load_balancer | Set to true if load balancers will be attached | boolean | `false` | no |
| cluster | The short name or ARN of the ECS cluster where the service will be deployed | string | - | yes |
| container_port | The port number which the application is listening to inside the container | number | `8080` | no |
| cpu_utilization_alarm_threshold | The threshold of service cpu utilization | number | `75` | no |
| desired_count | The desired amount of services running at any given time | number | `2` | no |
| deregistration_delay | The number of seconds the load balancer waits before setting the service to unused from draining | number | `30` | no |
| enable_ecs_managed_tags | Specifies whether to enable Amazon ECS managed tags for the tasks within the service | boolean | `false` | no |
| external_lb_listener_arn | The external load balancers ARN | string | `-` | no |
| external_lb_name | The friendly name of the external load balancer | string | `-` | no |
| healthcheck_grace_period | The grace period to give the healthchecks | number | `300` | no |
| healthcheck_path | The path which will be used for healthchecks | number | `/actuator/health` | no |
| healthy_threshold | The number of healthchecks until a service is deemed healthy | number | `2` |
| internal_lb_listener_arn | The internal load balancers ARN | string | `-` | no |
| internal_lb_name | The friendly name of the internal load balancer | string | `-` | no |
| is_exposed_externally | Determines if the service will be attached to the external load balancer | boolean | `false` | no |
| launch_type | The launch type on which to run your service | string | `EC2` | no |
| memory_utilization_alarm_threshold | The threshold of service memory utilization | number | `90` | no | 
| placement_constraints | The rules that are taken into consideration during task placement | list(map(object({type  = string expression = string}))) | `[]` | no |
| placement_strategy | Service level strategy rules that are taken into consideration during task placement | list(map(object({type  = string field = string}))) | `[ { type  = "spread" field = "attribute:ecs.availability-zone" }, {type  = "binpack" field = "memory"}]` | no |
| platform_version | The platform version on which to run your service | string | `LATEST` | no |
| priority | The priority of the target group in the load balancer | number | `1` | no |
| propagate_tags | Specifies whether to propagate the tags from the task definition or the service to the tasks | string | `TASK_DEFINITION` | no |
| scheduling_strategy | The scheduling strategy to use for the service | string | `REPLICA` | no |
| security_groups | The security groups associated with the task or service. Required for Fargate services | list(string) | `[]` | no |
| service_name | The name of the service | `-` | yes |
| service_role_policy_arn | The ARN of the IAM role which will be attached at the service level | `arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole` | no |
| subnets | The subnets associated with the task or service | list(string) | `[]` | no |
| tags | A map of tags to add to the appropriate resources | map(string) | `<map>` | no |
| task_definition_arn | The full ARN of the task definition that you want to run in your service | string | `-` | yes |
| unhealthy_threshold | The number of healthchecks until a service is deemed unhealthy | number | `3` | no |
| vpc_id | The VPC ID which the load balancer listener(s) will be part of | string | `-` | yes |

## Outputs

| Name | Description |
|------|-------------|
| target_group_name | The name of the target group |
| ecs_service_name | The id of the service |