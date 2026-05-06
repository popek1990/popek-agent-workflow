# Plan (Batch): [wspólny kontekst, np. "Bezpieczeństwo cache + Circuit Breaker"]

**Status:** DRAFT | W DYSKUSJI | GOTOWY DO OCENY | ZATWIERDZONY | WDROŻONY
**Data:** [data]
**Inicjator:** Sokół / Klaudiusz / Orkiestrator
**Typ zmiany:** bug fix | security fix | nowa funkcja | refactor | portowanie | optymalizacja
**Złożoność:** prosty fix (1-2 pliki) | średni (3-5 plików) | duży refactor (6+ plików)
**Senior-architect wymagany:** TAK / NIE — [uzasadnienie]

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

## Post-deploy weryfikacja

- [ ] Aplikacja działa poprawnie po deploy
- [ ] Plik planu → status WDROŻONY
- [ ] TODO / lista zadań → taski oznaczone jako DONE
- [ ] `issues_found.md` → issues oznaczone jako rozwiązane
- [ ] [dodatkowe sprawdzenia specyficzne dla tego batcha]

## Dla Orkiestratora

| # | Obecne zachowanie | Proponowana zmiana | Wpływ na działanie | Ryzyko |
|---|---|---|---|---|
| 1 | [jak działa teraz] | [co chcemy zmienić] | [jak będzie działać po zmianie] | [niskie/średnie/wysokie] |
| 2 | ... | ... | ... | ... |

**Decyzja:** [np. "Czy zatwierdzasz kolejność? Zaczynamy od #1?"]
