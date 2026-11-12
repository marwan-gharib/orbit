# CRM Dashboard Feature

> Last verified: 2026-11-12
> Path: `lib/features/crm_dashboard/`

## 1. Purpose

Sales dashboard of the CRM module: one read-only screen (tab 0 of the CRM shell) showing
the open pipeline, weighted forecast, won revenue, win ratio, pipeline by stage, expected
closings by month and the sales team ranking. All figures come from one
`GET /crm/overview/`; the app only reshapes them for charts — no business rules of its own.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| Dashboard tab | none — tab 0 of `RoutePaths.crm` | — | Skeleton → figures → retryable error; pull-to-refresh + silent refresh; no detail navigation |

## 3. File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| domain | entities/dashboard_{overview,metric,win_ratio,stage_slice,month_point,salesperson}_entity.dart, enums/dashboard_stage.dart | Overview and its parts (metric = value + count; win ratio; stage slice; month point; salesperson); stage enum |
| domain | repositories/dashboard_repository.dart, usecases/get_dashboard_overview_usecase.dart | Contract + the single read use case |
| data | datasources/remote/dashboard_remote_data_source.dart | `GET Endpoints.crmOverview` through BaseApiClient |
| data | models/dashboard_{overview,metric,win_ratio,stage_slice,month_point,salesperson}_model.dart, dashboard_json.dart | Defensive parse: missing key → neutral value; wrong list shape → FormatException |
| data | repositories/dashboard_repository_impl.dart | Model → entity mapping into ApiResult |
| presentation | cubits/dashboard/* | Load + silent-refresh Cubit and state |
| presentation | constants/dashboard_layout_constants.dart | Responsive sizes |
| presentation | pure/dashboard_insights.dart, dashboard_palette.dart | Display-only derivations; stage colours |
| presentation | widgets/dashboard_tab.dart | Owns the cubit (DI); skeleton / figures / error switch |
| presentation | widgets/dashboard_view.dart | Pull-to-refresh, progress line, refresh notice, staggered cards, empty state |
| presentation | widgets/dashboard_hero_card.dart, dashboard_ring.dart | Open pipeline count-up + forecast-coverage ring |
| presentation | widgets/dashboard_kpi_grid.dart, dashboard_kpi_card.dart | 4 KPI tiles: won, weighted, average deal, past close date (pulsing) |
| presentation | widgets/dashboard_win_ratio_card.dart, dashboard_legend_item.dart | Won/lost donut, count-up percentage in the hole, tappable slices; legend |
| presentation | widgets/dashboard_pipeline_card.dart, pipeline_funnel_view.dart, pipeline_donut_view.dart, pipeline_bars_view.dart | Stage data as funnel/donut/bars, by value or count |
| presentation | widgets/dashboard_closings_card.dart | Deal vs weighted value by month, bars or trend line |
| presentation | widgets/dashboard_team_card.dart, dashboard_team_row.dart | Leaderboard ranked by won revenue, animated bars |
| presentation | widgets/dashboard_card_header.dart | Shared card header |
| presentation | widgets/dashboard_refresh_notice.dart | Dismissible silent-refresh failure notice |
| presentation | widgets/dashboard_skeleton.dart, dashboard_skeleton_cards.dart | Skeleton shaped like the dashboard |

## 4. Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| DashboardOverview | currency, openPipeline, weightedForecast, won, winRatio, pastExpectedCloseCount, stages[], months[], salesTeam[] | DashboardOverviewModel | Everything on the dashboard, one response |
| DashboardMetric | value, count | DashboardMetricModel | A money total plus how many opportunities cover it |
| DashboardWinRatio | percentage, wonCount, lostCount | DashboardWinRatioModel | Share of closed that were won |
| DashboardStageSlice | stage, label, value, count | DashboardStageSliceModel | Open pipeline per stage |
| DashboardMonthPoint | month, label, dealValue, weightedValue | DashboardMonthPointModel | Expected closings per month |
| DashboardSalesperson | employeeId, employeeName, wonValue, wonCount | DashboardSalespersonModel | Team ranking row |

## 5. Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetDashboardOverviewUseCase | — | ApiResult<DashboardOverview> | Pass-through to repository; the feature's only use case |

## 6. API & storage

| Endpoint / key (constant) | Method | Notes |
|---------------------------|--------|-------|
| `Endpoints.crmOverview` | GET | No query parameters; whole dashboard in one response; no cache, no change signal |

## 7. State

- `DashboardCubit`: `Initial` → `Loading` → `Success(isRefreshing, refreshFailure)` / `Error`. `load()` on first display; `refresh()` keeps the figures on screen while refreshing, and a failed refresh keeps them too (`refreshFailure` → dismissible notice).
- No CRM change signal — the dashboard refreshes by pull-to-refresh only.
- The cubit lives as long as the tab (the shell keeps the tab alive), so figures survive tab switches.

## 8. Dependencies

- Depends on (core): BaseApiClient, ErrorMapper, ApiResult, Endpoints, `Formatters` (money/compact), core animations (ProgressDriver, AnimatedCounter, StaggeredListItem, AppAnimatedSwitcher, PulseWidget, shimmer, AnimatedProgressBar), core widgets (AppCard, EmptyState, ErrorState, ProgressRing) and `core/widgets/charts/` (bar/donut/line `CustomPainter` charts, no chart package), core/responsive, core/theme, core/i18n, core/extensions.
- Depends on (features): none.
- Used by (features): `crm_shell` — DashboardTab as tab 0 of `/crm`.
- DI file: `core/di/dashboard_injection.dart` — `initDashboardModule` (datasource/repository/use case lazy singletons, cubit factory); wired in `injection_container.dart`.

## 9. Localization

- Namespace: `context.t.crm.dashboard.*` (hero, kpi, winRatio, pipeline, closings, team, empty) plus `crm.tabs.dashboard`; regenerate with `dart run slang`.

## 10. Business rules & edge cases

- Money is always shown in `overview.currency` via `Formatters.money` / `Formatters.compact`.
- Forecast coverage = weighted / open and average open deal = open value / open count — display-only derivations in `pure/dashboard_insights.dart`.
- An overview with no data at all renders the empty state instead of empty charts.
- Missing JSON keys parse to neutral values; only a wrongly shaped list fails the whole response (FormatException).

## 11. Tests

none — `test/features/crm_dashboard/` and `test/core/widgets/charts/` exist as empty directories; no test files (see Known issues).

## 12. Known issues / TODO

- Full test-suite gap: model parsing, repository, cubit (incl. out-of-order requests), pure insights, skeleton/view layouts at 320/360/412 px × text scale 1/1.5/2, view switching, empty state, reduce motion — described in the 2026-11-08 doc but absent from the working tree; same for the `core/widgets/charts/` tests. Restore as its own task.
- Charts use LTR layout inside RTL locales for now.
- The past-close-date KPI does not navigate (the opportunities list has no overdue filter yet).

## 13. Changelog

- 2026-11-12 — Doc repaired against the working tree: restructured to the 13 template sections, entities/models and file map expanded to the real files (card header, legend item, refresh notice added), Tests corrected to none (suite absent from the working tree — moved to Known issues), endpoint by constant name.
- 2026-11-08: Feature created (domain/data/cubit/UI), DI module, shell tab 0, core `widgets/charts/` and the compact money formatter.
