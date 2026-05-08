# Plan (Batch): [wspólny kontekst, np. "Bezpieczeństwo cache + Circuit Breaker"]

**Status:** DRAFT | W DYSKUSJI | GOTOWY DO OCENY | ZATWIERDZONY | WDROŻONY
**Data:** [data]
**Inicjator:** Sokół / Klaudiusz / Orkiestrator
**Typ zmiany:** bug fix | security fix | nowa funkcja | refactor | portowanie | optymalizacja
**Złożoność:** prosty fix (1-2 pliki) | średni (3-5 plików) | duży refactor (6+ plików)
**Senior-architect wymagany:** TAK / NIE — [uzasadnienie]
**Sugerowany agent:** [agent z agents.popeklab.com + 1-zdaniowe uzasadnienie + timing. Dla batchy 6+ plików / logiki biznesowej rozważ `aqua-combo` [debata przez cały proces]. Dla domeny Python rozważ `python-reviewer` [reviewer po implementacji]. Jeśli żaden — `brak — [uzasadnienie]`]

## Źródło

Skąd pochodzi batch: [np. `issues_found.md` batch #1, skan Sokoła z 2025-05-06, `bledy.md` + `MD/TODO.md`]

## Issues w tym batchu

| # | Plik | Funkcja / linia | Severity | Opis problemu | Proponowany fix |
|---|------|-----------------|----------|---------------|-----------------|
| 1 | `src/...` | `func()` | MEDIUM | [opis] | [fix] |
| 2 | `src/...` | `func()` | MEDIUM | [opis] | [fix] |

**Dlaczego batch:** [np. ten sam moduł, ten sam wzorzec fixu, brak zależności między fixami]

## Kolejność wdrażania

1. **Issue #X** — [dlaczego najpierw, np. "brak zależności, najniższe ryzyko"]
2. **Issue #Y** — [dlaczego potem, np. "zależy od #X" lub "wyższe ryzyko, po walidacji #X"]

## Propozycja rozwiązania

[Ogólne podejście do całego batcha — co łączy te fixy, jaki wspólny wzorzec]

## Minimalizm (YAGNI)

- [ ] Czy batch nie jest przeładowany? (max 5 issues)
- [ ] Czy rozwiązanie dla każdego issue jest najprostsze z możliwych?
- [ ] Czy unikamy refaktoryzacji "przy okazji"?

## Strategia testów

- [ ] [np. Testy regresji dla modułu X]
- [ ] [np. Mierzalne kryterium sukcesu: wszystkie 5 fixów przechodzi unit testy]
- [ ] [np. Smoketest połączony dla całego flow]

### Issue #1: [krótki opis]

[Konkretne kroki techniczne dla tego issue]

### Issue #2: [krótki opis]

[Konkretne kroki techniczne dla tego issue]

## Plan implementacji

1. [ ] Issue #1: [krok]
2. [ ] Issue #1: [krok]
3. [ ] Issue #2: [krok]
4. [ ] Issue #2: [krok]
5. [ ] Testy dla całego batcha

## Ryzyka

| Ryzyko | Dotyczy issue | Prawdopodobieństwo | Wpływ | Mitygacja |
|--------|--------------|-------------------|-------|-----------|
| | #1 | | | |

## Powiązane

- [linki do powiązanych planów, issues, dyskusji — jeśli są]

## Uzgodnienia

- **Sokół:** [zgadza się / ma uwagi — per issue jeśli różne stanowiska]
- **Klaudiusz:** [zgadza się / ma uwagi — per issue jeśli różne stanowiska]
- **Senior-architect:** [ocena — lub "pominięty: [uzasadnienie]"]

## Kryteria akceptacji

- [ ] Wszystkie issues z batcha zaimplementowane
- [ ] Testy przechodzą (zielone)
- [ ] Code-review (jeśli wymagany) bez CRITICAL/HIGH issues
- [ ] Deploy OK (`docker compose up -d --build`)
- [ ] Dokumentacja zaktualizowana (jeśli potrzeba)
- [ ] [dodatkowe kryteria specyficzne dla tego batcha]

## Checklista finalizacji (BLOKUJĄCA — odhacz PRZED promptem zwrotnym)

- [ ] Aplikacja działa poprawnie po deploy
- [ ] Ten plik → status zmieniony na WDROŻONY
- [ ] Ten plik → przeniesiony do `MD/archive/` (MUSI istnieć w archive)
- [ ] `MD/memory.md` → dopisano do "Zrobione" z linkiem do `MD/archive/` (NIE `MD/plans/`)
- [ ] `MD/issues_sokol.md` → status FIXED (lub WONTFIX)
- [ ] `MD/TODO.md` → taski oznaczone jako DONE
- [ ] Dokumentacja zaktualizowana (jeśli potrzeba)
- [ ] Sugerowany agent (z agents.popeklab.com) — wywołany albo odrzucony z uzasadnieniem (zgłoszone issues naprawione)
- [ ] Prompt zwrotny zawiera "Routing końcowy" — wiadomo czyja jest kolej i czy Sokół dostaje prompt teraz
- [ ] [dodatkowe sprawdzenia specyficzne dla tego batcha]

## Dla Orkiestratora

Użyj tekstowej tabeli z ramką Unicode. Pisz prostym językiem: Orkiestrator ma z tabeli od razu rozumieć co się zmienia, po co to robimy i jaka decyzja jest potrzebna.

Format tabeli: maksymalnie 4 kolumny, preferowany układ `# / Temat / Co to znaczy / Co dalej`. Nie używaj szerokiego układu `# / Obecnie / Zmiana / Wpływ / Ryzyko`. Komórki mają być krótkie, maksymalnie ok. 24 znaki. Nie zawijaj długich zdań w komórce — skróć komórkę i przenieś szczegóły pod tabelę.

┌─────┬────────────────────┬────────────────────────┬────────────────────────┐
│ #   │ Temat              │ Co to znaczy           │ Co dalej               │
├─────┼────────────────────┼────────────────────────┼────────────────────────┤
│ 1   │ [temat]            │ [krótko]               │ [następny krok]        │
│ 2   │ [temat]            │ [krótko]               │ [następny krok]        │
└─────┴────────────────────┴────────────────────────┴────────────────────────┘

Szczegóły:
[dłuższy opis, jeśli potrzebny]

**Decyzja:** [np. "Czy zatwierdzasz kolejność? Zaczynamy od #1?"]
