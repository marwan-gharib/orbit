# Core First — every layer is built on `lib/core/` (always loaded)

`lib/core/` is the single base of the whole app. Every feature, in every layer, is built on it.
`docs/CORE_MAP.md` is the index of what exists. This file is why the app stays uniform.

- BASE-1  Before writing ANY code (presentation, domain, data, DI, router, tests), in this order:
          1. Read `docs/CORE_MAP.md`.
          2. Open the core files you are about to use. Start with the barrels and cheat sheets:
             `core/widgets/widgets.dart`, `core/animations/animations.dart` and
             `core/animations/README.md`, `core/responsive/responsive.dart`. Learn the real API.
             Never guess a class, method, or parameter name (CORE-7).
          3. Search core for anything else that looks like the need: `grep -ril <keyword> lib/core`.
          4. Print the `Core reuse:` / `Core gap:` line (CORE-5).
- BASE-2  What each layer takes from core:

  | Layer         | Take from core                                                                 |
  |---------------|--------------------------------------------------------------------------------|
  | Presentation  | `core/widgets` (components), `core/animations` (all motion, overlays, loading, page transitions), `core/responsive` (sizes), `core/theme` (`context.colors`, `context.textStyles`, `AppSpacing`, `AppRadius`), `core/extensions` (`BuildContext` helpers, `context.failureText`), `core/i18n` (`context.t`), `core/constants`, route constants in `core/router/` |
  | Domain        | `core/utils` (`ApiResult`, `PagedResult`), `core/errors` (`Failure`)            |
  | Data          | `core/network` (`BaseApiClient`), `core/errors` (error mapping), `core/local/cache` and `core/local/secure` abstractions, `core/utils` (`Logger`, `Validators`), `core/constants` (`ApiKeys`, `Endpoints`) |
  | DI / router   | `core/di` (`injection_container.dart` and the module pattern), `core/router` (`AppRoute.create`, guards, route constants) |
  | Tests         | Shared test helpers already under `test/` (search first), mocks of core abstractions |

- BASE-3  Use what exists exactly as designed. Never re-implement, copy, wrap, or fork a core
          piece inside a feature. Never bypass it with the raw SDK or package equivalent when
          `docs/CORE_MAP.md` lists a core component for the job. Examples: `AppButton` not
          `ElevatedButton`, `AppTextField` not `TextField`, `AppCard` not `Card`,
          `showAppDialog` / `AppDialog` not `showDialog` / `AlertDialog`, `AppSnackbar` not
          `SnackBar`, `EmptyState` / `ErrorState` not hand-built empty or error screens.
- BASE-4  If core has no such piece:
          - UI widget → create it inside the feature that needs it (WIDGET-2).
          - Animation or motion → ANIM-3 (compose from core; if impossible, stop and ask).
          - Non-UI code (helper, validator, formatter) → create it in the feature; when a second
            feature needs it, promote it to `core/` with the same steps as WIDGET-3 (ARCH-4).
          - Anything that needs a new package → `package-evaluation` skill, then wait (H-2).
- BASE-5  If a core piece almost fits, extend it, never fork it. Allowed only when additive: a new
          optional parameter or variant, defaults keep every existing caller unchanged, tests are
          added, and `docs/CORE_MAP.md` (plus the area's README, if any) is updated. Anything that
          changes existing behavior or could break a caller → ask first.
- BASE-6  Design tokens are changed only on explicit request: theme colors and text styles,
          `AppSpacing`, `AppRadius`, `AppDurations`, `AppCurves`, `AppAnimationConstants`, the
          responsive engine. If a needed token does not exist, ask. Never hardcode a stand-in value.
