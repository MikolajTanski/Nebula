# Roadmap

Co jest gotowe, co planowane, co opcjonalne.

![Roadmap Nebula 2026](assets/roadmap.png)

## Status

| Komponent | Status |
|---|---|
| k3d klaster `nebula` | ✅ działa |
| Terraform bootstrap | ✅ `make up` / `make down` |
| ArgoCD + root-app | ✅ App-of-Apps z `recurse: true` |
| Traefik Ingress | ✅ port 9080 |
| Sealed Secrets | ✅ zainstalowany |
| Clipper (przykładowa apka) | ✅ frontend + backend |
| Lokalny Docker registry | 🔶 ręczna konfiguracja |
| DNS wildcard (dnsmasq) | 📋 planowane |
| Monitoring (Prometheus/Grafana) | 📋 planowane |

---

## Fazy rozwoju

```mermaid
gantt
    title Nebula Roadmap
    dateFormat YYYY-MM
    section Fundament
    Bootstrap k3d + ArgoCD     :done, 2026-01, 2026-02
    App-of-Apps pattern        :done, 2026-02, 2026-03
    Clipper smoke test         :done, 2026-03, 2026-04
    section DevEx
    Dokumentacja               :active, 2026-04, 2026-05
    DNS wildcard               :2026-05, 2026-06
    Lokalny registry w Terraform :2026-05, 2026-06
    section Rozszerzenia
    Sealed Secrets workflow    :2026-06, 2026-07
    Monitoring stack           :2026-07, 2026-08
    HTTPS lokalny              :2026-08, 2026-09
```

---

## Następne kroki (priorytet)

### 1. DNS wildcard
Zamiast ręcznego `/etc/hosts` przy każdej apce:
```bash
brew install dnsmasq
echo "address=/.nebula.local/127.0.0.1" >> /opt/homebrew/etc/dnsmasq.conf
sudo brew services start dnsmasq
```

### 2. Registry w Terraform
Automatyczne tworzenie `k3d-nebula-registry` przy `make up`.

### 3. Sealed Secrets — pełny workflow
Dokumentacja + przykład `sealedsecret.yaml` w Clipperze.

### 4. Monitoring
Prometheus + Grafana jako kolejna aplikacja w `apps/`.

---

## Backlog (nice to have)

| Pomysł | Opis |
|---|---|
| GitHub Actions lokalny | `act` — CI na Macu |
| Kubernetes Dashboard | Headlamp lub oficjalny dashboard |
| Multi-node k3d | 1 server + 2 agents |
| cert-manager | HTTPS z self-signed cert |
| Ollama + Open WebUI | Lokalne LLM w klastrze |
| Helm charts per app | Zamiast raw YAML |

---

## Filozofia produktu

Nebula to **darmowe narzędzie dev**, nie platforma enterprise.

- Proste > kompletne
- Działa lokalnie > skaluje się do chmury
- Dokumentacja > automatyzacja wszystkiego
- Open source > vendor lock-in

Każda funkcja musi zmniejszać tarcie, nie je zwiększać.
