# Popek Agent Workflow

System pracy z dwoma agentami AI w terminalu (vibe-coding).

## Agenty

| Agent | Narzędzie | Rola |
|-------|-----------|------|
| **Klaudiusz** | Claude Code CLI | Serce projektu — pisze kod, wdraża, pushuje na GitHub |
| **Sokół** | Gemini / Codex CLI | Research, szukanie błędów, deep thinking, planowanie |

## Jak to działa

```
Sokół (research/analiza)
    ↓ prompt
Orkiestrator (Ty — kopiujesz prompt)
    ↓ prompt
Klaudiusz (plan → ocena → prompt zwrotny)
    ↓ prompt
Orkiestrator (kopiujesz prompt)
    ↓ prompt
Sokół (odpowiedź → iteracja...)
```

Ping-pong trwa aż oba agenty są zadowolone z planu. Potem:
1. Senior-architect ocenia
2. Klaudiusz wdraża
3. Code-review
4. Push na GitHub

## Instalacja w nowym projekcie

```bash
curl -sL https://raw.githubusercontent.com/popek1990/popek-agent-workflow/main/install.sh | bash
```

Lub ręcznie:
```bash
git clone https://github.com/popek1990/popek-agent-workflow.git /tmp/workflow
cd /tmp/workflow && bash install.sh /ścieżka/do/twojego/projektu
```

## Pliki

- `workflow.md` — pełny opis procesu (referencja)
- `klaudiusz.md` — instrukcje dla Claude Code (dodawane do CLAUDE.md)
- `sokol.md` — instrukcje dla Gemini/Codex
- `install.sh` — skrypt instalacyjny
- `templates/plan_template.md` — szablon planu wdrożenia
