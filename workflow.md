# Workflow: Klaudiusz + Sokół

<!-- workflow-version: 2026.05.07 -->

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
- Aktualizuje dokumentację (CLAUDE.md, README, `MD/TODO.md`)
- Ma dostęp do **60+ sub-agentów** z katalogu [agents.popeklab.com](https://agents.popeklab.com/) (m.in. senior-architect, python-reviewer, silent-failure-hunter, security-reviewer, code-reviewer, tdd-guide, aqua-combo)

### Sokół (Gemini / Codex)
- Research i analiza
- Szukanie błędów, luk bezpieczeństwa
- Deep thinking przy skomplikowanych tematach
- Proponowanie ulepszeń
- Tworzenie planów dla nowych funkcji
- **Sugeruje agenta dla Klaudiusza** w każdym prompcie (wybór z [agents.popeklab.com](https://agents.popeklab.com/) wg domeny zadania) — sugestia jest REKOMENDACJĄ, Klaudiusz może odrzucić z uzasadnieniem
- **Guardrails:** NIE czyta kodu bez powodu, NIE wchodzi do innych repozytoriów, NIE uruchamia testów/Dockera, NIE skanuje bez polecenia

### Wznowienie pracy ("wracamy do...")
Gdy Orkiestrator mówi "wracamy" / "kontynuujemy" — Sokół robi max 4 kroki:
1. Sprawdza `MD/issues_sokol.md` (OPEN issues?)
2. Sprawdza `MD/TODO.md` (co następne?)
3. Weryfikuje czy proponowany task nie jest już wdrożony w kodzie
4. Proponuje JEDEN następny krok → STOP, czeka na decyzję

### Retroaktywna finalizacja
Gdy task z TODO jest już wdrożony w kodzie ale nie przeszedł przez workflow:
Sokół tworzy stub `MD/archive/plan_retro_*.md`, aktualizuje memory/TODO/issues, raportuje Orkiestratorowi.

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

**Quick fix (Sokół sam):** literówki, rename, złamane linki, śmieci — max 3 pliki, zero ryzyka. **Wyłączenie:** pliki instrukcji workflow (`klaudiusz.md`, `sokol.md`, `workflow.md`, `cel.md`, `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `agents_catalog.md`, `templates/*.md`) NIGDY nie są Quick fixem.
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

**Plan jest OBOWIĄZKOWY** gdy: severity >= MEDIUM, >2 plików, lub logika biznesowa/auth/dane.

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

**Zasada 3 rund ping-pongu:** Jeśli po 3 rundach ping-pongu nie ma konsensusu — STOP. Agenty eskalują do Orkiestratora z podsumowaniem stanowisk i pytaniem decyzyjnym.

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
  - **Zasada 3 prób testowych:** Jeśli testy padną 3 razy pod rząd, Klaudiusz przerywa pracę i wraca do Sokoła po nową strategię.
- Code-review (jeśli wymagany: 3+ pliki, logika biznesowa, nowy pattern)
- `git commit` + `git push` na GitHub (automatycznie po zielonych testach)
- `docker compose up -d --build` (automatycznie po pushu — rebuild i deploy)
- **Checklista finalizacji (BLOKUJĄCA)** — Klaudiusz NIE pisze promptu zwrotnego dopóki nie odhaczy WSZYSTKICH punktów. **Kanoniczna lista:** `klaudiusz.md` → sekcja "Po zatwierdzeniu planu" → krok 12. Templates `plan_single.md` / `plan_batch.md` mają tę samą listę jako per-plan checkboxy do odhaczenia.

### 6a. Prompt zwrotny do Sokoła (obowiązkowy)
Po odhaczeniu CAŁEJ checklisty Klaudiusz **MUSI** wypisać w terminalu prompt po polsku dla Sokoła:
- Co zostało zrobione (podsumowanie zmian)
- **Dowód wdrożenia:** link do commitu lub wynik `git diff HEAD~1`
- Jakie testy przeszły (liczba, wynik)
- Czy deploy się powiódł (docker rebuild + push)
- **Odhaczona checklista finalizacji** (Sokół ją zweryfikuje)
- **Pytanie:** jaki jest kolejny etap planu / co robimy dalej?

Orkiestrator kopiuje ten prompt do Sokoła. **Sokół wykonuje "Blind Audit":** sprawdza diff, weryfikuje checklistę finalizacji (plan w archive, memory linkuje do archive, issues FIXED), i wskazuje kolejne zadanie → cykl się powtarza.

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

## FAQ — co gdy coś idzie nie tak

Sytuacje brzegowe, na które reguły wprost nie odpowiadają. Wszystkie mają wspólny rdzeń: **orkiestrator decyduje, agenty realizują**.

### Sokół wraca z tym samym pomysłem mimo NIE od Klaudiusza

Jeśli po pushbacku Klaudiusza Sokół ponownie proponuje to samo (np. po 2 rundach) bez nowego argumentu:
- Klaudiusz w prompcie zwrotnym: cytuje swój poprzedni argument + pyta "co się zmieniło że wracamy do tego pomysłu?"
- Po 3 rundach (zasada 3 rund ping-pongu) — STOP, eskalacja do orkiestratora
- Orkiestrator rozstrzyga: albo zatwierdza wersję Sokoła (overrides Klaudiusza), albo zatwierdza wersję Klaudiusza (zamyka temat → Sokół zapisuje pomysł w `MD/memory.md` "Odrzucone")

### Senior-architect odrzuca cały plan

- Status planu wraca do `W DYSKUSJI`
- Klaudiusz pisze prompt zwrotny dla Sokoła z uwagami architecta (cytuj dokładnie, nie parafrazuj)
- Standardowy ping-pong z nowym wkładem
- Jeśli architect odrzucił **drugi raz** po poprawkach — STOP, orkiestrator decyduje czy plan wykonujemy mimo wszystko, czy go zamykamy (status `WONTFIX`)

### Plan ZATWIERDZONY, ale orkiestrator zmienia zdanie

- Orkiestrator pisze do Klaudiusza "wstrzymaj plan X" — nawet jeśli implementacja już ruszyła
- Klaudiusz zatrzymuje pracę, status planu → `W DYSKUSJI` z notatką "wstrzymany przez orkiestratora — powód: …"
- **Jeśli były już commity:** zostają na branchu (lub są revertowane — decyzja orkiestratora). Plan się nie merguje na main dopóki nie wraca do `ZATWIERDZONY`
- Sokół dostaje prompt zwrotny "plan wstrzymany — czekamy na decyzję orkiestratora"

### `MD/issues_sokol.md` puchnie do 200+ wierszy

- Sokół (przy pierwszym skanie po przekroczeniu progu) raportuje to w tabeli "Dla Orkiestratora"
- Quick fix dla Sokoła: przenieść wszystkie `FIXED` / `WONTFIX` do `MD/issues_sokol_archive.md` (zostaje plik tylko z `OPEN` + `IN_PROGRESS`)
- Aktualne statusy nie giną — w archiwum mają nadal pełną historię z linkiem do planu

### Klaudiusz wywołał agenta z `agents_catalog.md` ale agent nie istnieje

Sokół zasugerował agenta którego nie ma (mimo że miał czytać katalog) lub Klaudiusz źle przeparsował.
- Klaudiusz NIE wywołuje "podobnego" agenta na ślepo
- W prompcie zwrotnym do Sokoła: "Nie znalazłem agenta `X` w `agents_catalog.md`. Sprawdziłem sekcję Y. Możesz zasugerować innego z faktycznie istniejących?"
- Sokół otwiera katalog (rule #8) i poprawia sugestię

### Push się wywalił, rollback też się wywalił

Krytyczna sytuacja — opisana w `klaudiusz.md` → "Procedura rollback". TLDR:
- Kontenery zatrzymaj (`docker compose down`)
- Eskalacja przez `bash scripts/notify.sh "DEPLOY FAIL — rollback fail — wymagana ręczna interwencja"`
- STOP. NIE próbuj `git push --force`. NIE próbuj kasować commitów. Czekaj na decyzję orkiestratora.

### Dwa agenty edytują workflow równocześnie (`klaudiusz.md`, `sokol.md`, ...)

To stanie się jeśli orkiestrator pomyli się i dał polecenie obu na ten sam zakres.
- Reguła append-only z `sokol.md` → "Kto pisze gdzie" odnosi się tylko do `MD/memory.md`. Dla plików workflow:
- Pierwsza zasada: oba agenty czytają plik PRZED edycją (zawsze świeży stan)
- Jeśli git pokazuje konflikt — Klaudiusz rozwiązuje (Sokół nie pushuje), zachowując zmiany obu stron jeśli się nie wykluczają
- Jeśli wykluczają się — eskalacja do orkiestratora przed mergem
