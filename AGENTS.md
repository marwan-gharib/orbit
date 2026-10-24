# Flutter Project — Agent Entry Point

Stack: Flutter (Dart 3+), feature-first Clean Architecture, Cubit/Bloc, get_it,
go_router, dio behind `BaseApiClient`, slang, `ApiResult<T>`.
No Freezed, no build_runner, no code generation except `dart run slang`.
The whole app is built on one base: `lib/core/` (widgets, animations, responsive, theme, network...).

This file is the index. Detailed rules live in `.opencode/rules/` (guide: `.opencode/README.md`).
Always loaded (via `opencode.json`): `00-core`, `00-style`, `00-done`, `core-first`, `file-size`,
`release-notes`. Every other rule file MUST be read before coding when the routing table requires it.

Reference feature (mirror its structure and style): `lib/features/auth` (if exists).
If that folder does not exist, mirror the newest completed feature in `docs/FEATURES_INDEX.md`.

## 1. Hard rules (apply to every task, never violated)

- H-1  Never modify `pubspec.yaml`, `analysis_options.yaml`, generated files
       (`*.g.dart`, slang output), `android/`, `ios/`, `.env*` without explicit approval.
- H-2  Never add a package. Propose it and wait for approval.
- H-3  Never rename, move, or delete files without explicit instruction (only exceptions:
       WIDGET-3 promotion, FILE-2 splitting). Never run `git commit` / `git push` (denied in
       `opencode.json`); when asked, prepare the message or PR text with the `git-workflow`
       skill and let the user run git.
- H-4  Presentation → Domain → Data. Domain never imports `package:flutter`.
       Cubit/Bloc depends on usecases only.
- H-5  No hardcoded user-facing string, no hardcoded color/text style,
       no `Navigator.push`, no `dio` import outside `core/network/` and the Dio error
       classifier in `core/errors/`.
- H-6  Never guess a file path, class name, parameter name, or API. Search, read, or ask.
- H-7  Smallest change that solves the problem. No drive-by refactoring (only exceptions:
       BASE-5 additive core extension, WIDGET-3 promotion, FILE-2 splitting).
- H-8  Any change to a feature updates that feature's `FEATURE.md` in the same task.
- H-9  If a request conflicts with a rule, name the rule ID and ask. Never override silently.
- H-10 No string literal as a key, path, or identifier. Every API/JSON field name, query/body/header
       name, endpoint, storage/cache key, asset path, hero tag, env variable name, and event name
       MUST be a constant in `core/constants/` (ApiKeys, Endpoints, Assets, AppLottieAssets,
       AppConsts, HeroTags, ... one file per purpose); route names and paths live in
       `core/router/route_names.dart` and `route_paths.dart`. A literal may be written only
       inside those files. No exceptions. Full rule: ARCH-10 (`constants.md`).
- H-11 Core first, in EVERY layer. Before writing any code read `docs/CORE_MAP.md` and the core
       files you will use, and build on them. Never re-implement, copy, or bypass a core piece.
       Print the `Core reuse:` / `Core gap:` line. Full rules: BASE-1..6 (`core-first.md`).
- H-12 Responsive UI. Every dimension is a theme token or goes through `core/responsive/`: no bare
       numbers, no `MediaQuery` size math, no scaling package outside core. Full: RESP (`responsive.md`).
- H-13 Motion only from `core/animations/`. No custom animation and no raw animation, overlay,
       haptic, or Lottie API in a feature. Nothing fits → compose, else stop and ask.
       Full: ANIM (`animations.md`).
- H-14 Widgets: `core/widgets/` first. A widget core lacks is created in the feature that needs it;
       when a second feature needs it, promote it to `core/widgets/` and generalize it.
       Full: WIDGET (`widgets.md`).
- H-15 No file over 300 lines (code, docs, config; generated files excepted). Split before you
       finish. Full: FILE (`file-size.md`).
- H-16 After every tester-visible change update `testers_release_note.txt`, written for the tester
       (what to test), never for the developer (what files changed). Full: NOTES (`release-notes.md`).

## 2. Before writing any code (mandatory order)

