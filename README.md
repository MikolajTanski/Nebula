# Nebula

**Darmowe, lokalne środowisko GitOps na Macu.**  
Jedna komenda `git push` — aplikacja żyje pod `nazwa.nebula.local`.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

![Przegląd architektury Nebula](docs/assets/architecture-overview.png)

---

## Czym jest Nebula?

Nebula to **Twój własny mini-cloud na laptopie** — bez abonamentu, bez chmury, bez vendor lock-in.

| Bez Nebuli | Z Nebulą |
|---|---|
| Każda apka ma inny sposób uruchomienia | Jeden schemat dla wszystkich projektów |
| Ręczne `kubectl apply` | `git push` → automatyczne wdrożenie |
| Hasła w plikach `.env` | Sealed Secrets — bezpiecznie w Gicie |
| $50–200/mies. za klaster w chmurze | **$0** — wszystko lokalnie |

![Bez Nebuli vs Z Nebulą](docs/assets/why-nebula.png)

![Przepływ GitOps](docs/assets/gitops-flow.png)

---

## Szybki start (15 minut)

**Wymagania:** macOS, [Docker Desktop](https://www.docker.com/products/docker-desktop/), [Homebrew](https://brew.sh/)

```bash
# 1. Narzędzia
brew install k3d terraform kubectl helm

# 2. Postaw klaster
cd terraform && make up

# 3. DNS — dodaj do /etc/hosts
echo "127.0.0.1 argocd.nebula.local clipper.nebula.local" | sudo tee -a /etc/hosts

# 4. ArgoCD UI (w osobnym terminalu)
kubectl port-forward svc/argocd-server -n argocd 9090:80
```

| Adres | Co to |
|---|---|
| http://localhost:9090 | Panel ArgoCD (login: `admin`) |
| http://clipper.nebula.local:9080 | Przykładowa apka (Clipper) |
| http://localhost:9080 | Ingress HTTP (port Traefika) |

Hasło admina:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Szczegóły → [docs/quickstart.md](docs/quickstart.md)

---

## Struktura repo

```
Nebula/
├── terraform/          ← bootstrap (uruchamiasz raz: make up)
├── argocd/             ← root-app (App-of-Apps)
├── apps/               ← definicje aplikacji dla ArgoCD
│   └── clipper/
└── manifests/          ← manifesty Kubernetes (Deployment, Service, Ingress)
    └── clipper/
```

---

## Dokumentacja

| Dokument | Opis |
|---|---|
| [Quickstart](docs/quickstart.md) | Instalacja krok po kroku |
| [Architektura](docs/architecture.md) | Diagramy i przepływ danych |
| [Dodawanie aplikacji](docs/add-app.md) | Jak wdrożyć własny projekt |
| [Troubleshooting](docs/troubleshooting.md) | Znane problemy i rozwiązania |
| [Roadmap](docs/roadmap.md) | Plany rozwoju |

---

## Dlaczego za darmo?

Nebula to projekt open source (MIT) stworzony jako **alternatywa dla płatnych klastrów deweloperskich**.  
Chcesz GitOps i Kubernetes lokalnie — bez faktury od AWS/GCP/Azure.

- Zero kosztów infrastruktury
- Pełna kontrola — wszystko na Twoim Macu
- Umiejętności 1:1 przenoszalne na produkcję (EKS, GKE, AKS)
- Możesz forkować, modyfikować, udostępniać

---

## Licencja

[MIT](LICENSE) — używaj jak chcesz, za darmo.
