# Agents Catalog — popek-agent-workflow

Lokalny katalog agentów dostępnych dla Klaudiusza (Claude Code) w tym workflow. **Sokół (Gemini/Codex) — czytaj TEN plik gdy wybierasz "Sugerowany agent" do promptu.** Nie zmyślaj nazw, nie zgaduj — wybór TYLKO z tej listy.

**Liczba agentów:** 60
**Źródło:** [agents.popeklab.com](https://agents.popeklab.com/) (snapshot)

---

## Mapowanie domena → agent (skrót)

Pełne tabele decyzyjne — patrz `sokol.md` sekcja "Wybór agenta dla Klaudiusza".

| Domena | Sugerowani |
|--------|------------|
| Python | `python-reviewer`, `silent-failure-hunter`, skill `modern-python` |
| TypeScript / JS | `typescript-reviewer`, `code-reviewer` |
| Go | `go-reviewer`, `go-build-resolver` |
| Rust | `rust-reviewer`, `rust-build-resolver` |
| Postgres / DB | `database-reviewer`, skill `database-postgreSQL` |
| Security / auth | `security-reviewer`, `python-reviewer` |
| Architecture | `senior-architect`, `architect`, `code-architect` |
| Frontend | `senior-frontend`, skill `frontend-claude-official` |
| DevOps / CI | `senior-devops` |
| Boty / silent failures | `silent-failure-hunter` |
| TDD / testing | `tdd-guide` |
| Performance | `performance-optimizer` |
| Refactor / hygiene | `code-simplifier`, `refactor-cleaner` |
| Documentation | `doc-updater`, skill `readme-gh` |
| Build errors | `build-error-resolver` (TS), `*-build-resolver` (per język) |
| Accessibility | `a11y-architect` |
| Healthcare | `healthcare-reviewer` |
| Aqua orchestration (debata) | `aqua-combo` (lokalny) |

---

## Reviewerzy języków programowania

### `code-reviewer` (agent)

Expert code review specialist for TypeScript, JavaScript, Python, Swift, Kotlin, Go.

**Wywołanie:** `Task subagent_type=code-reviewer`

### `cpp-reviewer` (agent)

Expert C++ code reviewer specializing in memory safety, modern C++ idioms, concurrency.

**Wywołanie:** `Task subagent_type=cpp-reviewer`

### `csharp-reviewer` (agent)

Expert C# code reviewer specializing in .NET conventions, async patterns, security.

**Wywołanie:** `Task subagent_type=csharp-reviewer`

### `flutter-reviewer` (agent)

Flutter and Dart code reviewer for widget best practices and state management.

**Wywołanie:** `Task subagent_type=flutter-reviewer`

### `go-reviewer` (agent)

Expert Go code reviewer specializing in idiomatic Go, concurrency, error handling.

**Wywołanie:** `Task subagent_type=go-reviewer`

### `java-reviewer` (agent)

Expert Java and Spring Boot code reviewer for layered architecture, JPA, security.

**Wywołanie:** `Task subagent_type=java-reviewer`

### `kotlin-reviewer` (agent)

Kotlin and Android/KMP code reviewer for idiomatic patterns, coroutine safety, Compose.

**Wywołanie:** `Task subagent_type=kotlin-reviewer`

### `python-reviewer` (agent)

Expert Python code reviewer for PEP 8 compliance, Pythonic idioms, type hints, security.

**Wywołanie:** `Task subagent_type=python-reviewer`

### `rust-reviewer` (agent)

Expert Rust code reviewer for ownership, lifetimes, error handling, unsafe usage.

**Wywołanie:** `Task subagent_type=rust-reviewer`

### `typescript-reviewer` (agent)

Expert TypeScript/JavaScript code reviewer for type safety, async correctness, security.

**Wywołanie:** `Task subagent_type=typescript-reviewer`


## Build/Compile resolvers

### `cpp-build-resolver` (agent)

C++ build, CMake, and compilation error resolution specialist.

**Wywołanie:** `Task subagent_type=cpp-build-resolver`

### `dart-build-resolver` (agent)

Dart/Flutter build, analysis, and dependency error resolution specialist.

**Wywołanie:** `Task subagent_type=dart-build-resolver`

### `go-build-resolver` (agent)

Go build, vet, and compilation error resolution specialist.

**Wywołanie:** `Task subagent_type=go-build-resolver`

### `java-build-resolver` (agent)

Java/Maven/Gradle build, compilation, and dependency error resolution specialist.

**Wywołanie:** `Task subagent_type=java-build-resolver`

### `kotlin-build-resolver` (agent)

Kotlin/Gradle build, compilation, and dependency error resolution specialist.

**Wywołanie:** `Task subagent_type=kotlin-build-resolver`

### `pytorch-build-resolver` (agent)

PyTorch runtime, CUDA, and training error resolution specialist.

**Wywołanie:** `Task subagent_type=pytorch-build-resolver`

### `rust-build-resolver` (agent)

Rust build, compilation, and dependency error resolution specialist.

**Wywołanie:** `Task subagent_type=rust-build-resolver`


## Senior specjaliści (multi-domain)

### `senior-architect` (agent)

Comprehensive software architecture skill with diagrams, patterns, and dependency analysis.

**Wywołanie:** `Task subagent_type=senior-architect`

### `senior-backend` (agent)

Comprehensive backend development: Node.js, Express, Go, Python, Postgres, GraphQL.

**Wywołanie:** `Task subagent_type=senior-backend`

### `senior-devops` (agent)

Comprehensive DevOps: CI/CD, infrastructure automation, containerization, cloud platforms.

**Wywołanie:** `Task subagent_type=senior-devops`

### `senior-frontend` (agent)

Comprehensive frontend development: React, Next.js, TypeScript, Tailwind CSS.

**Wywołanie:** `Task subagent_type=senior-frontend`

### `senior-prompt-engineer` (agent)

World-class prompt engineering: LLM optimization, prompt patterns, RAG, agent design.

**Wywołanie:** `Task subagent_type=senior-prompt-engineer`


## GAN (multi-agent loops)

### `gan-evaluator` (agent)

GAN Harness — Evaluator agent. Tests live app via Playwright and scores against rubric.

**Wywołanie:** `Task subagent_type=gan-evaluator`

### `gan-generator` (agent)

GAN Harness — Generator agent. Implements features and iterates on evaluator feedback.

**Wywołanie:** `Task subagent_type=gan-generator`

### `gan-planner` (agent)

GAN Harness — Planner agent. Expands prompts into full product specifications.

**Wywołanie:** `Task subagent_type=gan-planner`


## Open-source pipeline

### `opensource-forker` (agent)

Fork any project for open-sourcing. Strips secrets, replaces internal references.

**Wywołanie:** `Task subagent_type=opensource-forker`

### `opensource-packager` (agent)

Generate complete open-source packaging: README, LICENSE, CONTRIBUTING, setup.sh.

**Wywołanie:** `Task subagent_type=opensource-packager`

### `opensource-sanitizer` (agent)

Verify an open-source fork is fully sanitized before release. Scans for leaked secrets/PII.

**Wywołanie:** `Task subagent_type=opensource-sanitizer`


## Skille (prefiks `skill ` w prompcie)

### `brainstorming` (skill)

Design-before-code: explores intent, proposes approaches, writes spec. Blocks implementation until design approved.

**Wywołanie:** `Skill skill=brainstorming` lub `/brainstorming`

### `database-postgreSQL` (skill)

Postgres performance optimization and best practices from Supabase. Query performance, connection pooling, RLS, schema design, EXPLAIN analysis.

**Wywołanie:** `Skill skill=database-postgreSQL` lub `/database-postgreSQL`

### `frontend-claude-official` (skill)

Create distinctive, production-grade frontend interfaces with high design quality. Avoids generic AI aesthetics.

**Wywołanie:** `Skill skill=frontend-claude-official` lub `/frontend-claude-official`

### `html` (skill)

Build complex HTML artifacts with React 18, TypeScript, Tailwind CSS, shadcn/ui. Bundles to single HTML file.

**Wywołanie:** `Skill skill=html` lub `/html`

### `ksiegowosc` (skill)

345 tax/accounting skills: US federal/state, international VAT/CT, cross-border. Conservative defaults, Excel output, reviewer model.

**Wywołanie:** `Skill skill=ksiegowosc` lub `/ksiegowosc`

### `readme-gh` (skill)

Generate thorough README.md: local setup, architecture, deployment, API docs.

**Wywołanie:** `Skill skill=readme-gh` lub `/readme-gh`

### `xlsx` (skill)

Read, write, edit Excel and tabular files (.xlsx, .xlsm, .csv, .tsv). Formula verification via LibreOffice.

**Wywołanie:** `Skill skill=xlsx` lub `/xlsx`


## Pozostałe agenty

### `a11y-architect` (agent)

Accessibility Architect specializing in WCAG 2.2 compliance for Web and Native platforms.

**Wywołanie:** `Task subagent_type=a11y-architect`

### `architect` (agent)

Software architecture specialist for system design, scalability, and technical decision-making.

**Wywołanie:** `Task subagent_type=architect`

### `build-error-resolver` (agent)

Build and TypeScript error resolution specialist. Fixes build/type errors with minimal diffs.

**Wywołanie:** `Task subagent_type=build-error-resolver`

### `chief-of-staff` (agent)

Personal communication chief of staff that triages email, Slack, LINE, and Messenger.

**Wywołanie:** `Task subagent_type=chief-of-staff`

### `code-architect` (agent)

Designs feature architectures by analyzing existing codebase patterns and conventions.

**Wywołanie:** `Task subagent_type=code-architect`

### `code-explorer` (agent)

Deeply analyzes existing codebase features by tracing execution paths and mapping architecture.

**Wywołanie:** `Task subagent_type=code-explorer`

### `code-simplifier` (agent)

Simplifies and refines code for clarity, consistency, and maintainability.

**Wywołanie:** `Task subagent_type=code-simplifier`

### `comment-analyzer` (agent)

Analyze code comments for accuracy, completeness, maintainability, and comment rot risk.

**Wywołanie:** `Task subagent_type=comment-analyzer`

### `conversation-analyzer` (agent)

Analyzes conversation transcripts to find behaviors worth preventing with hooks.

**Wywołanie:** `Task subagent_type=conversation-analyzer`

### `database-reviewer` (agent)

PostgreSQL database specialist for query optimization, schema design, security.

**Wywołanie:** `Task subagent_type=database-reviewer`

### `doc-updater` (agent)

Documentation and codemap specialist for updating codemaps and documentation.

**Wywołanie:** `Task subagent_type=doc-updater`

### `docs-lookup` (agent)

Fetches current documentation via Context7 MCP for library/framework/API questions.

**Wywołanie:** `Task subagent_type=docs-lookup`

### `e2e-runner` (agent)

End-to-end testing specialist using Vercel Agent Browser with Playwright fallback.

**Wywołanie:** `Task subagent_type=e2e-runner`

### `harness-optimizer` (agent)

Analyze and improve local agent harness configuration for reliability, cost, throughput.

**Wywołanie:** `Task subagent_type=harness-optimizer`

### `healthcare-reviewer` (agent)

Reviews healthcare application code for clinical safety, CDSS accuracy, PHI compliance.

**Wywołanie:** `Task subagent_type=healthcare-reviewer`

### `loop-operator` (agent)

Operate autonomous agent loops, monitor progress, and intervene when loops stall.

**Wywołanie:** `Task subagent_type=loop-operator`

### `performance-optimizer` (agent)

Performance analysis and optimization: bottlenecks, bundle size, memory leaks.

**Wywołanie:** `Task subagent_type=performance-optimizer`

### `planner` (agent)

Expert planning specialist for complex features and refactoring.

**Wywołanie:** `Task subagent_type=planner`

### `pr-test-analyzer` (agent)

Review pull request test coverage quality and completeness.

**Wywołanie:** `Task subagent_type=pr-test-analyzer`

### `refactor-cleaner` (agent)

Dead code cleanup and consolidation specialist using knip, depcheck, ts-prune.

**Wywołanie:** `Task subagent_type=refactor-cleaner`

### `security-reviewer` (agent)

Security vulnerability detection: SSRF, injection, unsafe crypto, OWASP Top 10.

**Wywołanie:** `Task subagent_type=security-reviewer`

### `seo-specialist` (agent)

SEO specialist for technical audits, structured data, Core Web Vitals, keyword mapping.

**Wywołanie:** `Task subagent_type=seo-specialist`

### `silent-failure-hunter` (agent)

Review code for silent failures, swallowed errors, bad fallbacks.

**Wywołanie:** `Task subagent_type=silent-failure-hunter`

### `tdd-guide` (agent)

Test-Driven Development specialist enforcing write-tests-first with 80%+ coverage.

**Wywołanie:** `Task subagent_type=tdd-guide`

### `type-design-analyzer` (agent)

Analyze type design for encapsulation, invariant expression, and enforcement.

**Wywołanie:** `Task subagent_type=type-design-analyzer`


## Lokalne agenty (poza katalogiem popeklab.com)

### `aqua-combo` (agent)

Research-to-execution pipeline orchestrating Plan Mode, subagents with worktree isolation, adversarial debate, and smart clarification. Plan deeply, build once. **Trigger:** non-trivial implementations (>50 LOC) where approach is unclear, refactors with regression risk.

**Wywołanie:** `Task subagent_type=aqua-combo`
