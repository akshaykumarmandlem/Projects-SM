variable "key_name" {
  description = "Name of the EC2 key pair to use for the Splunk Forwarder instance"
  type        = string
  default     = "default-key-pair"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "default-project"
}

variable "namespace" {
  type    = string
  default = "minikube"
}

variable "cluster_name" {
  type    = string
  default = "k8s-threat-detection"
}

variable "externalservices_prometheus_host" {
  type    = string
  default = "https://prometheus-prod-36-prod-us-west-0.grafana.net"
}

variable "externalservices_prometheus_basicauth_username" {
  type    = number
  default = 1779411
}

variable "externalservices_prometheus_basicauth_password" {
  type    = string
  default = "glc_eyJvIjoiMTIxNTcxOSIsIm4iOiJzdGFjay0xMDMxMjEyLWludGVncmF0aW9uLXRocmVhdC1kZXRlY3Rpb24tdGhyZWF0LWRldGVjdGlvbiIsImsiOiJzMDh2ZzRadjBRaEhJQ1A2NjFYMDEzcEIiLCJtIjp7InIiOiJwcm9kLXVzLXdlc3QtMCJ9fQ=="
}

variable "externalservices_loki_host" {
  type    = string
  default = "https://logs-prod-021.grafana.net"
}

variable "externalservices_loki_basicauth_username" {
  type    = number
  default = 988992
}

variable "externalservices_loki_basicauth_password" {
  type    = string
  default = "glc_eyJvIjoiMTIxNTcxOSIsIm4iOiJzdGFjay0xMDMxMjEyLWludGVncmF0aW9uLXRocmVhdC1kZXRlY3Rpb24tdGhyZWF0LWRldGVjdGlvbiIsImsiOiJzMDh2ZzRadjBRaEhJQ1A2NjFYMDEzcEIiLCJtIjp7InIiOiJwcm9kLXVzLXdlc3QtMCJ9fQ=="
}

variable "externalservices_tempo_host" {
  type    = string
  default = "https://tempo-prod-15-prod-us-west-0.grafana.net:443"
}

variable "externalservices_tempo_basicauth_username" {
  type    = number
  default = 983307
}

variable "externalservices_tempo_basicauth_password" {
  type    = string
  default = "glc_eyJvIjoiMTIxNTcxOSIsIm4iOiJzdGFjay0xMDMxMjEyLWludGVncmF0aW9uLXRocmVhdC1kZXRlY3Rpb24tdGhyZWF0LWRldGVjdGlvbiIsImsiOiJzMDh2ZzRadjBRaEhJQ1A2NjFYMDEzcEIiLCJtIjp7InIiOiJwcm9kLXVzLXdlc3QtMCJ9fQ=="
}
