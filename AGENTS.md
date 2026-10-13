# Flutter Project — Agent Entry Point

Stack: Flutter (Dart 3+), feature-first Clean Architecture, Cubit/Bloc, get_it,
go_router, dio behind `BaseApiClient`, slang, `ApiResult<T>`.
No Freezed, no build_runner, no code generation except `dart run slang`.

This file is the index. Detailed rules live in `.opencode/rules/`.
`00-core.md` is always loaded. Every other rule file MUST be read before coding
when the routing table below requires it.

Reference feature (mirror its structure and style): `lib/features/auth` (if exists)
<!-- Change the path above if your best-structured feature has another name. -->

## 1. Hard rules (apply to every task, never violated)

- H-1  Never modify `pubspec.yaml`, `analysis_options.yaml`, generated files
       (`*.g.dart`, slang output), `android/`, `ios/`, `.env*` without explicit approval.
- H-2  Never add a package. Propose it and wait for approval.
- H-3  Never rename, move, or delete files without explicit instruction.
       Never `git commit` / `git push` unless asked.
- H-4  Presentation → Domain → Data. Domain never imports `package:flutter`.
       Cubit/Bloc depends on usecases only.
- H-5  No hardcoded user-facing string, no hardcoded color/text style,
       no `Navigator.push`, no `dio` outside the API client implementation.
- H-6  Never guess a file path, class name, or API. Search or ask.
- H-7  Smallest change that solves the problem. No drive-by refactoring.
- H-8  Any change to a feature updates that feature's `FEATURE.md` in the same task.
- H-9  If a request conflicts with a rule, name the rule ID and ask. Never override silently.

## 2. Before writing any code (mandatory order)

1. Classify the task using the routing table.
2. Read `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
   Open source files only after that, and only the ones you need.
3. Read every rule file listed for the task type. If several types apply, read the union.
4. When creating something new, read the reference feature first.
5. Print one line before the first edit: `Rules loaded: <file names>`.

## 3. Routing table

| Task type                                                          | Read these rule files (in `.opencode/rules/`)                                                               |
|--------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| New feature                                                        | architecture, domain-and-errors, data-layer, state-management, ui, di-and-navigation, testing, feature-docs |
| New screen / widget / UI change                                    | ui, state-management, feature-docs                                                                          |
| Cubit / Bloc / state change                                        | state-management, domain-and-errors, testing, feature-docs                                                  |
| UseCase / entity / params / repository contract                    | domain-and-errors, architecture, testing, feature-docs                                                      |
| API / datasource / model / mapper / repo impl / cache / pagination | data-layer, domain-and-errors, testing, feature-docs                                                        |
| DI registration / route / navigation                               | di-and-navigation, feature-docs                                                                             |
| Bug fix                                                            | rule files of every layer you touch + testing + feature-docs                                                |
| Add or change translations only                                    | ui (section Localization), feature-docs                                                                     |
| Change inside `core/`                                              | architecture, data-layer (if network/local), feature-docs (update `docs/CORE_MAP.md`)                       |
| Tests only                                                         | testing                                                                                                     |
| Docs only                                                          | feature-docs                                                                                                |

## 4. Skills (load with the `skill` tool BEFORE the work they cover)

Skills live in `.opencode/skills/`. Rules always win over skills (a skill never overrides a rule ID).

| Situation                                              | Load skill                                   |
|--------------------------------------------------------|----------------------------------------------|
| Writing or editing any code                            | `clean-code`                                 |
| Designing or growing a class, Cubit, repo, service     | `solid-principles`                           |
| Deciding where code goes, layer or import questions    | `clean-architecture`                         |
| After ANY change to a feature, or FEATURE.md missing   | `feature-doc`                                |
| New feature from scratch                               | `feature-scaffold` (+ `write-tests`, `feature-doc`) |
| New API call in an existing feature                    | `add-endpoint` (+ `write-tests`, `feature-doc`) |
| Adding or changing behavior, or any test work          | `write-tests`                                |
| Bug, crash, wrong behavior, failing test               | `debugging`                                  |
| User explicitly asks to refactor / restructure         | `refactoring`                                |
| User asks for a review of a diff or PR                 | `code-review`                                |
| Slow, janky, memory, or "optimize"                     | `performance-audit`                          |
| Auth, tokens, personal data, deep links, WebView       | `security-review`                            |
| Task seems to need a new package                       | `package-evaluation`                         |
| User asks to commit, name a branch, or write a PR text | `git-workflow`                               |
| Preparing a build for testers or the stores            | `release-readiness`                          |

Print one extra line next to `Rules loaded:` →  `Skills loaded: <names>` (or `Skills loaded: none`).



## 5. Commands (use them — they enforce the process)

| Command                  | Use when                                                          |
|--------------------------|-------------------------------------------------------------------|
| `/feature <name+desc>`   | Building a new feature end to end                                 |
| `/change <feature+desc>` | Modifying an existing feature                                     |
| `/fix <feature+bug>`     | Fixing a bug (regression test first)                              |
| `/review`                | Reviewing the current diff against all rules (read-only subagent) |
| `/doc-sync <feature>`    | Creating or repairing a `FEATURE.md` from the code                |

## 6. Done means

Defined in `00-core.md` section G. Short form: format → analyze → tests →
slang (if i18n changed) → FEATURE.md updated → self-review. A failed step means
the task is not done. Never claim a check passed without running it.
