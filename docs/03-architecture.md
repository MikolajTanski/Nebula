# Nebula — Diagram Architektury

## Przepływ wdrożenia (GitOps Flow)

```
Developer
    │
    │  git push
    ▼
┌─────────────────┐
│   Git Repository │  ← single source of truth
│   (lokalny)      │    manifesty YAML, Application.yaml
└────────┬────────┘
         │  polling co 3 min / webhook
         ▼
┌─────────────────┐
│    ArgoCD        │  ← GitOps engine
│  (w klastrze)    │    wykrywa diff Git ↔ klaster
└────────┬────────┘
         │  sync
         ▼
┌──────────────────────────────────────────────┐
│                  k3s Cluster (k3d)            │
│                                               │
│  ┌────────────┐  ┌────────────┐  ┌─────────┐ │
│  │ dotnet-app │  │python-task │  │react-ui │ │
│  │  namespace │  │  namespace │  │namespace│ │
│  └────────────┘  └────────────┘  └─────────┘ │
│                                               │
│  ┌────────────────────────────────────────┐  │
│  │            Traefik Ingress             │  │
│  │  dotnet.nebula.local                   │  │
│  │  python.nebula.local                   │  │
│  │  react.nebula.local                    │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ┌──────────────┐   ┌──────────────────────┐ │
│  │Sealed Secrets│   │  ArgoCD Dashboard    │ │
│  │  Controller  │   │  argocd.nebula.local │ │
│  └──────────────┘   └──────────────────────┘ │
└──────────────────────────────────────────────┘
         ▲
         │  bootstrap (jednorazowo)
┌────────┴────────┐
│   Terraform      │
│                  │  1. tworzy klaster k3d
│                  │  2. instaluje ArgoCD (Helm)
│                  │  3. aplikuje root Application
└─────────────────┘
```

## App-of-Apps Pattern

```
ArgoCD
  └── root-app (apps/)          ← jeden "master" Application
        ├── apps/dotnet-app/
        │     └── Application.yaml  ──► manifests/dotnet-app/
        ├── apps/python-task/
        │     └── Application.yaml  ──► manifests/python-task/
        └── apps/react-ui/
              └── Application.yaml  ──► manifests/react-ui/
```

Dodanie nowej apki = dodanie folderu w `apps/`. ArgoCD wykrywa go automatycznie.

## Struktura katalogów

```
nebula/
├── docs/                        ← dokumentacja
│   ├── 01-project.md
│   ├── 02-business.md
│   └── 03-architecture.md
│
├── terraform/                   ← bootstrap (uruchamiasz raz)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── argocd/                      ← konfiguracja ArgoCD
│   ├── root-app.yaml
│   └── projects/
│
├── apps/                        ← definicje aplikacji dla ArgoCD
│   ├── dotnet-app/
│   │   └── Application.yaml
│   ├── python-task/
│   │   └── Application.yaml
│   └── react-ui/
│       └── Application.yaml
│
└── manifests/                   ← Kubernetes manifesty apek
    ├── dotnet-app/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── ingress.yaml
    │   └── sealedsecret.yaml
    ├── python-task/
    └── react-ui/
```

## Warstwa sieciowa

```
MacOS /etc/hosts
  *.nebula.local  →  127.0.0.1
                          │
                    k3d port mapping
                    :80 / :443
                          │
                    Traefik Ingress
                    ┌─────┴──────┐
                    │            │
             dotnet.nebula  python.nebula
```

## Cykl życia sekretu

```
Developer
    │
    │  kubectl create secret --dry-run -o yaml
    ▼
plain secret.yaml  (NIE trafia do Gita)
    │
    │  kubeseal
    ▼
sealedsecret.yaml  ──► git commit ──► ArgoCD sync ──► klaster odszyfruje
```
