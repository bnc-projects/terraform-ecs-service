# terraform-ecs-service

**This module currently only supports deploying a single task per service.**

Terraform module which creates a ECS service to be deployed on the specified cluster.  

## Examples

### Internal Service
```
data "aws_iam_role" "task" {
  name = "${var.service_name}_task"
}

module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  application_path         = "/v1/service" 
  cluster_name             = "ecs-cluster-name"
  docker_image             = "bncprojects/${var.service_name}:${var.service_version}"
  external_lb_listener_arn = ""
  internal_lb_listener_arn = "arn:aws:elasticloadbalancing:region:account-id:listener/app/intlb"
  java_options             = "-javaagent:newrelic/newrelic.jar -Dnewrelic.environment=${terraform.workspace} -Dnewrelic.config.file=newrelic/newrelic.yml"
  is_exposed_externally    = false
  priority                 = 1
  service_name             = "${var.service_name}
  splunk_token             = "${var.splunk_token}
  splunk_url               = "${var.splunk_url}
  spring_profile           = "default,${terraform.workspace}"
  task_role_arn            = "${aws_iam_role.task.arn}"
  vpc_id                   = "vpc-124552462"
  tags                     = "${merge(local.common_tags, var.tags)}"
}
```

### External Service
```
data "aws_iam_role" "task" {
  name = "${var.service_name}_task"
}

module "ecs_service" {
  source                   = "git::https://github.com/bnc-projects/terraform-ecs-service.git?ref=1.0.0"
  application_path         = "/v1/service" 
  cluster_name             = "ecs-cluster-name"
  docker_image             = "bncprojects/${var.service_name}:${var.service_version}"
  external_lb_listener_arn = "arn:aws:elasticloadbalancing:region:account-id:listener/app/intlb"
  internal_lb_listener_arn = ""
  java_options             = "-javaagent:newrelic/newrelic.jar -Dnewrelic.environment=${terraform.workspace} -Dnewrelic.config.file=newrelic/newrelic.yml"
  is_exposed_externally    = true
  priority                 = 5
  service_name             = "${var.service_name}
  splunk_token             = "${var.splunk_token}
  splunk_url               = "${var.splunk_url}
  spring_profile           = "default,${terraform.workspace}"
  task_role_arn            = "${aws_iam_role.task.arn}"
  vpc_id                   = "vpc-124552462"
  tags                     = "${merge(local.common_tags, var.tags)}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application_path | The path which the load balancer will route to. /* will be appended | string | - | yes |
| cluster_name | The name of the ECS cluster to deploy the service too | string | - | yes |
| container_healthcheck | The command which will be used for the health checks inside the container | string | `wget --quiet --tries=1 --spider --timeout=30 http://localhost:8080/actuator/health || exit 1` | no |
| container_port | The port number which the application is listening to inside the container | number | `8080` | no |
| cpu_reservation | The amount of CPU to reserve on the cluster for the task | number | `128` | no |
| desired_count | The desired amount of services running at any given time | number | `2` | no |
| deregistration_delay | The number of seconds the load balancer waits before setting the service to unused from draining | number | `30` | no |
| docker_image | The docker image to be used for the task definition | string | `-` | yes |
| external_lb_listener_arn | The external load balancers ARN | string | `-` | yes |
| healthcheck_grace_period | The grace period to give the healthchecks | number | `300` | no |
| healthcheck_path | The path which will be used for healthchecks | number | `/actuator/health` | no |
| healthy_threshold | The number of healthchecks until a service is deemed healthy | number | `2` |
| internal_lb_listener_arn | The internal load balancers ARN | string | `-` | yes |
| java_options | The Java Options environment variables to apply in the container | string | `` | no |
| is_exposed_externally | Determines if the service will be attached to the external load balancer | boolean | `false` | no |
| memory_limit | The hard memory limit for the task | number | `512` | no |
| memory_reservation | The amount of memory to reserve for the task | `512` | no | 
| priority | The priority of the target group in the load balancer | `1` | no |
| service_name | The name of the service | `-` | yes |
| service_role_arn | The ARN of the IAM role which will be attached at the service level | `arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole` | no |
| splunk_token | The Splunk token for the HTTP Event Collector | `-` | yes |
| splunk_url | The Splunk URL for the HTTP Event Collector | `-` | yes |
| spring_profile | The spring profile(s) which will be enabled in the application | `-` | no |
| tags | A map of tags to add to the appropriate resources | map | `<map>` | no |
| task_role_arn | The ARN of the IAM role which will be attached at the task definition level | string | `-` | no |
| unhealthy_threshold | The number of healthchecks until a service is deemed unhealthy | number | `3` | no |
| vpc_id | The VPC ID which the load balancer listener(s) will be part of | string | `-` | yes |

## Outputs

| Name | Description |
|------|-------------|
| target_group_name | The name of the target group |
| ecs_service_name | The id of the service |