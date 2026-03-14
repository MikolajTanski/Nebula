terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

# ── 1. Klaster k3d ─────────────────────────────────────────────────────────────

resource "null_resource" "k3d_cluster" {
  provisioner "local-exec" {
    command = <<-EOT
      k3d cluster create ${var.cluster_name} \
        --port "${var.port_http}:80@loadbalancer" \
        --port "${var.port_https}:443@loadbalancer" \
        --wait
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete nebula"
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [null_resource.k3d_cluster]

  provisioner "local-exec" {
    command = "k3d kubeconfig merge ${var.cluster_name} --kubeconfig-merge-default"
  }
}

# ── 2. ArgoCD (Helm) ───────────────────────────────────────────────────────────

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-${var.cluster_name}"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-${var.cluster_name}"
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [null_resource.kubeconfig]

  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3"

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
}

# ── 3. Traefik ────────────────────────────────────────────────────────────────
# Traefik jest dostarczany przez k3s (kube-system) — nie instalujemy osobno.

# ── 4. ArgoCD Ingress ──────────────────────────────────────────────────────────

resource "kubernetes_ingress_v1" "argocd" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = "argocd.nebula.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# ── 5. Sealed Secrets (Helm) ───────────────────────────────────────────────────

resource "kubernetes_namespace" "sealed_secrets" {
  depends_on = [null_resource.kubeconfig]

  metadata {
    name = "sealed-secrets"
  }
}

resource "helm_release" "sealed_secrets" {
  depends_on = [kubernetes_namespace.sealed_secrets]

  name       = "sealed-secrets"
  namespace  = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.15.3"
}
