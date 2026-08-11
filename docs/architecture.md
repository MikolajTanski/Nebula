# Architektura

Nebula składa się z kilku warstw. Każda ma jedną, jasną rolę.

![Przegląd architektury](assets/architecture-overview.png)

## Mapa komponentów

```mermaid
flowchart TB
    subgraph Host["Twój Mac"]
        subgraph Docker
            subgraph k3d["k3d cluster: nebula"]
                Traefik["Traefik Ingress<br/>port 9080 → 80"]
                
                subgraph GitOps
                    ArgoCD["ArgoCD"]
                    RootApp["root-app"]
                end
                
                subgraph Apps
                    Clipper["clipper<br/>frontend + backend"]
                end
                
                Sealed["Sealed Secrets"]
            end
        end
        
        Hosts["/etc/hosts<br/>*.nebula.local → 127.0.0.1"]
        Git["Git repo"]
    end

    Dev["Developer"] -->|git push| Git
    Git -->|poll / webhook| ArgoCD
    ArgoCD --> RootApp
    RootApp --> Clipper
    Dev -->|przeglądarka| Hosts
    Hosts --> Traefik
    Traefik --> Clipper
    Traefik --> ArgoCD
    Sealed -.->|odszyfrowuje sekrety| Apps
```

## Co robi każdy element?

| Komponent | Rola | Koszt |
|---|---|---|
| **k3d + k3s** | Lekki klaster Kubernetes w Dockerze | $0 |
| **Terraform** | Jednorazowy bootstrap (`make up`) | $0 |
| **ArgoCD** | GitOps — synchronizuje Git ↔ klaster | $0 |
| **Traefik** | Routing HTTP — każda apka pod własnym hostem | $0 (wbudowany w k3s) |
| **Sealed Secrets** | Szyfrowanie haseł w Gicie | $0 |

---

## Przepływ wdrożenia (GitOps)

![Przepływ GitOps](assets/gitops-flow.png)

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Git as Git Repo
    participant Argo as ArgoCD
    participant K8s as k3s Klaster
    participant User as Przeglądarka

    Dev->>Git: git push (manifesty YAML)
    Argo->>Git: sprawdza diff (co 3 min)
    Argo->>K8s: kubectl apply (sync)
    K8s->>K8s: uruchamia Pod'y
    User->>K8s: GET app.nebula.local:9080
    K8s->>User: odpowiedź HTTP
```

**Single source of truth = Git.**  
Stan klastra zawsze odzwierciedla ostatni commit.

---

## App-of-Apps

![App-of-Apps](assets/app-of-apps.png)

Jeden `root-app` zarządza wszystkimi aplikacjami. Dodanie nowej apki = nowy folder w `apps/`.

```mermaid
flowchart TD
    Root["root-app<br/>(argocd/root-app.yaml)"]
    
    Root --> ClipperApp["apps/clipper/<br/>Application.yaml"]
    Root --> FutureApp["apps/twoja-apka/<br/>Application.yaml"]
    
    ClipperApp --> ClipperMan["manifests/clipper/<br/>Deployment, Service, Ingress"]
    FutureApp --> FutureMan["manifests/twoja-apka/<br/>..."]
```

Kluczowa opcja w `root-app.yaml`:
```yaml
directory:
  recurse: true   # ← ArgoCD skanuje podfoldery w apps/
```

---

## Struktura katalogów

```
Nebula/
├── docs/                    ← ta dokumentacja
├── terraform/               ← bootstrap (make up / make down)
│   ├── main.tf
│   ├── variables.tf
│   └── Makefile
├── argocd/
│   └── root-app.yaml        ← master Application
├── apps/                    ← definicje dla ArgoCD (lekkie YAML)
│   └── clipper/
│       └── Application.yaml
└── manifests/               ← pełne manifesty Kubernetes
    └── clipper/
        ├── namespace.yaml
        ├── frontend-deployment.yaml
        ├── frontend-service.yaml
        ├── backend-deployment.yaml
        ├── backend-service.yaml
        └── ingress.yaml
```

---

## Warstwa sieciowa

![Warstwa sieciowa](assets/network-layer.png)

Port **9080** na hoście mapuje się na port **80** w klastrze (Traefik).

```mermaid
flowchart LR
    Browser["Przeglądarka<br/>clipper.nebula.local:9080"]
    Hosts["/etc/hosts<br/>127.0.0.1"]
    k3dPort["k3d port mapping<br/>9080 → 80"]
    Traefik["Traefik Ingress"]
    Svc["Service: frontend"]
    Pod["Pod: clipper-frontend"]

    Browser --> Hosts
    Hosts --> k3dPort
    k3dPort --> Traefik
    Traefik -->|host: clipper.nebula.local| Svc
    Svc --> Pod
```

> **Uwaga:** Używamy portu 9080 zamiast 80, żeby uniknąć konfliktu z innymi serwisami na Macu.

---

## Cykl życia sekretu

![Cykl życia sekretu](assets/sealed-secrets.png)

```mermaid
flowchart TD
    A["kubectl create secret<br/>(dry-run)"] --> B["plain secret.yaml<br/>❌ NIE commituj"]
    B --> C["kubeseal"]
    C --> D["sealedsecret.yaml<br/>✅ commituj do Gita"]
    D --> E["ArgoCD sync"]
    E --> F["Sealed Secrets Controller<br/>odszyfrowuje w klastrze"]
```

Plain secret nigdy nie trafia do repozytorium. W Git jest tylko zaszyfrowana wersja.

---

## Clipper — przykładowa aplikacja

Clipper (łączenie PDF) pokazuje typowy układ: frontend + backend + lokalny registry.

```mermaid
flowchart LR
    User["Użytkownik"] -->|":9080"| FE["frontend<br/>nginx / react"]
    FE --> BE["backend<br/>.NET / Python"]
    BE --> Registry["k3d-nebula-registry:5001<br/>własne obrazy Docker"]
```

Obrazy budujesz lokalnie, pushujesz do registry k3d, a w `deployment.yaml` wskazujesz tag obrazu.
