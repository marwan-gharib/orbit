# Features Index

Read this first for any feature task. One row per feature. Keep rows to one line.
Maintained under DOC-2 / DOC-3 (`.opencode/rules/feature-docs.md`).

| Feature | Purpose | Doc | Routes | Depends on |
|---------|---------|-----|--------|------------|
| splash | Startup animation, auth/onboarding checks, routing | lib/features/splash/FEATURE.md | /splash | core/local/cache, core/local/secure, core/router, core/responsive, core/theme, core/widgets |
| auth | Sign-in, sign-up, pending approval and employee-status flows | lib/features/auth/FEATURE.md | /login, /signup, /pending | core/network, core/errors, core/local/secure, core/local/cache, core/utils, core/widgets, core/animations, core/responsive, core/theme, core/i18n, core/router, core/di |
| onboarding | First-run intro to 4 modules (Projects, People, Finance, Insights) with animated slides | lib/features/onboarding/FEATURE.md | /onboarding | core/local/cache, core/animations, core/theme, core/router, core/i18n, core/responsive |
| interactions | CRM interactions: search/filter feed grouped by date, add/edit sheet, delete dialog, timeline for the opportunity detail tab — Bloc/Cubit holders + full widget layer | lib/features/interactions/FEATURE.md | /crm (tab) | core/animations, core/constants, core/di, core/errors, core/helpers, core/i18n, core/network, core/responsive, core/services, core/theme, core/utils, core/widgets |
| customer_notes | CRM customer notes: newest-first thread per customer, add composer, edit sheet, delete dialog — Cubit holders + full widget layer (embedded in the opportunity detail page) | lib/features/customer_notes/FEATURE.md | /crm/opportunities/:id (embedded) | core/constants, core/helpers, core/services, core/di, core/network, core/errors, core/utils, core/widgets, core/animations, core/responsive, core/theme, core/i18n |
| opportunities | CRM opportunities: paginated list/search, read-only detail with header, stage stepper, probability ring, tabs, overview, interactions tab, "Log it?" prompt — Bloc/Cubit holders + presentation widgets | lib/features/opportunities/FEATURE.md | /crm, /crm/opportunities/:id | core/animations, core/constants, core/di, core/errors, core/helpers, core/i18n, core/network, core/responsive, core/services, core/theme, core/utils, core/widgets, interactions, customer_notes |
| crm_shell | CRM module shell — composes crm_dashboard, opportunities and interactions into one kept-alive tabbed shell with a floating nav bar at /crm | lib/features/crm_shell/FEATURE.md | /crm, /crm/opportunities/:id | opportunities, interactions, crm_dashboard, core/animations, core/router, core/di, core/theme, core/i18n |
| crm_dashboard | CRM sales dashboard: read-only tab 0 with open pipeline, weighted forecast, won revenue, win ratio, pipeline by stage, closings by month, team ranking — one overview endpoint | lib/features/crm_dashboard/FEATURE.md | none (tab 0 of /crm) | core/animations, core/constants, core/di, core/errors, core/extensions, core/i18n, core/network, core/responsive, core/theme, core/utils, core/widgets |

<!-- Replace the example row with your real features. Run /doc-sync <feature> to generate each FEATURE.md. -->
