# Constants — no string literal as a key, path, or identifier

- ARCH-10 No string literal may be used as a key, path, or identifier, anywhere in `lib/`.
          No exceptions, no "just this once", no private `const` next to the usage.
          The only places such a literal may be written are the constants files:
          `core/constants/*.dart`, and for routes `core/router/route_names.dart` and
          `core/router/route_paths.dart`.
          Covered: JSON/API field names (`ApiKeys`), request body/query/header names, endpoints and
          paths (`Endpoints`), route names and paths (the two route files), storage and cache
          keys, asset paths (`Assets`, `AppLottieAssets`), hero tags (`HeroTags`), analytics/event
          names, platform channel names, environment variable names, and any meaningful repeated
          string or number (`AppConsts`).
          Where: one file per purpose in `core/constants/`. If no file fits, create a new one there.
          Use `abstract final class` with `static const` members (ARCH-7).
          Reference constants everywhere: models, datasources, repositories, router, storage, tests (TEST-7).
          Before adding a constant, check `docs/CORE_MAP.md` and the existing files. Reuse, don't duplicate.

Out of scope for ARCH-10 (other rules own them, do not duplicate them here):

- User-facing text goes to i18n (UI-4), never a constant.
- Layout dimensions (width, height, padding, gap, radius, font size, icon size): RESP-2.
- Durations, curves, and motion numbers: `AppDurations`, `AppCurves`, `AppAnimationConstants` (ANIM-1).
- Developer-only diagnostic text (exception or log messages) is not a key or a path.
