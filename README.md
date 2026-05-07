# Popek Agent Workflow

Dwóch agentów AI pracuje na tym samym repo. Jeden pisze kod, drugi go sprawdza. Ty kopiujesz prompty między nimi i decydujesz co wdrożyć.

## Po co to

Zamiast jednego agenta AI, który sam pisze i sam ocenia swój kod — masz dwóch, którzy się nawzajem weryfikują. Sokół znajduje problemy, Klaudiusz proponuje rozwiązania, razem dochodzą do planu przez burzę mózgów. Ty masz kontrolę na każdym etapie.

## Agenty

| Agent | Narzędzie | Rola |
|-------|-----------|------|
| **Klaudiusz** | Claude Code CLI | Pisze kod, wdraża, pushuje na GitHub |
| **Sokół** | Gemini / Codex CLI | Research, szukanie błędów, planowanie |
| **Orkiestrator** | Ty | Kopiujesz prompty, podejmujesz decyzje |

## Jak to działa

```
Sokół: znajduje problem / proponuje ulepszenie
  ↓ prompt (kopiujesz do Klaudiusza)
Klaudiusz: tworzy plan, ocenia, pisze prompt zwrotny
  ↓ prompt (kopiujesz do Sokoła)
Sokół: odpowiada → iteracja aż plan jest gotowy
  ↓
Senior-architect: ocenia plan (jeśli zmiana architektoniczna)
  ↓
Klaudiusz: wdraża → testy → auto push + docker rebuild
  ↓
Klaudiusz: pisze prompt do Sokoła — co zrobiono, co dalej?
```

## Wymagania

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) lub [Codex CLI](https://github.com/openai/codex)
- Docker (jeśli projekt używa kontenerów)

## Instalacja

```bash
git clone https://github.com/popek1990/popek-agent-workflow.git /tmp/workflow
bash /tmp/workflow/install.sh /ścieżka/do/twojego/projektu
```

Skrypt tworzy w Twoim projekcie:
- `CLAUDE.md` — instrukcje dla Klaudiusza (z `klaudiusz.md`)
- `GEMINI.md` — instrukcje dla Sokoła w Gemini CLI (z `sokol.md`)
- `AGENTS.md` — instrukcje dla Sokoła w Codex CLI (identyczna treść jak `GEMINI.md`)
- `templates/plan_single.md` — szablon planu — pojedynczy issue
- `templates/plan_batch.md` — szablon planu — batch (kilka issues)
- `MD/issues_sokol.md` — tracking issues ze statusami
- `MD/memory.md` — pamięć agentów (co zrobione, co odrzucone)

## Szybki start

1. Otwórz dwa terminale w katalogu projektu
2. Terminal 1: uruchom Claude Code → to Klaudiusz
3. Terminal 2: uruchom Gemini/Codex → to Sokół
4. Zacznij od Sokoła — poproś go o przegląd kodu

## Pełny przykład — od skanu do deployu

Konkretny flow w nowym projekcie. Pokazuje kto co mówi, czego oczekiwać.

**Krok 1 — Ty (orkiestrator) do Sokoła:**

> Przeskanuj moduł `src/cache/`. Szukaj bugów, luk bezpieczeństwa, miejsc gdzie brakuje walidacji.

**Krok 2 — Sokół skanuje, znajduje issue, pisze prompt dla Klaudiusza** (przykładowo):

> Klaudiuszu, mamy problem z walidacją inputów w module cache.
> **Źródło:** skan `src/cache/middleware.ts` linia 42
> **Severity:** HIGH
> **Konsekwencje zaniechania:** Bez walidacji `X-Forwarded-Host` atakujący może zatruć cache.
> **Dotknięte pliki:** `src/cache/middleware.ts`, `src/cache/middleware.test.ts`
> **Propozycja:** Guard na początku `getCacheKey()` — allowlista domen.
> **Sugerowany agent:** `security-reviewer` [reviewer po implementacji]
> Zaproponuj plan. Czy widzisz ryzyka?

**Krok 3 — Ty kopiujesz prompt z Sokoła do Klaudiusza.** Klaudiusz **nie pisze kodu** — tworzy `MD/plans/plan_cache_host_validation.md`, ocenia propozycję, identyfikuje ryzyka, pisze prompt zwrotny dla Sokoła:

> Sokole, zgadzam się z guardem, ale allowlista powinna być w configu (`src/config.ts`), nie hardcoded. Mitygacja pustej allowlisty: skip jeśli długość 0. Czy akceptujesz dodanie configa? Jeśli tak — zmieniam status planu na GOTOWY DO OCENY.

**Krok 4 — Ty kopiujesz odpowiedź Klaudiusza do Sokoła.** Sokół potwierdza ("Plan jest gotowy do implementacji.") lub kontruje. Ping-pong trwa max 3 rundy.

**Krok 5 — Ty dajesz zielone światło Klaudiuszowi:** *"OK, wdrażaj."*

**Krok 6 — Klaudiusz wdraża sam:** wywołuje `security-reviewer` na kodzie, puszcza testy, robi `git push`, `docker compose up -d --build`, healthcheck, aktualizuje `MD/memory.md` + `MD/TODO.md` + przenosi plan do `MD/archive/`. Kończy promptem zwrotnym dla Sokoła z dowodem (link do commitu).

**Krok 7 — Ty kopiujesz raport Klaudiusza do Sokoła.** Sokół robi Blind Audit (sprawdza diff, weryfikuje finalizację) i wskazuje kolejne issue → wracamy do kroku 2.

**Co poszło nie tak?** Patrz `workflow.md` → sekcja FAQ.

## Pliki w tym repo

| Plik | Opis |
|------|------|
| `klaudiusz.md` | Instrukcje dla Claude Code (kopiowane do CLAUDE.md) |
| `sokol.md` | Instrukcje dla Gemini/Codex (kopiowane do `GEMINI.md` i `AGENTS.md`) |
| `workflow.md` | Pełny opis procesu (referencja) |
| `cel.md` | Opis workflow z perspektywy orkiestratora |
| `install.sh` | Skrypt instalacyjny |
| `templates/plan_single.md` | Szablon planu — pojedynczy issue |
| `templates/plan_batch.md` | Szablon planu — batch (kilka issues) |
| `update-all.sh` | Aktualizacja workflow we wszystkich projektach |
