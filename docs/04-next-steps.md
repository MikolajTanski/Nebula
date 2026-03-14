# Nebula — Dalszy Plan Działania

## Status obecny ✓

| Komponent | Status |
|---|---|
| k3d klaster `nebula` | działa |
| ArgoCD | zainstalowany, UI dostępny pod `argocd.nebula.local:9080` |
| Traefik | wbudowany k3s, obsługuje Ingress |
| Sealed Secrets | zainstalowany |
| DNS lokalny | `argocd.nebula.local` → `/etc/hosts` |

---

## Faza 3 — App-of-Apps (GitOps engine)

Cel: ArgoCD zaczyna zarządzać aplikacjami z Gita.

### 3.1 Inicjalizacja repo Git
```bash
cd /Users/mikolajtanski/Desktop/Moje\ projekty/Nebula
git init
git add .
git commit -m "init: nebula bootstrap"
```

### 3.2 Root Application (App-of-Apps)
Stworzyć `argocd/root-app.yaml` — jeden Application który śledzi folder `apps/`.
ArgoCD automatycznie wykryje każdy `Application.yaml` dodany do `apps/`.

### 3.3 Podpięcie repo do ArgoCD
Zarejestrować lokalne repo w ArgoCD (przez UI lub CLI `argocd repo add`).
Zaaplikować `root-app.yaml` przez `kubectl apply`.

Od tego momentu: `git push` = wdrożenie.

---

## Faza 4 — Pierwsza aplikacja (smoke test)

Cel: udowodnić że cały pipeline działa end-to-end.

### 4.1 Hello World (nginx)
- `apps/hello/Application.yaml` — definicja dla ArgoCD
- `manifests/hello/deployment.yaml` — prosty nginx
- `manifests/hello/service.yaml`
- `manifests/hello/ingress.yaml` → `hello.nebula.local:9080`

### 4.2 DNS
Dodać wpis do `/etc/hosts`:
```
127.0.0.1 hello.nebula.local
```

### 4.3 Test
```bash
git add . && git commit -m "feat: hello world app"
# obserwuj sync w ArgoCD UI
curl http://hello.nebula.local:9080
```

---

## Faza 5 — Lokalny registry Docker

Cel: wdrażać własne obrazy, nie tylko publiczne.

### 5.1 Stworzenie registry
```bash
k3d registry create nebula-registry --port 5050
k3d cluster edit nebula --registry-use k3d-nebula-registry:5050
```

### 5.2 Workflow z własnym obrazem
```bash
docker build -t localhost:5050/myapp:v1 .
docker push localhost:5050/myapp:v1
# zaktualizuj tag w deployment.yaml → git push → ArgoCD sync
```

Konwencja tagowania: `localhost:5050/<nazwa>:<git-sha>` (nie `latest`)

---

## Faza 6 — Właściwe aplikacje

Kolejność wdrożeń (od najprostszej):

### 6.1 Python (FastAPI / Flask)
- Prosta REST API lub worker
- Namespace: `python-task`
- URL: `python.nebula.local:9080`

### 6.2 .NET (ASP.NET Core)
- Web API lub minimal API
- Namespace: `dotnet-app`
- URL: `dotnet.nebula.local:9080`

### 6.3 React
- Frontend zbudowany przez Vite/CRA
- Nginx jako serwer statyczny w kontenerze
- Namespace: `react-ui`
- URL: `react.nebula.local:9080`

Dla każdej apki ten sam schemat:
```
apps/<nazwa>/Application.yaml
manifests/<nazwa>/deployment.yaml
manifests/<nazwa>/service.yaml
manifests/<nazwa>/ingress.yaml
```

---

## Faza 7 — Sealed Secrets (produkcyjne sekrety)

Cel: hasła do baz danych i tokeny bezpiecznie w Gicie.

```bash
# Pobierz certyfikat klastra
kubeseal --fetch-cert --controller-namespace sealed-secrets > pub-cert.pem

# Zapieczętuj sekret
kubectl create secret generic db-password \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml \
  | kubeseal --cert pub-cert.pem -o yaml > manifests/myapp/sealedsecret.yaml

# pub-cert.pem można commitować (publiczny klucz)
# sealedsecret.yaml można commitować (zaszyfrowany)
# plain secret.yaml — NIGDY do Gita
```

---

## Faza 8 — DNS wildcard (opcjonalne ulepszenie)

Zamiast dodawać wpisy ręcznie do `/etc/hosts` przy każdej nowej apce — skonfigurować `dnsmasq`:

```bash
brew install dnsmasq
echo "address=/.nebula.local/127.0.0.1" >> /opt/homebrew/etc/dnsmasq.conf
sudo brew services start dnsmasq
```

Po tym `*.nebula.local` automatycznie rozwiązuje się do `127.0.0.1` — bez dotykania `/etc/hosts`.

---

## Backlog (nice to have)

| Pomysł | Opis |
|---|---|
| GitHub Actions lokalny | `act` — uruchamiaj GitHub Actions lokalnie |
| Monitoring | Prometheus + Grafana przez ArgoCD |
| Dashboards | Kubernetes Dashboard lub Headlamp |
| Multi-node | k3d z 3 nodami (1 server + 2 agents) |
| HTTPS lokalny | cert-manager + self-signed cert |
| Ollama + Open WebUI |
