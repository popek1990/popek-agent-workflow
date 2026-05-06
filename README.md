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
- `GEMINI.md` — instrukcje dla Sokoła (z `sokol.md`)
- `templates/plan_template.md` — szablon planu wdrożenia

## Szybki start

1. Otwórz dwa terminale w katalogu projektu
2. Terminal 1: uruchom Claude Code → to Klaudiusz
3. Terminal 2: uruchom Gemini/Codex → to Sokół
4. Zacznij od Sokoła — poproś go o przegląd kodu

## Pliki w tym repo

| Plik | Opis |
|------|------|
| `klaudiusz.md` | Instrukcje dla Claude Code (kopiowane do CLAUDE.md) |
| `sokol.md` | Instrukcje dla Gemini/Codex (kopiowane do GEMINI.md) |
| `workflow.md` | Pełny opis procesu (referencja) |
| `cel.md` | Opis workflow z perspektywy orkiestratora |
| `install.sh` | Skrypt instalacyjny |
| `templates/plan_template.md` | Szablon planu wdrożenia |
