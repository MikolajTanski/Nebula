.PHONY: up down reboot

# Bootstrap pełnego środowiska
up:
	@echo "── Krok 1: Tworzenie klastra k3d ─────────────────────────"
	terraform apply -target=null_resource.k3d_cluster -target=null_resource.kubeconfig -auto-approve
	@echo "── Krok 2: Instalacja ArgoCD + Sealed Secrets ────────────"
	terraform apply -auto-approve
	@echo ""
	@echo "✓ Klaster gotowy."
	@echo ""
	@echo "  ArgoCD UI  : http://localhost:9090"
	@echo "  Port-forward: kubectl port-forward svc/argocd-server -n argocd 9090:80"
	@echo "  Hasło      : $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"

# Usuń cały klaster
down:
	k3d cluster delete nebula
	terraform state rm null_resource.k3d_cluster null_resource.kubeconfig || true

# Pełny reset
reboot: down
	terraform apply -target=null_resource.k3d_cluster -target=null_resource.kubeconfig -auto-approve
	terraform apply -auto-approve
