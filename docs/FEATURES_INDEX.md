# Features Index

Read this first for any feature task. One row per feature. Keep rows to one line.
Maintained under DOC-2 / DOC-3 (`.opencode/rules/feature-docs.md`).

| Feature | Purpose | Doc | Routes | Depends on |
|---------|---------|-----|--------|------------|
| splash | Startup animation, auth/onboarding checks, routing | lib/features/splash/FEATURE.md | /splash | core/local/cache, core/local/secure, core/router, core/responsive, core/theme, core/widgets |
| auth | Sign-in, sign-up, pending approval and employee-status flows | lib/features/auth/FEATURE.md | /login, /signup, /pending | core/network, core/errors, core/local/secure, core/local/cache, core/utils, core/widgets, core/animations, core/responsive, core/theme, core/i18n, core/router, core/di |
| onboarding | First-run intro to 4 modules (Projects, People, Finance, Insights) with animated slides | lib/features/onboarding/FEATURE.md | /onboarding | core/local/cache, core/animations, core/theme, core/router, core/i18n, core/responsive |
| interactions | CRM interactions: list/search, add, edit, delete — Bloc/Cubit holders only (no screens yet) | lib/features/interactions/FEATURE.md | none yet | core/constants, core/domain/enums, core/helpers, core/services, core/di, core/network, core/errors, core/utils |
| customer_notes | CRM customer notes: list by customer, add, edit, delete — Cubit holders only (no screens yet) | lib/features/customer_notes/FEATURE.md | none yet | core/constants, core/helpers, core/services, core/di, core/network, core/errors, core/utils |
| opportunities | CRM opportunities: paginated list/search, read-only detail — Bloc/Cubit holders only (no screens yet) | lib/features/opportunities/FEATURE.md | none yet | core/constants, core/helpers, core/services, core/di, core/network, core/errors, core/utils |

<!-- Replace the example row with your real features. Run /doc-sync <feature> to generate each FEATURE.md. -->
