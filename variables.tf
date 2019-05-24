variable "alarm_actions" {
  description = "The list of ARNs which will be triggered when the alarms trigger"
  type        = list
}

variable "application_path" {
  description = "The path that the service will listen to requests on"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster where the service will be launched"
  type        = string
}

variable "container_healthcheck" {
  default     = "wget --quiet --tries=1 --spider --timeout=30 http://localhost:8080/actuator/health || exit 1"
  description = "The command to run for the container healthcheck"
  type        = string
}

variable "container_port" {
  default     = 8080
  description = "The port number which the application is listening to inside the container"
  type        = number
}

variable "cpu_reservation" {
  default     = 128
  description = "The amount of CPU to reserve on the cluster for the task"
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

variable "docker_image" {
  description = "The docker image to be used for the task definition"
  type        = string
}

variable "external_lb_listener_arn" {
  description = "The external load balancers ARN"
  type        = string
}

variable "external_lb_name" {
  description = "The external load balancer name"
  type        = string
}

variable "healthcheck_grace_period" {
  default     = 300
  description = "The grace period to give the healthchecks"
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
  description = "The internal load balancers ARN"
  type        = string
}

variable "internal_lb_name" {
  description = "The internal load balancer name"
  type        = string
}

variable "java_options" {
  default     = ""
  description = "The Java Options environment variables to apply in the container"
  type        = string
}

variable "is_exposed_externally" {
  default     = false
  description = "Determines if the service will be attached to the external load balancer"
  type        = bool
}

variable "memory_limit" {
  default     = 512
  description = "The hard memory limit for the task"
  type        = number
}

variable "memory_reservation" {
  default     = 512
  description = "The amount of memory to reserve for the task"
  type        = number
}

variable "priority" {
  default     = 1
  description = "The priority of the application path matching"
  type        = number
}

variable "service_name" {
  description = "The name of the service which will be deployed"
  type        = string
}

variable "service_role_arn" {
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  description = "The ARN of the IAM role which will be attached at the service level"
  type        = string
}

variable "splunk_token" {
  description = "The Splunk token for the HTTP Event Collector"
  type        = string
}

variable "splunk_url" {
  description = "The Splunk URL for the HTTP Event Collector"
  type        = string
}

variable "spring_profile" {
  default     = ""
  description = "The spring profile(s) which will be enabled in the application"
  type        = string
}

variable "tags" {
  default     = {}
  description = "The map of tags to be set on resources"
  type        = map(string)
}

variable "task_role_arn" {
  default     = ""
  description = "The ARN of the IAM role which will be attached at the task definition level"
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