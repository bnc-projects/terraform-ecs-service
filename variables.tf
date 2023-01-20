variable "alarm_actions" {
  default     = []
  description = "The list of ARNs which will be triggered when the alarms trigger"
  type        = list(string)
}

variable "assign_public_ip" {
  default     = false
  description = "Assign a public IP address to the ENI"
  type        = bool
}

variable "application_path" {
  default     = null
  description = "The path that the service will listen to requests on"
  type        = string
}

variable "host_header" {
  default     = null
  description = "The host that the servie will listen to"
  type        = string
}

variable "attach_load_balancer" {
  default     = false
  description = "Set to true if load balancers will be attached"
  type        = bool
}

variable "cluster" {
  description = "The short name or ARN of the cluster where the service will be launched"
  type        = string
}

variable "container_port" {
  default     = 8080
  description = "The port number which the application is listening to inside the container"
  type        = number
}

variable "cpu_utilization_alarm_statistic" {
  default     = "Average"
  description = "The statistic of service cpu utilization"
  type        = string
}

variable "cpu_utilization_alarm_threshold" {
  default     = 75
  description = "The threshold of service cpu utilization"
  type        = number
}

variable "cpu_utilization_evaluation_periods" {
  default     = 5
  description = "The evaluation periods of service cpu utilization alarm"
  type        = number
}

variable "desired_count" {
  default     = 2
  description = "The desired amount of services running at any given time"
  type        = number
}

variable "deregistration_delay" {
  default     = 30
  description = "The number of seconds the load balancer waits before setting the service to unused from draining"
  type        = number
}

variable "enable_ecs_managed_tags" {
  default     = false
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
}

variable "external_lb_listener_arn" {
  default     = null
  description = "The external load balancers ARN"
  type        = string
}

variable "external_lb_name" {
  default     = null
  description = "The external load balancer name"
  type        = string
}

variable "healthcheck_grace_period" {
  default     = 300
  description = "The grace period to give the ECS service healthchecks"
  type        = number
}

variable "healthcheck_path" {
  default     = "/actuator/health"
  description = "The healthcheck path"
  type        = string
}

variable "healthy_threshold" {
  default     = 2
  description = "The number of healthchecks until a service is deemed healthy"
  type        = number
}

variable "internal_lb_listener_arn" {
  default     = null
  description = "The internal load balancers ARN"
  type        = string
}

variable "internal_lb_name" {
  default     = null
  description = "The internal load balancer name"
  type        = string
}

variable "is_exposed_externally" {
  default     = null
  description = "Determines if the service will be attached to the external load balancer"
  type        = bool
}

variable "launch_type" {
  default     = "EC2"
  description = "The launch type on which to run your service"
  type        = string
}

variable "memory_utilization_alarm_statistic" {
  default     = "Average"
  description = "The statistic of service memory utilization"
  type        = string
}

variable "memory_utilization_alarm_threshold" {
  default     = 90
  description = "The threshold of service memory utilization"
  type        = number
}

variable "memory_utilization_evaluation_periods" {
  default     = 5
  description = "The evaluation periods of service memory utilization alarm"
  type        = number
}

variable "placement_constraints" {
  default     = []
  description = "The rules that are taken into consideration during task placement"
  type        = list(object({
    type       = string
    expression = string
  }))
}

variable "placement_strategy" {
  default     = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]
  description = "The orded placement strategy which should be followed by the service"
  type        = list(object({
    type  = string
    field = string
  }))
}

variable "platform_version" {
  default     = "LATEST"
  description = "The platform version on which to run your service"
}

variable "priority" {
  default     = null
  description = "The priority of the application path matching"
  type        = number
}

variable "propagate_tags" {
  default     = "TASK_DEFINITION"
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks"
  type        = string
}

variable "scheduling_strategy" {
  default     = "REPLICA"
  description = "The scheduling strategy to use for the service"
  type        = string
}

variable "security_groups" {
  default     = []
  description = "The security groups associated with the task or service"
  type        = list(string)
}

variable "service_name" {
  description = "The name of the service which will be deployed"
  type        = string
}

variable "service_role_policy_arn" {
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  description = "The ARN of the IAM policy which will be attached at the service level"
  type        = string
}

variable "subnets" {
  default     = []
  description = "The subnets associated with the task or service"
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "The map of tags to be set on resources"
  type        = map(string)
}

variable "task_definition_arn" {
  description = "The ARN the task definition level"
  type        = string
}

variable "unhealthy_threshold" {
  default     = 3
  description = "The number of healthchecks until a service is deemed unhealthy"
  type        = number
}

variable "vpc_id" {
  description = "The VPC ID which the load balancer listener(s) will be part of"
  type        = string
}
