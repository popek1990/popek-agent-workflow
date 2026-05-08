# Plan: [nazwa wdrożenia]

**Status:** DRAFT | W DYSKUSJI | GOTOWY DO OCENY | ZATWIERDZONY | WDROŻONY
**Data:** [data]
**Inicjator:** Sokół / Klaudiusz / Orkiestrator
**Typ zmiany:** bug fix | security fix | nowa funkcja | refactor | portowanie | optymalizacja
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**Złożoność:** prosty fix (1-2 pliki) | średni (3-5 plików) | duży refactor (6+ plików)
**Senior-architect wymagany:** TAK / NIE — [uzasadnienie, np. "defensywny fix, pełny konsensus, brak ryzyk architektonicznych"]
**Sugerowany agent:** [agent z agents.popeklab.com + 1-zdaniowe uzasadnienie + timing, np. "`python-reviewer` [reviewer po implementacji] — fix dotyka logiki kalkulacji, wymaga weryfikacji idiomów Pythona". Jeśli żaden nie pasuje — `brak — [uzasadnienie]`]

## Źródło

Skąd pochodzi issue: [np. `bledy.md`, skan Sokoła, `issues_found.md` batch #2, request Orkiestratora, `MD/TODO.md`]

## Problem / Cel

[Opis problemu — co jest nie tak i dlaczego to ważne. Konsekwencje zaniechania.]

## Dotknięte pliki / moduły

| Plik | Funkcja / linia | Co wymaga zmiany |
|------|-----------------|------------------|
| `src/...` | `nazwa_funkcji()` | [opis zmiany] |

## Propozycja rozwiązania

[Co proponujemy zrobić — konkretne kroki techniczne]

## Minimalizm (YAGNI)

- [ ] Czy to rozwiązanie jest najprostsze z możliwych?
- [ ] Czy modyfikuję tylko niezbędne pliki i linie?
- [ ] Czy unikam "gold-platingu" i przyszłościowych funkcji?

## Strategia testów

- [ ] [np. Test jednostkowy: metoda X zwraca 400 dla inputu Y]
- [ ] [np. Integracja: baza danych zapisuje rekord Z]
- [ ] [np. Mierzalne kryterium sukcesu: czas odpowiedzi < 100ms]

## Plan implementacji

1. [ ] Krok 1
2. [ ] Krok 2
3. [ ] Krok 3

## Ryzyka

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|--------|-------------------|-------|-----------|
| | | | |

## Powiązane

- [linki do powiązanych planów, issues, dyskusji — jeśli są]

## Uzgodnienia

- **Sokół:** [zgadza się / ma uwagi]
- **Klaudiusz:** [zgadza się / ma uwagi]
- **Senior-architect:** [ocena — lub "pominięty: [uzasadnienie]"]

## Kryteria akceptacji

- [ ] Testy przechodzą (zielone)
- [ ] Code-review (jeśli wymagany) bez CRITICAL/HIGH issues
- [ ] Deploy OK (`docker compose up -d --build`)
- [ ] Dokumentacja zaktualizowana (jeśli potrzeba)
- [ ] [dodatkowe kryteria specyficzne dla tego planu]

## Checklista finalizacji (BLOKUJĄCA — odhacz PRZED promptem zwrotnym)

- [ ] Aplikacja działa poprawnie po deploy
- [ ] Ten plik → status zmieniony na WDROŻONY
- [ ] Ten plik → przeniesiony do `MD/archive/` (MUSI istnieć w archive)
- [ ] `MD/memory.md` → dopisano do "Zrobione" z linkiem do `MD/archive/` (NIE `MD/plans/`)
- [ ] `MD/issues_sokol.md` → status FIXED (lub WONTFIX)
- [ ] `MD/TODO.md` → task oznaczony jako DONE
- [ ] Dokumentacja zaktualizowana (jeśli potrzeba)
- [ ] Sugerowany agent (z agents.popeklab.com) — wywołany albo odrzucony z uzasadnieniem (zgłoszone issues naprawione)
- [ ] Prompt zwrotny zawiera "Routing końcowy" — wiadomo czyja jest kolej i czy Sokół dostaje prompt teraz
- [ ] [dodatkowe sprawdzenia specyficzne dla tego planu]

## Dla Orkiestratora

Użyj tekstowej tabeli z ramką Unicode. Pisz prostym językiem: Orkiestrator ma z tabeli od razu rozumieć co się zmienia, po co to robimy i jaka decyzja jest potrzebna. Komórki mają być krótkie, ale nie jednowyrazowe jeśli przez to tracą sens. Dłuższe opisy, uzasadnienia i szczegóły techniczne wpisz pod tabelą jako zwykły tekst.

Reguła szerokości kolumn: każda linia tekstu w komórce musi mieścić się między separatorami `│`. Jeśli tekst jest za długi, zawiń go do kolejnej fizycznej linii tej samej komórki albo skróć wpis w tabeli i przenieś szczegóły pod tabelę.

┌─────┬───────────────────┬────────────────────┬───────────────────┬─────────┐
│ #   │ Obecnie           │ Zmiana             │ Wpływ             │ Ryzyko  │
├─────┼───────────────────┼────────────────────┼───────────────────┼─────────┤
│ 1   │ [jak jest teraz]  │ [co zmieniamy]    │ [co to daje]      │ [krótko]│
└─────┴───────────────────┴────────────────────┴───────────────────┴─────────┘

Szczegóły:
[dłuższy opis, jeśli potrzebny]

**Decyzja:** [np. "Czy zatwierdzasz ten plan? Czy zaczynamy wdrożenie?"]
