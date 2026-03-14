output "cluster_name" {
  description = "Nazwa klastra k3d"
  value       = "k3d-${var.cluster_name}"
}

output "argocd_url" {
  description = "ArgoCD UI (po uruchomieniu port-forward)"
  value       = "http://localhost:${var.port_argocd}"
}

output "argocd_portforward_cmd" {
  description = "Komenda do otwarcia ArgoCD UI"
  value       = "kubectl port-forward svc/argocd-server -n argocd ${var.port_argocd}:80"
}

output "argocd_password_cmd" {
  description = "Komenda do pobrania hasła admina ArgoCD"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "http_url" {
  description = "HTTP ingress"
  value       = "http://localhost:${var.port_http}"
}
