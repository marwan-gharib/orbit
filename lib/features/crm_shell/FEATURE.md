# CRM Shell Feature

> Last verified: 2026-11-04
> Path: `lib/features/crm_shell/`

## 1 Purpose

CRM module shell — composes the three CRM features (`opportunities`, `interactions`, `customer_notes`) into one working module with a tabbed interface. Owns the `/crm` route and the tab bar; does not own any domain/business logic.

## 2 Screens & routes

| Screen | Route | Purpose |
|--------|-------|---------|
| CrmShell | `/crm` | Tabbed shell with Opportunities and Interactions tabs; preserves tab state and scroll |
| OpportunityDetailPage | `/crm/opportunities/:id` | Owned by `opportunities` feature; pushed from both tabs |
| Invalid ID page | `/crm/opportunities/:id` (non-numeric) | Shows error with back action |

## 3 File map

| Layer | Key files | Responsibility |
|-------|-----------|----------------|
| presentation | widgets/crm_shell.dart | `CrmShell` (Scaffold + AppBar + AnimatedChipSelector tab bar + IndexedStack via TabBarView), `_TabBar` |
| presentation | widgets/widgets.dart | Barrel export |

No domain, data, or state layer — this feature only composes existing features.

## 4 Dependencies

| Depends on | Used by |
|------------|---------|
| `opportunities` (OpportunitiesTabView, OpportunitiesListBloc) | — |
| `interactions` (InteractionsFeedView) | — |
| `customer_notes` (via OpportunitiesDetailPage → NotesTab) | — |
| `core/animations` (AnimatedChipSelector, AppRoute, AppPageTransition) | — |
| `core/router` (RoutePaths, RouteNames, AppRoute) | — |
| `core/di` (getIt for OpportunitiesListBloc) | — |
| `core/theme` (context.colors, AppSpacing) | — |
| `core/i18n` (context.t.crm.title, context.t.crm.tabs) | — |

## 5 Constants & routes

Route paths in `core/constants/route_paths.dart`:
- `RoutePaths.crm` → `/crm`
- `RoutePaths.crmOpportunityDetails` → `/crm/opportunities/:id`

Route names in `core/constants/route_names.dart`:
- `RouteNames.crm` → `crm`
- `RouteNames.crmOpportunityDetails` → `crmOpportunityDetails`

i18n keys in `assets/i18n/en.i18n.json` under `crm.*`:
- `crm.title` — "CRM"
- `crm.tabs.opportunities` — "Opportunities"
- `crm.tabs.interactions` — "Interactions"
- `crm.common.invalidId` — "Invalid opportunity ID"
- `crm.common.back` — "Back"
- `crm.common.notFound` — "Not found" (reused from common)

## 6 Navigation behavior

| From | Action | To | Transition |
|------|--------|----|------------|
| Home | Tap CRM button | `/crm` (Opportunities tab) | fadeThrough |
| Shell | Tap tab | Switch in place | AnimatedChipSelector pill slide |
| Opportunities tab | Tap card | `/crm/opportunities/<id>` | containerTransform (Hero) |
| Interactions tab | Tap "Open opportunity" chip | `/crm/opportunities/<id>` | containerTransform |
| Detail | Back | Shell (preserved state & scroll) | sharedAxisHorizontal reverse |
| Invalid ID | — | Invalid ID page with back | fadeThrough |

## 7 Tests

`test/features/crm_shell/` (to be added in C3):
- Navigation tests for the full navigation map
- Integration flow tests E1–E12 (end-to-end through real router)

## 8 Known issues

- Tab body state preservation uses `TabBarView` (IndexedStack semantics) — scroll position is preserved per tab. The "fade-through" tab switch animation is achieved via `AnimatedChipSelector` pill motion; the body does not cross-fade (by design, to preserve state).

## 9 Changelog

- 2026-11-04: Created CRM shell feature — CrmShell widget with AnimatedChipSelector tab bar, routes in AppRouterRoutes, Home screen CRM entry, invalid ID page, i18n keys for CRM title/tabs/invalidId/back.