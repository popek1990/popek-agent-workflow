# Popek Agent Workflow

Dwóch agentów AI pracuje na tym samym repo. Jeden pisze kod, drugi go sprawdza. Ty kopiujesz prompty między nimi i decydujesz co wdrożyć.

> **Repo szablonowe.** Tu nie implementujesz kodu — instalujesz workflow w docelowym projekcie skryptem `install.sh`. Pliki `builder.md` i `sokol.md` są kopiowane jako instrukcje dla agentów.

## Spis treści

- [Po co to](#po-co-to)
- [Agenty](#agenty)
- [Jak to działa](#jak-to-działa)
- [Najważniejsze zasady](#najważniejsze-zasady)
- [Wymagania](#wymagania)
- [Instalacja](#instalacja)
- [Co tworzy install.sh](#co-tworzy-installsh-w-projekcie-docelowym)
- [Aktualizacja workflow](#aktualizacja-workflow-force)
- [Szybki start](#szybki-start)
- [Pełny przykład — od skanu do deployu](#pełny-przykład--od-skanu-do-deployu)
- [Statusy planu](#statusy-planu)
- [Pliki w tym repo](#pliki-w-tym-repo)
- [FAQ](#faq--co-gdy-coś-idzie-nie-tak)

## Po co to

Zamiast jednego agenta AI, który sam pisze i sam ocenia swój kod — masz dwóch, którzy się nawzajem weryfikują. Sokół znajduje problemy, Builder proponuje rozwiązania, razem dochodzą do planu przez burzę mózgów. Ty masz kontrolę na każdym etapie.

**Co dostajesz:**
- Drugi pair of eyes na każdą zmianę przed implementacją
- Plan zapisany w `MD/plans/plan_*.md` zanim cokolwiek zostanie zaimplementowane
- Tracking issues w `MD/issues_sokol.md` (OPEN / IN_PROGRESS / FIXED / WONTFIX)
- Pamięć decyzji w `MD/memory.md` (zrobione + odrzucone z uzasadnieniem)
- Auto-deploy po zielonych testach (push + docker rebuild + healthcheck)
- Tabelę "Dla Orkiestratora" pod każdą odpowiedzią agenta — proste streszczenie dla człowieka
- Czytelne podsumowania planów: co działa teraz, co zmieni wdrożenie, jakie jest ryzyko i jaka decyzja jest potrzebna
- Higienę kontekstu: `/compact` albo nowa sesja dopiero po zamkniętej fazie pracy, nie po każdym małym kroku

## Agenty

| Agent | Narzędzie | Rola |
|-------|-----------|------|
| **Builder** | Codex CLI | Pisze kod, wdraża, pushuje na GitHub. Ma dostęp do **60+ wyspecjalizowanych sub-agentów** ([agents.popeklab.com](https://agents.popeklab.com/)) |
| **Sokół** | Claude Code CLI lub Gemini CLI | Research, szukanie błędów, planowanie i Blind Audit. Domyślnie nie pushuje, ale może to zrobić na wyraźne polecenie Orkiestratora |
| **Orkiestrator** | Ty | Kopiujesz prompty, podejmujesz decyzje, dajesz zielone światło |

## Jak to działa

```
Sokół: skanuje moduł / czyta issue / dostaje polecenie
  ↓ prompt (kopiujesz do Buildera)
Builder: tworzy plan w MD/plans/, ocenia, pisze prompt zwrotny
  ↓ prompt (kopiujesz do Sokoła)
Sokół: odpowiada → iteracja (max 3 rundy) aż plan jest gotowy
  ↓
Senior-architect: ocenia plan (warunkowo — przy zmianach architektonicznych)
  ↓
Ty: dajesz zielone światło "OK, wdrażaj"
  ↓
Builder: wdraża → testy → auto push + docker rebuild + healthcheck
  ↓
Builder: pisze raport zwrotny dla Sokoła (commit, testy, checklista)
  ↓
Sokół: Blind Audit (weryfikuje diff, finalizację) → wskazuje kolejne issue
  ↓
Cykl się powtarza
```

## Najważniejsze zasady

### Builder najpierw planuje, potem wdraża

Builder nie zaczyna od kodu. Najpierw tworzy plan w `MD/plans/`, ocenia propozycję Sokoła i pisze prompt zwrotny. Implementacja zaczyna się dopiero po zielonym świetle Orkiestratora.

Po zielonych testach Builder sam robi commit, push, rebuild Dockera i healthcheck. To jest świadome uproszczenie procesu: Orkiestrator zatwierdza wdrożenie raz, a Builder kończy je do końca.

### Sokół ma domyślny zakres, nie absolutne zakazy

Sokół standardowo zajmuje się analizą, planowaniem, review i Blind Auditem. Testy, Docker, commit i push zostawia Builderowi.

To nie jest twardy zakaz. Jeśli Orkiestrator wyraźnie poprosi Sokoła o push, commit, testy, Dockera albo aktualizację tracking docs, Sokół może to zrobić. Ma wtedy opisać ryzyko prostym językiem i nie używać destrukcyjnych operacji typu `git push --force` bez osobnego, jednoznacznego polecenia.

### Raporty mają być zrozumiałe dla Orkiestratora

Tabela "Dla Orkiestratora" ma być krótka, ale nie może być samym żargonem. Gdy Sokół pisze, że plan jest gotowy, pod tabelą musi dopisać prostym językiem:

- o co chodzi;
- jak działa teraz;
- co zmieni wdrożenie;
- jakie jest ryzyko;
- jakiej decyzji potrzebuje od Orkiestratora.

Sokół rozwija skróty i techniczne pojęcia przy pierwszym użyciu. Zamiast pisać tylko `SA`, `AST`, `cron`, `24h window`, `caller`, `replayable` albo `idempotentny`, dopisuje krótkie wyjaśnienie po polsku.

Sokół nie powinien rutynowo dodawać sekcji "Czego NIE zrobiłem". Pominiętą czynność wymienia tylko wtedy, gdy blokuje następny krok, była przedmiotem pytania Orkiestratora albo wymaga decyzji.

### `/compact` albo nowa sesja dopiero po fazie

Duży kontekst jest normalnym trybem pracy. Agent nie sugeruje `/compact` ani nowej sesji po analizie, planie, pojedynczym issue albo zwykłym przejściu między implementacją i testami.

Sugestia pojawia się dopiero po zamknięciu nazwanej fazy pracy, na przykład `Faza 5`, `P1 hardening 1/2`, paczki ID typu `F-015`-`F-019` albo bloku tematycznego `Silent failures + Observability`.

Jeśli środowisko wspiera `/compact` (Claude albo Gemini/Sokół), a temat pozostaje ten sam, preferowany jest `/compact`. Nowa sesja ma sens głównie wtedy, gdy zaczyna się osobna faza, inny moduł albo niezależny temat.

## Wymagania

- [Codex CLI](https://github.com/openai/codex)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) **lub** [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- `bash`, `git`
- Docker (jeśli projekt używa kontenerów — Builder robi auto-rebuild po deployu)

## Instalacja

```bash
git clone https://github.com/popek1990/popek-agent-workflow.git /tmp/workflow
bash /tmp/workflow/install.sh /ścieżka/do/twojego/projektu
```

Skrypt jest **idempotentny** i bezpieczny:
- Jeśli plik nie istnieje — tworzy
- Jeśli istnieje, ale bez workflow — dokleja instrukcje na końcu (zachowuje istniejącą treść)
- Jeśli istnieje z workflow — pomija (chyba że dasz `--force`)

Smoketest na końcu instalacji weryfikuje czy wszystkie pliki są na miejscu (markery wersji, struktura katalogów, sekcje TODO.md).

## Co tworzy `install.sh` w projekcie docelowym

| Ścieżka | Co | Z czego |
|---------|----|---------|
| `CLAUDE.md` | Instrukcje dla Claude Code (Sokół) | `sokol.md` |
| `GEMINI.md` | Instrukcje dla Gemini CLI (Sokół) | `sokol.md` |
| `AGENTS.md` | Instrukcje dla Codex CLI (Builder) | `builder.md` |
| `agents_catalog.md` | Snapshot 60+ sub-agentów (Sokół wybiera z tego, nie zmyśla) | `agents_catalog.md` |
| `scripts/notify.sh` | Powiadomienie po deployu (cross-platform popup) | `scripts/notify.sh` |
| `templates/plan_single.md` | Szablon planu — pojedynczy issue | `templates/plan_single.md` |
| `templates/plan_batch.md` | Szablon planu — batch (do 5 powiązanych issues) | `templates/plan_batch.md` |
| `MD/plans/` | Katalog na aktywne plany wdrożeń | (pusty katalog) |
| `MD/archive/` | Katalog na zarchiwizowane plany (po wdrożeniu) | (pusty katalog) |
| `MD/issues_sokol.md` | Tracking issues ze statusami (OPEN / IN_PROGRESS / FIXED / WONTFIX) | stub |
| `MD/memory.md` | Pamięć agentów: zrobione (z linkiem do archive) + odrzucone z uzasadnieniem | stub |
| `MD/TODO.md` | Kolejka zadań: OPEN / DONE / Hygiene | stub |

**Pre-existing pliki:** Jeśli któryś z plików (`MD/TODO.md`, `MD/memory.md`, `MD/issues_sokol.md`) już istnieje w projekcie z innym formatem (np. własna struktura tasków po polsku) — `install.sh` go **zachowuje** bez zmian. Przy `MD/TODO.md` dodatkowo wypisuje inline ostrzeżenie jeśli brakuje standardowych sekcji `OPEN/DONE/Hygiene` (workflow ich używa do trackingu). To **warning, nie błąd** — możesz albo dokleić te sekcje do swojego pliku, albo zarchiwizować stary do `MD/TODO_legacy.md` i odpalić install ponownie żeby dostać świeży template.

## Aktualizacja workflow (`--force`)

Gdy w tym repo pojawią się nowe wersje `builder.md` / `sokol.md`, podmienisz je w docelowym projekcie:

```bash
bash /tmp/workflow/install.sh /ścieżka/do/projektu --force
```

`--force` podmienia **bloki workflow** (od nagłówka `# Instrukcje dla ...` do końca pliku) — ręcznie dopisana treść projektu nad tym blokiem zostaje nietknięta. Skrypt usuwa też duplikaty nagłówka i starsze osadzone sekcje workflow Buildera w `CLAUDE.md`, które nie miały jeszcze nagłówka `# Instrukcje dla ...`.

**Pominięcie bezpieczne:** jeśli `--force` wykryje, że workflow nigdy nie był zainstalowany w tym projekcie (brak markerów `## Twoja rola` w żadnym pliku) — pomija projekt. Ochrona przed przypadkowym nadpisaniem cudzego CLAUDE.md.

**Aktualizacja wielu projektów naraz:** edytuj listę `PROJECTS=(...)` w `update-all.sh` i odpal:

```bash
bash update-all.sh
```

## Szybki start

1. Otwórz dwa terminale w katalogu projektu
2. **Terminal 1:** uruchom `codex` → to Builder
3. **Terminal 2:** uruchom `claude` (lub `gemini`) → to Sokół
4. Zacznij od Sokoła — poproś go o przegląd kodu modułu lub odebranie konkretnego issue z `MD/issues_sokol.md`

## Pełny przykład — od skanu do deployu

Konkretny flow w nowym projekcie. Pokazuje kto co mówi, czego oczekiwać.

**Krok 1 — Ty (orkiestrator) do Sokoła:**

> Przeskanuj moduł `src/cache/`. Szukaj bugów, luk bezpieczeństwa, miejsc gdzie brakuje walidacji.

**Krok 2 — Sokół skanuje, znajduje issue, pisze prompt dla Buildera** (przykładowo):

> Builderze, mamy problem z walidacją inputów w module cache.
> **Źródło:** skan `src/cache/middleware.ts` linia 42
> **Severity:** HIGH
> **Konsekwencje zaniechania:** Bez walidacji `X-Forwarded-Host` atakujący może zatruć cache.
> **Dotknięte pliki:** `src/cache/middleware.ts`, `src/cache/middleware.test.ts`
> **Propozycja:** Guard na początku `getCacheKey()` — allowlista domen.
> **Sugerowany agent:** `security-reviewer` [reviewer po implementacji]
> Zaproponuj plan. Czy widzisz ryzyka?

**Krok 3 — Ty kopiujesz prompt z Sokoła do Buildera.** Builder **nie pisze kodu** — tworzy `MD/plans/plan_cache_host_validation.md`, ocenia propozycję, identyfikuje ryzyka, pisze prompt zwrotny dla Sokoła:

> Sokole, zgadzam się z guardem, ale allowlista powinna być w configu (`src/config.ts`), nie hardcoded. Mitygacja pustej allowlisty: skip jeśli długość 0. Czy akceptujesz dodanie configa? Jeśli tak — zmieniam status planu na GOTOWY DO OCENY.

**Krok 4 — Ty kopiujesz odpowiedź Buildera do Sokoła.** Sokół potwierdza ("Plan jest gotowy do implementacji.") lub kontruje. Ping-pong trwa max 3 rundy.

Gdy Sokół potwierdza gotowość planu, powinien dopisać pod tabelą ludzkie wyjaśnienie: co dokładnie zmieni wdrożenie, jak działa obecny stan, jakie jest ryzyko i jakiej decyzji potrzebuje od Ciebie.

**Krok 5 — Ty dajesz zielone światło Builderowi:** *"OK, wdrażaj."*

**Krok 6 — Builder wdraża sam:** wywołuje `security-reviewer` na kodzie, puszcza testy, robi `git push`, `docker compose up -d --build`, healthcheck, aktualizuje `MD/memory.md` + `MD/TODO.md` + przenosi plan do `MD/archive/`. Kończy promptem zwrotnym dla Sokoła z dowodem (link do commitu).

**Krok 7 — Ty kopiujesz raport Buildera do Sokoła.** Sokół robi **Blind Audit** (sprawdza diff, weryfikuje finalizację: plan w archive, memory linkuje do archive, issues FIXED) i wskazuje kolejne issue → wracamy do kroku 2.

**Co poszło nie tak?** Patrz `workflow.md` → sekcja FAQ.

## Statusy planu

```
DRAFT → W DYSKUSJI → GOTOWY DO OCENY → ZATWIERDZONY → WDROŻONY
```

| Status | Co oznacza |
|--------|-----------|
| **DRAFT** | Builder tworzy plan na podstawie pierwszego promptu Sokoła |
| **W DYSKUSJI** | Ping-pong trwa (max 3 rundy) |
| **GOTOWY DO OCENY** | Oba agenty potwierdziły, czeka na senior-architect (lub pomijamy) |
| **ZATWIERDZONY** | Gotowy do implementacji (po zielonym świetle Orkiestratora) |
| **WDROŻONY** | Kod wdrożony, testy zielone, pushnięty, plan przeniesiony do `MD/archive/` |

Dodatkowo: **WONTFIX** — issue / plan świadomie odrzucony, zapisany w `MD/memory.md` "Odrzucone".

## Pliki w tym repo

| Plik | Opis | Instalowany jako |
|------|------|------------------|
| `builder.md` | Instrukcje dla Codex CLI | `AGENTS.md` |
| `sokol.md` | Instrukcje dla Claude Code/Gemini | `CLAUDE.md` + `GEMINI.md` |
| `agents_catalog.md` | Snapshot 60+ sub-agentów (Sokół wybiera z listy, nie zmyśla nazw) | `agents_catalog.md` |
| `templates/plan_single.md` | Szablon planu — pojedynczy issue | `templates/plan_single.md` |
| `templates/plan_batch.md` | Szablon planu — batch (do 5 powiązanych issues) | `templates/plan_batch.md` |
| `scripts/notify.sh` | Cross-platform powiadomienie (po deployu, przy konfliktach) | `scripts/notify.sh` |
| `workflow.md` | Pełna referencja procesu + FAQ | — (referencja, nie kopiowany) |
| `cel.md` | Skrót dla orkiestratora — co decyduję, co kopiuję | — (dokumentacja publiczna) |
| `install.sh` | Skrypt instalacyjny / aktualizacyjny (`--force`) | — (uruchamiany raz) |
| `update-all.sh` | Aktualizacja workflow we wszystkich projektach naraz | — (lokalny tooling) |
| `README.md` | Ten plik | — |

## FAQ — co gdy coś idzie nie tak

Najczęstsze sytuacje brzegowe — pełne odpowiedzi w `workflow.md` → sekcja "FAQ".

**Sokół zapętla się na tym samym pomyśle mimo NIE od Buildera**
→ Po 3 rundach ping-pongu — STOP, eskalacja do Orkiestratora. Orkiestrator rozstrzyga.

**Senior-architect odrzuca plan**
→ Status wraca do `W DYSKUSJI`, ping-pong z uwagami architecta jako nowym wkładem. Drugi raz odrzucony → Orkiestrator decyduje (`WONTFIX` albo wdrażamy mimo wszystko).

**Plan ZATWIERDZONY, ale zmieniam zdanie**
→ "Wstrzymaj plan X" do Buildera. Zatrzymuje pracę, status → `W DYSKUSJI`. Commity zostają na branchu (lub revert — Twoja decyzja).

**`MD/issues_sokol.md` puchnie do 200+ wierszy**
→ Sokół przenosi `FIXED` / `WONTFIX` do `MD/issues_sokol_archive.md`. Aktywny plik trzyma tylko `OPEN` / `IN_PROGRESS`.

**Sokół pisze zbyt technicznie albo wypisuje "czego nie zrobił"**
→ Wklej mu odpowiedź z powrotem i poproś: "Napisz to dla Orkiestratora prostym językiem: o co chodzi, jak działa teraz, co się zmieni, jakie jest ryzyko i jaka decyzja jest potrzebna". Aktualne instrukcje wymagają takiego stylu.

**Sokół zasugerował agenta którego nie ma w `agents_catalog.md`**
→ Builder nie wywołuje "podobnego" na ślepo. W prompcie zwrotnym pyta Sokoła o poprawioną sugestię z faktycznie istniejących agentów.

**Push się wywalił, rollback też się wywalił**
→ `docker compose down`, `bash scripts/notify.sh "DEPLOY FAIL — wymagana ręczna interwencja"`, STOP. Bez `git push --force`, bez kasowania commitów. Czekamy na Twoją decyzję.

---

Pełny opis procesu z perspektywy orkiestratora: [`cel.md`](./cel.md)
Pełna referencja techniczna: [`workflow.md`](./workflow.md)
