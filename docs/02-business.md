# Nebula — Uzasadnienie Biznesowe

## Cel

Zbudowanie prywatnego, lokalnego środowiska deweloperskiego klasy produkcyjnej — bez kosztów chmury, z pełną kontrolą nad infrastrukturą.

## Korzyści

### Koszt
- **$0/miesiąc** na infrastrukturę w trakcie developmentu
- Brak rachunków za klastry EKS/GKE/AKS w fazie nauki i prototypowania
- Jedno środowisko zamiast N różnych konfiguracji per projekt

### Czas
- Nowa apka gotowa do wdrożenia w minuty — wystarczy dodać folder z manifestami
- Zero czasu na ręczną konfigurację każdego nowego projektu
- Odtworzenie całego środowiska po reinstalacji systemu: `terraform apply`

### Jakość
- Parity z produkcją — lokalne środowisko zachowuje się identycznie jak środowisko chmurowe
- GitOps jako single source of truth — stan klastra zawsze odzwierciedla stan Gita
- Audytowalność — każda zmiana wdrożeniowa jest commitem w historii Gita

### Bezpieczeństwo
- Sealed Secrets — hasła i tokeny zaszyfrowane w Gicie, odszyfrowane tylko przez klaster
- Brak plików z sekretami poza kontrolą wersji

## Scenariusze użycia

| Scenariusz | Bez Nebuli | Z Nebulą |
|---|---|---|
| Uruchomienie nowej apki | Ręczna konfiguracja Docker Compose / lokalny serwer | `git push` → apka żyje pod `nazwa.nebula.local` |
| Wdrożenie nowej wersji | `docker build && kubectl apply -f ...` | `git push` |
| Sprawdzenie stanu wszystkich apek | Wiele terminali, wiele komend | Jeden dashboard ArgoCD w przeglądarce |
| Odtworzenie środowiska po awarii | Kilka godzin ręcznej pracy | `terraform apply` (~5 minut) |
| Dodanie nowego projektu (inny język) | Nowy zestaw narzędzi, nowa konfiguracja | Nowy folder w `apps/` |

## Długoterminowa wartość

Środowisko zbudowane w tym modelu (GitOps + Kubernetes) jest bezpośrednio przenoszalne na produkcję w chmurze. Kompetencje i manifesty wypracowane lokalnie działają 1:1 na AWS EKS, Google GKE czy Azure AKS — bez przepisywania.
