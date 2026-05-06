# Workflow: Dual-Agent Vibe-Coding

Pracuję w terminalu z dwoma agentami AI działającymi na tym samym repozytorium. Ja (orkiestrator) zarządzam przepływem informacji między nimi.

> To jest uproszczony opis z perspektywy orkiestratora. Pełna referencja techniczna: `workflow.md`.

---

## Środowisko

| Okno | Agent | Narzędzie |
|------|-------|-----------|
| 1 | **Klaudiusz** | Claude Code CLI |
| 2 | **Sokół** | Gemini lub Codex CLI |

Oba okna mają dostęp do tych samych plików (to samo repo).

---

## Role agentów

### Klaudiusz (Claude Code) — serce projektu

- Tworzy, edytuje i ulepsza kod
- Robi `git push` na GitHub
- Tutaj zachodzą wszystkie poważne zmiany w projekcie
- Ma dostęp do agentów pomocniczych (`/code-review`, `@/a/senior-architect/` itd.)
- **Nie dokonuje zmian w kodzie bez mojego zielonego światła** (ale po zielonych testach i code review — sam pushuje i rebuilduje Dockera)
- **Prawo do pushbacku** — jeśli propozycja jest zbyt złożona, Klaudiusz musi zaproponować prostszą alternatywę (zasady Karpathy'ego)

### Sokół (Gemini / Codex) — analityk i doradca

- Szuka pomysłów i ulepszeń
- Znajduje błędy, luki bezpieczeństwa
- Myśli głęboko przy skomplikowanych tematach
- Tworzy plany dla nowych funkcji
- **Nigdy nie robi push na GitHub** (chyba że wyraźnie poproszę)
- **Nigdy nie edytuje plików instrukcji workflow** (`klaudiusz.md`, `sokol.md`, `workflow.md`, `cel.md`, `templates/*.md`)
- Może samodzielnie robić **Quick fixy** (literówki, rename, max 3 pliki, zero logiki)

---

## Orkiestrator (ja)

- Kopiuję prompty między agentami (ręcznie)
- Decyduję, kiedy plan jest gotowy do wdrożenia
- Daję zielone światło na zmiany w kodzie
- Chcę rozumieć każdy etap — wymagam opisów prostymi słowami (znam Git, Docker i podstawy architektury, ale nie chcę żargonu)

---

## Workflow krok po kroku

### Faza 0: Pamięć i skanowanie

1. Sokół sprawdza `MD/memory.md` (co już zrobione/odrzucone) i `MD/issues_sokol.md` (co OPEN)
2. Sokół skanuje projekt/moduł (pomija już skanowane)
3. Zapisuje WSZYSTKIE issues do `MD/issues_sokol.md`
4. Grupuje: **Quick fix** (robi sam) / **Batche** (powiązane, max 5) / **Individual** (złożone)
5. Quick fixy wykonuje od razu, resztę przedstawia mi do zatwierdzenia

### Faza 1: Analiza (Sokół)

6. Sokół pisze **prompt dla Klaudiusza** z pełnym checklistem:
   - Źródło, severity, dotknięte pliki, konsekwencje zaniechania
   - Czego NIE robić (zakazy)
   - Propozycja rozwiązania i mierzalne kryteria akceptacji
   - Pytania do Klaudiusza

### Faza 2: Burza mózgów (ping-pong)

7. Ja kopiuję prompt Sokoła → wklejam do Klaudiusza
8. Klaudiusz **nie rusza kodu** — zamiast tego:
   - Tworzy plan z szablonu (`templates/plan_single.md` lub `templates/plan_batch.md`)
   - Ocenia propozycję — zgadza się lub proponuje alternatywę
   - **Test minimalizmu:** Czy rozwiązanie jest najprostsze? Czy ≤20 linii wystarczy?
   - Pisze **prompt zwrotny dla Sokoła**
9. Ja kopiuję prompt Klaudiusza → wklejam do Sokoła
10. Sokół odpowiada → powtarzamy (kroki 7–9)
11. **Kończymy gdy plan satysfakcjonuje obu agentów** (max 3 rundy — po 3 eskalacja do mnie)

### Faza 3: Ocena architektury (warunkowa)

Senior-architect jest wymagany TYLKO gdy:
- Zmiana dotyka architektury (nowe serwisy, zmiana flow danych)
- Agenty nie doszły do konsensusu (był spór)
- Ryzyko średnie lub wyższe

Prosty fix z pełnym konsensusem → pomijamy.

### Faza 4: Wdrożenie

12. Klaudiusz wdraża plan (po moim zielonym świetle)
13. **Surgical Changes:** Modyfikuje TYLKO pliki wymienione w planie

### Faza 5: Code review i auto-deploy

14. Klaudiusz wywołuje `/code-review` (jeśli wymagany: 3+ pliki, logika biznesowa)
15. Gdy review przechodzi, Klaudiusz **sam** (bez pytania o zgodę):
    - Robi `git push` na GitHub
    - Robi `docker compose up -d --build` (rebuild + deploy)
    - Aktualizuje tracking: `MD/plans/`, `MD/issues_sokol.md`, `MD/memory.md`, `MD/TODO.md`
    - Aktualizuje dokumentację (CLAUDE.md, README) jeśli potrzeba
    - Powiadamia mnie (popup)

### Faza 6: Prompt zwrotny do Sokoła

16. Klaudiusz pisze **prompt dla Sokoła** (po polsku, w terminalu):
    - Co zostało zrobione + dowód (diff/commit)
    - Wynik testów i deploy
    - Dług techniczny / uwagi (jeśli są)
    - Pytanie: co dalej?
17. Ja kopiuję ten prompt → wklejam do Sokoła
18. Sokół robi **Blind Audit** (sprawdza diff, czy nie ma zmian poza planem)
19. Sokół wskazuje kolejne zadanie → wracamy do Fazy 1

---

## Po git push — synchronizacja kodu

Po każdym `git push` orkiestrator (ja) instaluje nową wersję kodu w środowisku, aby **oba okna** (Klaudiusz i Sokół) widziały aktualny stan repozytorium.

---

## Zasady komunikacji

Pod każdym promptem (niezależnie od fazy) chcę tabelę zmian:

| # | Obecne zachowanie | Proponowana zmiana | Wpływ na działanie | Ryzyko |
|---|---|---|---|---|
| 1 | [jak działa teraz] | [co chcemy zmienić] | [jak będzie działać] | [niskie/średnie/wysokie] |

Pod tabelą — pytanie decyzyjne (np. "Czy zatwierdzasz? Zaczynamy?").
