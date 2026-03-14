# Nebula — Opis Projektu

## Czym jest Nebula?

Nebula to lokalne środowisko GitOps zbudowane na Maca. Pozwala wdrażać dowolną liczbę aplikacji (niezależnie od języka — .NET, Python, React, Go) na lokalny klaster Kubernetes jedną komendą: `git push`.

## Problem który rozwiązuje

Praca z wieloma projektami jednocześnie generuje chaos:
- każda apka ma inny sposób uruchamiania lokalnie
- ręczne `kubectl apply` są podatne na błędy i nie zostają w historii
- brak centralnego miejsca do obserwacji stanu wszystkich serwisów
- sekrety i hasła lądują w plikach konfiguracyjnych poza kontrolą wersji

## Rozwiązanie

Nebula standaryzuje sposób pracy z każdą apką:

1. Kod apki żyje w swoim własnym repo
2. Manifest wdrożenia (kilka plików YAML) ląduje w tym repo
3. `git push` → ArgoCD automatycznie wykrywa zmianę i wdraża na klaster
4. Stan każdej apki widoczny w przeglądarce (ArgoCD UI)

## Co wchodzi w skład

| Komponent | Rola |
|---|---|
| **k3s via k3d** | Lekki klaster Kubernetes działający lokalnie w Dockerze |
| **Terraform** | Jednorazowy bootstrap — stawia klaster i instaluje ArgoCD |
| **ArgoCD** | Silnik GitOps — synchronizuje Git z klastrem |
| **Traefik** | Ingress — każda apka dostaje adres `*.nebula.local` |
| **Sealed Secrets** | Szyfrowanie sekretów — bezpieczne trzymanie haseł w Gicie |

## Dla kogo

Dla developera który chce mieć profesjonalne, powtarzalne środowisko lokalne — bez utrzymywania pełnego klastra chmurowego i bez płacenia za infrastrukturę w czasie developmentu.
