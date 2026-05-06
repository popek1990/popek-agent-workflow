# Workflow: Klaudiusz + Sokół

## Zasady ogólne

- Oba agenty pracują na tym samym repo/katalogu
- Tylko Klaudiusz pushuje na GitHub (chyba że Orkiestrator wyraźnie poprosi Sokoła)
- Klaudiusz nigdy nie rusza kodu bez zielonego światła od Orkiestratora
- Komunikacja między agentami odbywa się po polsku
- Pod każdą odpowiedzią — wyjaśnienie prostym językiem dla Orkiestratora

## Role

### Orkiestrator (człowiek)
- Kopiuje prompty między agentami
- Podejmuje ostateczne decyzje
- Daje zielone światło na wdrożenie

### Klaudiusz (Claude Code)
- Pisze i wdraża kod
- Tworzy plany wdrożeń (`MD/plans/plan_nazwa.md`)
- Pushuje na GitHub
- Aktualizuje dokumentację (CLAUDE.md, README, todo.md)
- Ma dostęp do sub-agentów: senior-architect, code-reviewer, planner, tdd-guide

### Sokół (Gemini / Codex)
- Research i analiza
- Szukanie błędów, luk bezpieczeństwa
- Deep thinking przy skomplikowanych tematach
- Proponowanie ulepszeń
- Tworzenie planów dla nowych funkcji

## Faza 0: Pamięć i skanowanie (oszczędność tokenów)

### 0a. Sprawdź pamięć
Przed skanem Sokół czyta:
- `MD/memory.md` — skondensowana historia: 2-3 zdania opisu per rozwiązany/odrzucony problem + link do pełnego planu w `MD/archive/`.
- `MD/issues_sokol.md` — co OPEN (do zrobienia), co FIXED (nie wracaj)

### 0b. Skanowanie
Zamiast naprawiać issues jeden po jednym (kosztowne — pełny cykl kontekstu per issue):

1. Sokół sprawdza pamięć (patrz 0a)
2. Skanuje projekt/moduł (pomija już skanowane — sprawdza header w `MD/issues_sokol.md`)
3. Zapisuje WSZYSTKIE issues do `MD/issues_sokol.md` (ze statusem OPEN)
4. Grupuje: **Quick fix** (Sokół robi sam, max 3 pliki, LOW, zero logiki), **batche** (powiązane/proste, max 5 per batch), **individual** (złożone)
5. Quick fixy wykonuje od razu (bez zatwierdzenia), raportuje w "Dla Orkiestratora"
6. Orkiestrator zatwierdza podział Batche + Individual
7. Praca idzie batch po batchu → potem individual issues

**Quick fix (Sokół sam):** literówki, rename, złamane linki, śmieci — max 3 pliki, zero ryzyka. **Wyłączenie:** pliki instrukcji workflow (`klaudiusz.md`, `sokol.md`, `workflow.md`, `cel.md`, `templates/*.md`) NIGDY nie są Quick fixem.
**Kiedy batchować:** ten sam plik/moduł, ten sam wzorzec fixu, LOW/MEDIUM severity, brak zależności.
**Kiedy osobno:** architektura, HIGH/CRITICAL, auth/płatności, nieoczywiste rozwiązanie.

## Proces ping-pong

### 1. Sokół rozpoczyna
Sokół pisze prompt dla Klaudiusza (dla pojedynczego issue LUB całego batcha) zawierający:
- **Źródło** — skąd pochodzi issue (np. `MD/issues_sokol.md`, skan modułu)
- **Konsekwencje zaniechania** — co się stanie, jeśli tego nie naprawimy?
- **Severity** — CRITICAL / HIGH / MEDIUM / LOW
- **Dotknięte pliki** — konkretne ścieżki i funkcje
- **Czego NIE robić** — zakazy (np. "nie refaktoruj otaczającego kodu")
- **Typ zmiany** — bug fix / security fix / nowa funkcja / refactor / portowanie
- Opis problemu i propozycję rozwiązania
- **Strategia testów** — mierzalne kryteria sukcesu (np. "metoda X zwraca Y dla inputu Z")
- Pytanie czy Klaudiusz się zgadza (jeśli nie — chce argument)
- Pytanie o ryzyka w implementacji

### 2. Klaudiusz odpowiada
Klaudiusz NIE implementuje — zamiast tego:
- Wybiera szablon: `templates/plan_single.md` (1 issue) lub `templates/plan_batch.md` (batch)
- Tworzy plik `MD/plans/plan_nazwa_wdrożenia.md` (status: DRAFT lub W DYSKUSJI)
- Wypełnia wszystkie pola szablonu (źródło, pliki, severity, złożoność, senior-architect TAK/NIE)
- **Pushback na złożoność:** Jeśli propozycja jest nieproporcjonalnie złożona — proponuje prostszą alternatywę NAJPIERW (YAGNI)
- Mówi czy się zgadza z Sokołem (jeśli nie — dlaczego)
- Proponuje alternatywy jeśli widzi lepsze rozwiązanie
- Identyfikuje ryzyka
- **OBOWIĄZKOWO pisze prompt zwrotny dla Sokoła** (wypisany w terminalu)

