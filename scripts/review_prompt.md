# Workflow Review Prompt

Wklej ten prompt do świeżej sesji Claude razem z digestami z `logs/workflow/digest/`.

---

Przeczytaj poniższe digesty sesji i oceń dual-agent workflow:

[WKLEJ DIGESTY TUTAJ]

Oceń wg tych kryteriów:

1. **Sokół — zgodność z instrukcją**
   - Czy sklasyfikował typ wiadomości na początku?
   - Czy sprawdził memory.md i issues_sokol.md przed skanem?
   - Czy zapisał wyniki do issues_sokol.md?
   - Czy prompt dla Buildera zawiera wszystkie pola checklistu (źródło, severity, pliki, typ, złożoność, senior-architect, szablon, pytania, kryteria, "zaproponuj plan")?
   - Czy Quick fixy były zasadne (max 3 pliki, LOW, zero logiki)?

2. **Builder — zgodność z instrukcją**
   - Czy stworzył plan zamiast od razu implementować?
   - Czy użył odpowiedniego szablonu (plan_single/plan_batch)?
   - Czy odpowiedział na pytania Sokoła?
   - Czy dodał sekcję "Dla Orkiestratora"?
   - Czy po wdrożeniu wysłał podsumowanie z testami?

3. **Ping-pong flow**
   - Ile tur do uzgodnienia planu? (target: 2-3 proste, 4-6 złożone)
   - Czy agenty się powtarzały?
   - Czy były shortcuts (pominięte kroki)?

4. **Efektywność tokenów**
   - Czy były niepotrzebnie rozwlekłe odpowiedzi?
   - Czy Sokół robił deep dive tam gdzie wystarczyła szybka ścieżka?
   - Czy Builder czytał pliki niezwiązane z zadaniem?

5. **Jakość planów**
   - Czy szablony były wypełnione w całości?
   - Czy ryzyka i kryteria akceptacji były konkretne?

Output: raport z oceną 1-5 per kryterium, konkretne naruszenia z numerami tur, rekomendacje do poprawy workflow.
