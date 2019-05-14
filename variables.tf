variable "application_path" {
  description = "The path that the service will listen to requests on"
}

variable "cluster_name" {
  description = "The name of the cluster where the service will be launched"
}

variable "container_healthcheck" {
  default     = "wget --quiet --tries=1 --spider --timeout=30 http://localhost:8080/actuator/health || exit 1"
  description = "The command to run for the container healthcheck"
}

variable "container_port" {
  default     = 8080
  description = "The port number which the application is listening to inside the container"
}

variable "cpu_reservation" {
  default     = 128
  description = "The amount of CPU to reserve on the cluster for the task"
}

variable "desired_count" {
  default     = 2
  description = "The desired amount of services running at any given time"
}

variable "deregistration_delay" {
  default     = 30
  description = "The number of seconds the load balancer waits before setting the service to unused from draining"
}

variable "docker_image" {
  description = "The docker image to be used for the task definition"
}

variable "external_lb_listener_arn" {
  description = "The external load balancers ARN"
}

variable "healthcheck_grace_period" {
  default     = 300
  description = "The grace period to give the healthchecks"
}

variable "healthcheck_path" {
  default     = "/actuator/health"
  description = "The healthcheck path"
}

variable "healthy_threshold" {
  default     = 2
  description = "The number of healthchecks until a service is deemed healthy"
}

variable "internal_lb_listener_arn" {
  description = "The internal load balancers ARN"
}

variable "java_options" {
  default     = ""
  description = "The Java Options environment variables to apply in the container"
}

variable "is_exposed_externally" {
  default     = false
  description = "Determines if the service will be attached to the external load balancer"
}

variable "memory_limit" {
  default     = 512
  description = "The hard memory limit for the task"
}

variable "memory_reservation" {
  default     = 512
  description = "The amount of memory to reserve for the task"
}

variable "priority" {
  default     = 1
  description = "The priority of the application path matching"
}

variable "service_name" {
  description = "The name of the service which will be deployed"
}

variable "service_role_arn" {
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  description = "The ARN of the IAM role which will be attached at the service level"
}

variable "splunk_token" {
  description = "The Splunk token for the HTTP Event Collector"
}

variable "splunk_url" {
  description = "The Splunk URL for the HTTP Event Collector"
}

variable "spring_profile" {
  default     = ""
  description = "The spring profile(s) which will be enabled in the application"
}

variable "tags" {
  default     = {}
  description = "The map of tags to be set on resources"
  type        = "map"
}

variable "task_role_arn" {
  default     = ""
  description = "The ARN of the IAM role which will be attached at the task definition level"
}

variable "unhealthy_threshold" {
  default     = 3
  description = "The number of healthchecks until a service is deemed unhealthy"
}

variable "vpc_id" {
  description = "The VPC ID which the load balancer listener(s) will be part of"
}