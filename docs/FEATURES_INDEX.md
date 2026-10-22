# Features Index

Read this first for any feature task. One row per feature. Keep rows to one line.
Maintained under DOC-2 / DOC-3 (`.opencode/rules/feature-docs.md`).

| Feature | Purpose | Doc | Routes | Depends on |
|---------|---------|-----|--------|------------|
| splash | Startup animation, auth/onboarding checks, routing | lib/features/splash/FEATURE.md | /splash | core/local/cache, core/local/secure, core/router, core/responsive, core/theme, core/widgets |
| auth | Sign-in/sign-up/session/employee-status logic (Cubits only, no screens yet) | lib/features/auth/FEATURE.md | (none) | core/network, core/errors, core/local/secure, core/local/cache, core/utils, core/di |
| onboarding | First-run intro to 4 modules (Projects, People, Finance, Insights) with animated slides | lib/features/onboarding/FEATURE.md | /onboarding | core/local/cache, core/animations, core/theme, core/router, core/i18n, core/responsive |

<!-- Replace the example row with your real features. Run /doc-sync <feature> to generate each FEATURE.md. -->
