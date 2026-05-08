# Workflow: Dual-Agent Vibe-Coding (z perspektywy orkiestratora)

Pracuję w terminalu z dwoma agentami AI działającymi na tym samym repo. Ja (orkiestrator) zarządzam przepływem informacji między nimi.

> **To jest skrócony opis z perspektywy orkiestratora — co robię, co decyduję, co kopiuję.**
> Pełna referencja techniczna (statusy planu, format checklistów, FAQ): `workflow.md`.
> Reguły poszczególnych agentów: `builder.md` (Codex CLI), `sokol.md` (Claude Code/Gemini).

---

## Środowisko

| Okno | Agent | Narzędzie |
|------|-------|-----------|
| 1 | **Builder** | Codex CLI |
| 2 | **Sokół** | Claude Code CLI lub Gemini CLI |

Oba okna mają dostęp do tych samych plików (to samo repo).

---

## Role w jednym zdaniu

- **Builder** — pisze kod, robi `git push`, deployuje Dockera. Ma dostęp do **60+ wyspecjalizowanych agentów** z [agents.popeklab.com](https://agents.popeklab.com/) (lokalny katalog: `agents_catalog.md`).
- **Sokół** — szuka błędów, robi research, krytykuje propozycje. Domyślnie nie pushuje, ale może to zrobić, jeśli wyraźnie poproszę.
- **Ja** — kopiuję prompty między oknami, decyduję kiedy plan jest gotowy do wdrożenia.

---

## Co robię w trakcie sesji

1. **Daję polecenie** Sokołowi (np. "przeskanuj moduł X" / "zajmij się issue #5")
2. **Kopiuję prompty** które Sokół pisze do Buildera, i odwrotnie — ping-pong
3. **Daję zielone światło** na implementację, gdy oba agenty zgadzają się co do planu
4. **Decyduję eskalacje** — gdy ping-pong przekroczy 3 rundy bez konsensusu, lub senior-architect odrzuci plan (patrz `workflow.md` → FAQ)

Po zielonych testach Builder **sam** pushuje, rebuilduje Dockera i robi healthcheck — bez pytania o zgodę. Patrz `builder.md` → "Po zatwierdzeniu planu".

---

## Co dostaję pod każdą odpowiedzią

Każdy agent kończy odpowiedź dwoma rzeczami:

1. **Tabela "Dla Orkiestratora"** — proste streszczenie zmian w układzie maks. 4 kolumn, najlepiej: temat / znaczenie / następny krok
2. **Pytanie decyzyjne** — np. "Czy zatwierdzasz? Wklej do drugiego agenta?"

Tę tabelę czytam zamiast szczegółów technicznych — wystarcza do podjęcia decyzji.

---

## Pełny przebieg jednego issue

Skondensowanie procesu (szczegóły: `workflow.md`):

1. **Sokół** skanuje / dostaje issue → pisze prompt dla Buildera (z severity, plikami, propozycją, sugerowanym agentem)
2. **Builder** dostaje prompt → tworzy plan w `MD/plans/plan_*.md` (NIE pisze kodu) → pisze prompt zwrotny dla Sokoła
3. **Ping-pong** (max 3 rundy) → plan dojrzewa
4. **Senior-architect** ocenia plan (warunkowo — gdy zmiana architektoniczna lub spór)
5. **Ja** daję zielone światło → Builder wdraża, woła reviewera (przed testami!), puszcza testy
6. **Auto-deploy** — git push + docker compose up → healthcheck → notify
7. **Builder** pisze raport zwrotny dla Sokoła (diff, testy, finalizacja)
8. **Sokół** robi Blind Audit + wskazuje kolejne zadanie → wracamy do kroku 1

Po `git push` ja synchronizuję kod (jedno polecenie) tak, żeby oba okna widziały aktualny stan repo.

---

## Plik instrukcji w repo

| Plik | Co opisuje | Komu czyta |
|------|-----------|------------|
| `builder.md` → `AGENTS.md` | Reguły Buildera | Codex CLI w docelowym projekcie |
| `sokol.md` → `CLAUDE.md` / `GEMINI.md` | Reguły Sokoła | Claude Code / Gemini |
| `workflow.md` | Pełna referencja procesu + FAQ | Ja (gdy coś się popsuje) |
| `cel.md` (ten plik) | Skrót dla orkiestratora | Ja, znajomi |
| `agents_catalog.md` | Snapshot 60+ agentów (Sokół wybiera z tego, nie zmyśla) | Sokół |
| `templates/plan_single.md`, `plan_batch.md` | Szablon per-plan | Builder |
| `scripts/notify.sh` | Powiadomienie po deployu | Builder wywołuje |

---

## Co gdy coś się popsuje

`workflow.md` → sekcja "FAQ — co gdy coś idzie nie tak" pokrywa:
- Sokół zapętla się na tym samym pomyśle
- Senior-architect odrzuca plan
- Plan ZATWIERDZONY ale zmieniam zdanie
- `MD/issues_sokol.md` puchnie do 200+ wierszy
- Push się wywalił, rollback też się wywalił

`builder.md` → sekcja "Procedura rollback" — co robi Builder gdy deploy padnie.
