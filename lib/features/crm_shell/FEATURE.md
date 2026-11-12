# CRM Shell Feature

> Last verified: 2026-11-12
> Path: `lib/features/crm_shell/`

## 1. Purpose

Composes the CRM module: one shell at `/crm` with the Dashboard, Opportunities and
Interactions tabs kept alive, a floating navigation bar that hides while scrolling, and
pushes into the opportunity detail route. Owns no domain, data or state logic.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| CrmShell | `RoutePaths.crm` | — | 3 tabs (Dashboard, Opportunities, Interactions); AppBar with back + `crm.title` |
| Opportunity detail | `RoutePaths.crmOpportunityDetails` | `id` | Owned by `opportunities`, defined in `core/router`; pushed by the shell and the feed's "Open opportunity" chip |
| Invalid-id page | `RoutePaths.crmOpportunityDetails` (non-numeric) | — | Error + back; lives in `core/router` |

Navigation: Home → `/crm` fadeThrough; tab switching via the `FloatingNavBar` pill and
`TabController` (swipe works, `TabBarView`); card/chip tap → detail containerTransform
(AppHero flight); back returns to the shell with per-tab state and scroll preserved
(`_KeepAlive`).

## 3. File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | widgets/crm_shell.dart | `CrmShell` (Scaffold, AppBar, three kept-alive tabs, scroll-driven nav visibility) and `_KeepAlive` |

No domain, data or state layer. The barrel `presentation/widgets/widgets.dart` no longer
exists. Route definitions, the home screen's CRM entry and the invalid-id page live in
`core/router/app_router_routes.dart`, not here.

## 4. Entities & models

none — composition only.

## 5. Use cases

none — composition only.

## 6. API & storage

none — composition only.

## 7. State

- No holders of its own. The Interactions tab creates `InteractionsListBloc`,
  `InteractionFormCubit` and `InteractionDeleteCubit` through `getIt` factories (one set
  for the shell's lifetime); the opportunities list Bloc is provided by the `/crm` route
  builder in `core/router`.
- All three tabs stay mounted (`_KeepAlive` with `AutomaticKeepAliveClientMixin`), so
  scroll positions, blocs and loaded data survive tab switches.

## 8. Dependencies

- Depends on (features): `crm_dashboard` (`DashboardTab`), `opportunities`
  (`OpportunitiesTabView` + detail route), `interactions` (`InteractionsFeedView` + its
  three holders). `customer_notes` is only indirect — reached through the opportunities
  detail page, never imported here.
- Depends on (core): animations (`FloatingNavBar`, `AnimatedVisibility`, `AppCurves`,
  `AppDurations`), `core/di` (getIt), `core/i18n`, `core/theme`; route constants in
  `core/router` (owned there).
- Used by (features): none — top-level shell wired only by the router.
- DI file: none of its own; resolves the other features' holders through
  `core/di/injection_container.dart`.

## 9. Localization

- `context.t.crm.title` and `context.t.crm.tabs.{dashboard,opportunities,interactions}`
  for the shell; the invalid-id page (in `core/router`) uses
  `crm.common.{invalidId,back,notFound}`.

## 10. Business rules & edge cases

- Tab bodies are never rebuilt away: each tab is kept alive, so blocs and scroll state
  survive switches; the body intentionally does not cross-fade on tab change — the motion
  is the nav bar's pill/icon animation.
- The nav bar hides on scroll down and reappears on scroll up or idle; selecting any tab
  also forces it visible.
- The nav pill follows `TabController.animation` frame by frame, so taps and swipes glide
  without stacked implicit animations.
- Detail is opened with `context.push`, so back returns to the preserved shell.

## 11. Tests

none — no `test/features/crm_shell/` yet (navigation map and integration flows planned).

## 12. Known issues / TODO

- Missing test coverage: navigation map and shell integration flows have no tests.
- `crm_shell.dart` pushes the detail route with a string literal
  (`'/crm/opportunities/$id'`) instead of `RoutePaths.crmOpportunityDetails` (ARCH-10) —
  small fix needed.

## 13. Changelog

- 2026-11-12 — Doc repaired against the working tree: three tabs incl. Dashboard (tab 0), `FloatingNavBar` documented (was `AnimatedChipSelector`), deleted barrel removed from the file map, `customer_notes` demoted to indirect dependency, `crm_dashboard` recorded, tests marked absent, string-literal route push flagged.
- 2026-11-08: Dashboard tab added (tab 0) from `crm_dashboard`; nav bar has 3 items and shows only the selected label. `FloatingNavBar` follows `TabController.animation` frame by frame (no stacked implicit animation, no overshoot).
- 2026-11-07: Top tab bar replaced by the core `FloatingNavBar` (floating, away from edges, sliding spring pill, hides while scrolling down).
- 2026-11-04: Shell created — `CrmShell` with tab bar, `/crm` routes, home CRM entry, invalid-id page, i18n title/tabs/invalidId/back.