### 3. Iteracja
Orkiestrator kopiuje prompt do Sokoła. Proces się powtarza aż oba agenty są zadowolone z planu.

**Zasada 3 rund:** Jeśli po 3 rundach ping-pongu nie ma konsensusu — STOP. Agenty eskalują do Orkiestratora z podsumowaniem stanowisk i pytaniem decyzyjnym.

### 4. Zatwierdzenie

Gdy oba agenty potwierdzą plan, Sokół ocenia złożoność:

**Prosty fix** (defensywny, pełny konsensus, brak ryzyk architektonicznych):
→ Sokół pisze: "Plan jest gotowy do implementacji."
→ Klaudiusz zmienia status na ZATWIERDZONY i wdraża.

**Złożona zmiana** (architektura, nowe serwisy, spór, ryzyko średnie+):
→ Sokół pisze: "Plan jest gotowy do oceny przez senior-architect."
→ Klaudiusz wywołuje senior-architecta → jeśli OK: wdraża. Jeśli nie: powrót do ping-pongu.

### 5. Implementacja (zasady Karpathy'ego)

Przed i w trakcie implementacji obowiązują:

- **Surgical Changes:** Modyfikuj TYLKO pliki i linie wymienione w planie. Problemy poza planem → dług techniczny.
- **Test minimalizmu:** Przed implementacją: (1) Czy ≤20 linii wystarczy? (2) Czy dodaję coś, o co nikt nie prosił? (3) Czy to overcomplicated?
- **Prawo do pushbacku:** Klaudiusz MUSI odrzucić zbyt złożoną propozycję i zaproponować prostszą alternatywę NAJPIERW.

### 6. Po wdrożeniu
- Testy muszą przejść (zielone)
  - **Zasada 3 prób:** Jeśli testy padną 3 razy pod rząd, Klaudiusz przerywa pracę i wraca do Sokoła po nową strategię.
- Code-review (jeśli wymagany: 3+ pliki, logika biznesowa, nowy pattern)
- `git commit` + `git push` na GitHub (automatycznie po zielonych testach)
- `docker compose up -d --build` (automatycznie po pushu — rebuild i deploy)
- **Tracking** (obowiązkowo):
  - `MD/plans/plan_*.md` → status WDROŻONY → przenieś do `MD/archive/`
  - `MD/issues_sokol.md` → status FIXED (lub WONTFIX)
  - `MD/memory.md` → dopisz do "Zrobione" (krótki opis 2-3 zdania + link do planu w `MD/archive/`)
  - `MD/TODO.md` → oznacz task jako DONE
- Aktualizacja CLAUDE.md, README, docs (jeśli potrzeba)
- **Podsumowanie końcowe:** Klaudiusz generuje ustrukturyzowany raport statusu z checkboxami (Testy, Kontenery, Git, Tracking, Pliki) oraz sugeruje następny krok.

### 6a. Prompt zwrotny do Sokoła (obowiązkowy)
Po zakończeniu wdrożenia Klaudiusz **MUSI** wypisać w terminalu prompt po polsku dla Sokoła:
- Co zostało zrobione (podsumowanie zmian)
- **Dowód wdrożenia:** link do commitu lub wynik `git diff HEAD~1`
- Jakie testy przeszły (liczba, wynik)
- Czy deploy się powiódł (docker rebuild + push)
- **Pytanie:** jaki jest kolejny etap planu / co robimy dalej?

Orkiestrator kopiuje ten prompt do Sokoła. **Sokół wykonuje "Blind Audit":** sprawdza diff, czy nie ma zmian poza planem, i wskazuje kolejne zadanie → cykl się powtarza.

### 7. Gdy coś pójdzie nie tak

**Testy padają po wdrożeniu:**
- Klaudiusz naprawia i puszcza testy ponownie
- Jeśli fix jest nietrywalny (zmiana podejścia) → nowa runda ping-pong z Sokołem

**Code-review znajduje HIGH issues:**
- Klaudiusz naprawia → ponowne testy → push

**Senior-architect odrzuca plan:**
- Powrót do ping-pongu z uwagami architecta jako nowym inputem

## Statusy planu

```
DRAFT → W DYSKUSJI → GOTOWY DO OCENY → ZATWIERDZONY → WDROŻONY
```

- DRAFT: Klaudiusz tworzy plan na podstawie pierwszego promptu Sokoła
- W DYSKUSJI: ping-pong trwa
- GOTOWY DO OCENY: oba agenty potwierdziły, czeka na senior-architect (lub pomijamy)
- ZATWIERDZONY: gotowy do implementacji (po zielonym świetle Orkiestratora)
- WDROŻONY: kod wdrożony, testy zielone, pushnięty

## Wyjaśnienie dla Orkiestratora

Pod każdą odpowiedzią agenta — tabela zmian (sortowana od najważniejszego):

```
| # | Obecne zachowanie | Proponowana zmiana | Wpływ na działanie | Ryzyko |
|---|---|---|---|---|
| 1 | [jak działa teraz] | [co chcemy zmienić] | [jak będzie działać po zmianie] | [niskie/średnie/wysokie] |
```

Pod tabelą — pytanie decyzyjne do Orkiestratora (np. "Czy zatwierdzasz? Zaczynamy?").