1. Classify the task using the routing table.
2. Read `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
   Open source files only after that, and only the ones you need.
3. Read `docs/CORE_MAP.md` and the core files you will use (BASE-1).
4. Read every rule file listed for the task type. If several types apply, read the union.
5. When creating something new, read the reference feature first.
6. Load the skills required by section 4, then print before the first edit (CORE-5):
   `Rules loaded:` / `Skills loaded:` / `Core reuse:` (or `Core gap:`).

## 3. Routing table

| Task type | Read these rule files (in `.opencode/rules/`, besides the always-loaded ones) |
|---|---|
| New feature | architecture, folder-structure, constants, domain-and-errors, data-layer, state-management, ui-foundation, ui-layout, widgets, responsive, animations, di-and-navigation, testing, feature-docs |
| New screen / widget / UI change | ui-foundation, ui-layout, widgets, responsive, animations, state-management, constants, testing, feature-docs |
| Animation, transition, loading state, dialog, sheet, snackbar | animations, responsive, widgets, ui-foundation, feature-docs |
| Promote a feature widget to core | widgets, architecture, folder-structure, testing, feature-docs |
| Cubit / Bloc / state change | state-management, domain-and-errors, testing, feature-docs |
| UseCase / entity / params / repository contract | domain-and-errors, architecture, testing, feature-docs |
| API / datasource / model / repo impl / cache / pagination | data-layer, domain-and-errors, constants, testing, feature-docs |
| DI registration / route / navigation | di-and-navigation, constants, animations, feature-docs |
| New or changed constant (key, endpoint, route, asset) | constants, feature-docs |
| Bug fix | rule files of every layer you touch + testing + feature-docs |
| Add or change translations only | ui-foundation (Localization), feature-docs |
| Change inside `core/` | architecture, folder-structure, constants, the area's file (widgets / animations / responsive / data-layer), testing, feature-docs |
| Tests only | testing |
| Docs only | feature-docs |

## 4. Skills (load with the `skill` tool BEFORE the work they cover)

Skills live in `.opencode/skills/`. Rules always win over skills (a skill never overrides a rule ID).

| Situation | Load skill |
|---|---|
| Writing or editing any code | `clean-code` |
| Building or changing UI (screen, widget, layout, animation) | `ui-from-core` |
| Designing or growing a class, Cubit, repo, service | `solid-principles` |
| Deciding where code goes, layer or import questions | `clean-architecture` |
| After ANY change to a feature, or FEATURE.md missing | `feature-doc` |
| After ANY tester-visible change | `tester-release-notes` |
| New feature from scratch | `feature-scaffold` (+ `ui-from-core`, `write-tests`, `feature-doc`) |
| New API call in an existing feature | `add-endpoint` (+ `write-tests`, `feature-doc`) |
| Adding or changing behavior, or any test work | `write-tests` |
| Bug, crash, wrong behavior, failing test | `debugging` |
| User explicitly asks to refactor / restructure / split a file | `refactoring` |
| User asks for a review of a diff or PR | `code-review` |
| Slow, janky, memory, or "optimize" | `performance-audit` |
| Auth, tokens, personal data, deep links, WebView | `security-review` |
| Task seems to need a new package | `package-evaluation` |
| User asks to commit, name a branch, or write a PR text | `git-workflow` |
| Preparing a build for testers or the stores | `release-readiness` |

## 5. Commands (use them — they enforce the process)

| Command | Use when |
|---|---|
| `/feature <name+desc>` | Building a new feature end to end |
| `/screen <feature+desc>` | Building or reshaping a screen from core widgets, animations, responsive |
| `/change <feature+desc>` | Modifying an existing feature |
| `/fix <feature+bug>` | Fixing a bug (regression test first) |
| `/core-check <what you need>` | Before building: which core pieces to reuse, what is missing (read-only) |
| `/promote-widget <widget>` | A second feature needs a feature widget: move it to core and generalize |
| `/tests <feature>` | Adding missing tests to an existing feature |
| `/check` | Running the Definition of Done checks and the rules script |
| `/file-size [path]` | Auditing files over 300 lines, and splitting one on request |
| `/audit <feature or path>` | Auditing existing code against the rules (read-only) |
| `/review` | Reviewing the current diff against all rules (read-only subagent) |
| `/release-notes [new]` | Syncing `testers_release_note.txt`, or starting a new cycle |
| `/pr` | Commit message, branch name, and PR text for the current diff |
| `/doc-sync <feature>` | Creating or repairing a `FEATURE.md` from the code |

## 6. Done means

Defined in `00-done.md` section G. Short form: format → analyze → tests → slang (if i18n changed)
→ docs → rules script and file size → tester release note → self-review → `@reviewer` for big
changes. A failed step means the task is not done. Never claim a check passed without running it.
