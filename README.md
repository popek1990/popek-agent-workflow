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
1. Senior-architect ocenia (jeśli zmiana architektoniczna)
2. Klaudiusz wdraża
3. Code-review (jeśli zmiana złożona)
4. Testy zielone → auto push na GitHub + `docker compose up -d --build`
5. Klaudiusz pisze prompt zwrotny do Sokoła (co zrobiono, co dalej?)

## Instalacja w nowym projekcie

```bash
git clone https://github.com/popek1990/popek-agent-workflow.git /tmp/workflow
bash /tmp/workflow/install.sh /ścieżka/do/twojego/projektu
```

Skrypt kopiuje pełne instrukcje do `CLAUDE.md` i `GEMINI.md` w Twoim projekcie.

## Pliki

- `workflow.md` — pełny opis procesu (referencja)
- `klaudiusz.md` — instrukcje dla Claude Code (kopiowane do CLAUDE.md)
- `sokol.md` — instrukcje dla Gemini/Codex (kopiowane do GEMINI.md)
- `install.sh` — skrypt instalacyjny
- `templates/plan_template.md` — szablon planu wdrożenia
