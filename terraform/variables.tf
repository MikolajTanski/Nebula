variable "cluster_name" {
  description = "Nazwa klastra k3d"
  type        = string
  default     = "nebula"
}

variable "port_http" {
  description = "Port HTTP na hoście (Traefik)"
  type        = number
  default     = 9080
}

variable "port_https" {
  description = "Port HTTPS na hoście (Traefik)"
  type        = number
  default     = 9443
}

variable "port_argocd" {
  description = "Port lokalny do port-forward ArgoCD UI"
  type        = number
  default     = 9090
}
