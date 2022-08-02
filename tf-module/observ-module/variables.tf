variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
  default     = "kind"
}

variable "cluster_config_path" {
  type        = string
  description = "Cluster's kubeconfig location"
  default     = "~/.kube/config"
}

variable "enable_kube_prometheus_stack" {
  type    = number
  default = 1
}

variable "enable_loki" {
  type    = number
  default = 1
}

variable "enable_promtail" {
  type    = number
  default = 1
}

variable "loki_tag" {
  type        = string
  default     = "1.8.5"
  description = "value"
}

variable "promtail_tag" {
  type        = string
  default     = "6.2.2"
  description = "value"
}

variable "kube_prometheus_stack_tag" {
  type        = string
  default     = "39.2.1"
  description = "value"
}

variable "enable_tempo" {
  type    = number
  default = 1
}

variable "enable_myapp" {
  type    = number
  default = 1
}

variable "tempo_tag" {
  type        = string
  default     = "0.21.8"
  description = "value"
}

variable "myapp_tag" {
  type        = string
  default     = "0.1.0"
  description = "value"
}
