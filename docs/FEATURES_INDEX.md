# Features Index

Read this first for any feature task. One row per feature. Keep rows to one line.
Maintained under DOC-2 / DOC-3 (`.opencode/rules/feature-docs.md`).

| Feature | Purpose | Doc | Routes | Depends on |
|---------|---------|-----|--------|------------|
| splash | Startup animation, auth/onboarding checks, routing | lib/features/splash/FEATURE.md | /splash | core/local/cache, core/local/secure, core/router, core/responsive, core/theme, core/widgets |
| auth | Sign-in, sign-up, pending approval and employee-status flows | lib/features/auth/FEATURE.md | /login, /signup, /pending | core/network, core/errors, core/local/secure, core/local/cache, core/utils, core/widgets, core/animations, core/responsive, core/theme, core/i18n, core/router, core/di |
| onboarding | First-run intro to 4 modules (Projects, People, Finance, Insights) with animated slides | lib/features/onboarding/FEATURE.md | /onboarding | core/local/cache, core/animations, core/theme, core/router, core/i18n, core/responsive |
| interactions | CRM interactions: list/search, add, edit, delete — Bloc/Cubit holders + presentation widgets (list tab with search, chips, timeline, swipe actions, add/edit bottom sheets) | lib/features/interactions/FEATURE.md | /crm (tab) | core/constants, core/domain/enums, core/helpers, core/services, core/di, core/network, core/errors, core/utils |
| customer_notes | CRM customer notes: list by customer, add, edit, delete — Cubit holders + presentation widgets (thread, composer, edit sheet, delete dialog, skeletons, empty/error states) | lib/features/customer_notes/FEATURE.md | /crm (tab) | core/constants, core/helpers, core/services, core/di, core/network, core/errors, core/utils, core/widgets, core/animations, core/responsive, core/theme, core/i18n |
| opportunities | CRM opportunities: paginated list/search, read-only detail with header, stage stepper, probability ring, tabs, overview, interactions tab, "Log it?" prompt — Bloc/Cubit holders + presentation widgets | lib/features/opportunities/FEATURE.md | /crm, /crm/opportunities/:id | core/constants, core/helpers, core/services, core/di, core/network, core/errors, core/utils |
| crm_shell | CRM module shell — composes opportunities, interactions, customer_notes into one working module with tabbed interface | lib/features/crm_shell/FEATURE.md | /crm, /crm/opportunities/:id | opportunities, interactions, customer_notes, core/animations, core/router, core/di, core/theme, core/i18n |

<!-- Replace the example row with your real features. Run /doc-sync <feature> to generate each FEATURE.md. -->
