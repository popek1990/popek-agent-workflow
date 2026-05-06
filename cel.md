# Workflow: Dual-Agent Vibe-Coding

Pracuję w terminalu z dwoma agentami AI działającymi na tym samym repozytorium. Ja (orkiestrator) zarządzam przepływem informacji między nimi.

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

### Sokół (Gemini / Codex) — analityk i doradca

- Szuka pomysłów i ulepszeń
- Znajduje błędy, luki bezpieczeństwa
- Myśli głęboko przy skomplikowanych tematach
- Tworzy plany dla nowych funkcji
- **Nigdy nie robi push na GitHub** (chyba że wyraźnie poproszę)

---

## Orkiestrator (ja)

- Kopiuję prompty między agentami (ręcznie)
- Decyduję, kiedy plan jest gotowy do wdrożenia
- Daję zielone światło na zmiany w kodzie
- Chcę rozumieć każdy etap — wymagam opisów prostymi słowami

---

## Workflow krok po kroku

### Faza 1: Analiza (Sokół)

1. Uruchamiam Sokoła z zadaniem (np. znajdź błędy, zaproponuj ulepszenie, stwórz plan)
2. Sokół analizuje i przygotowuje wyniki
3. Sokół pisze **prompt dla Klaudiusza**, który zawiera:
   - Jaki problem znalazł
   - Opis problemu / planu
   - Pytanie czy Klaudiusz się zgadza (jeśli nie — wymaga argumentu dlaczego)
   - Pytanie o ryzyka w implementacji i jak je rozwiązać

### Faza 2: Burza mózgów (ping-pong)

4. Ja kopiuję prompt Sokoła → wklejam do Klaudiusza
5. Klaudiusz **nie rusza kodu** — zamiast tego:
   - Tworzy plan w pliku `plan_nazwa_wdrożenia.md`
   - Jeśli się zgadza z Sokołem — potwierdza
   - Jeśli się nie zgadza — pisze dlaczego
   - Jeśli rozwiązałby inaczej — pisze jak i dlaczego
6. Klaudiusz pisze **prompt zwrotny dla Sokoła** (po polsku, wypisany w terminalu)
7. Ja kopiuję prompt Klaudiusza → wklejam do Sokoła
8. Sokół odpowiada i powtarzamy proces (kroki 4–7)
9. **Kończymy gdy plan satysfakcjonuje obu agentów**

### Faza 3: Ocena architektury

10. Klaudiusz wywołuje agenta `@/a/senior-architect/`
11. Agent ocenia plan:
    - Brak zastrzeżeń → przechodzimy do wdrożenia
    - Są zastrzeżenia → wracamy do burzy mózgów (krok 4)

### Faza 4: Wdrożenie

12. Klaudiusz wdraża plan (po moim zielonym świetle)

### Faza 5: Code review i auto-deploy

13. Klaudiusz wywołuje `/code-review`
14. Gdy review przechodzi bez błędów, Klaudiusz **sam** (bez pytania o zgodę):
    - Robi `git push` na GitHub
    - Robi `docker compose up -d --build` (rebuild + deploy)
    - Edytuje `CLAUDE.md` (jeśli potrzeba)
    - Edytuje pliki referencyjne (jeśli potrzeba)
    - Edytuje README (jeśli potrzeba)
    - Oznacza task jako DONE w `todo.md` (jeśli istnieje)

> **Zasada:** Jeśli testy przeszły i code review jest zielony — Klaudiusz nie czeka na zgodę. Sam pushuje i rebuilduję Dockera.

### Faza 6: Prompt zwrotny do Sokoła

15. Po zakończeniu wdrożenia Klaudiusz pisze **prompt dla Sokoła** (po polsku, w terminalu):
    - Co zostało zrobione (podsumowanie zmian)
    - Jakie testy przeszły
    - Czy deploy się powiódł
    - **Pytanie:** jaki jest kolejny etap planu / co dalej?
16. Ja kopiuję ten prompt → wklejam do Sokoła
17. Sokół odpowiada z kolejnym zadaniem → wracamy do Fazy 1

---

## Po git push — synchronizacja kodu

Po każdym `git push` orkiestrator (ja) instaluje nową wersję kodu w środowisku, aby **oba okna** (Klaudiusz i Sokół) widziały aktualny stan repozytorium.

---

## Zasady komunikacji

Pod każdym promptem (niezależnie od fazy) chcę opis prostymi słowami:

- **Co to jest** — poprawka / błąd / ulepszenie / nowa funkcja
- **Jak działa teraz** — obecne zachowanie
- **Co się zmieni** — proponowana zmiana
- **Jakie są ryzyka** — co może pójść nie tak
- **Jaki jest zysk** — dlaczego warto to zrobić

Nie jestem aż tak techniczny — chcę mieć pełną decyzyjność na każdym etapie.
