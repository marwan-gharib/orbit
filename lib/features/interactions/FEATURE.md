# Interactions Feature

> Last verified: 2026-11-15
> Path: `lib/features/interactions/`

## 1. Purpose

CRM interactions end to end: a search-and-filter feed grouped by date with overflow and
swipe actions, an add/edit bottom sheet and a delete dialog — plus a non-scrolling timeline
reused by the opportunity detail tab. Domain (entities/params/repository/use cases), data
(models, data source, repository impl) and presentation (one Bloc, two Cubits, full widget
layer). No standalone routes: it lives inside the CRM shell.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| Interactions feed tab | `RoutePaths.crm` | — | Composed by `crm_shell`; the shell provides the three holders |
| Add/edit bottom sheet | — (overlay) | owning customer/opportunity context | `AppBottomSheet` opened via `widgets/helpers.dart`; fresh `InteractionFormCubit` per open |
| Delete dialog | — (overlay) | interaction + context | Confirm runs inside the button; closes only after the delete succeeds |

## 3. File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | blocs/interactions_list/* | Feed Bloc + events/states: debounced search, immediate filters, restartable reloads, CRM-signal silent refresh |
| presentation | cubits/interaction_form/*, cubits/interaction_delete/* | One-shot add/edit and delete Cubits; owning context captured at startEdit, never serialized |
| presentation | constants/interaction_layout_constants.dart | Shared geometry: tile, skeleton twin, timeline |
| presentation | mappers/interaction_tile_mapper.dart, view_models/interaction_tile_data.dart | Interaction → plain tile data for feed and timeline |
| presentation | pure/date_grouping.dart | Calendar-date grouping for the feed (today injected) |
| presentation | pure/timeline_ordering.dart, interaction_form_dirty.dart, interaction_submit_params.dart | Timeline sort; form dirty-check (calendar-day dates); form → add/update params |
| presentation | widgets/interactions_feed_view.dart, interactions_feed_state_body.dart | Feed entry; skeleton/content/empty (no data and no results)/error switch |
| presentation | widgets/interactions_feed_header.dart | Search field + type chips; owns the search controller so clear-all empties it |
| presentation | widgets/interactions_feed_content.dart, interactions_group_header.dart | Date-grouped scroll content (sticky headers, id-diffed flash/collapse); pinned date header (slang keys) |
| presentation | widgets/interaction_tile.dart, interaction_tile_skeleton.dart, interaction_type_icon.dart | Tile (overflow menu, "Open opportunity" chip, swipe actions); skeleton twin; animated type icon |
| presentation | widgets/interactions_timeline.dart | Non-scrolling timeline for the opportunity detail tab |
| presentation | widgets/interaction_add_edit_sheet.dart, interaction_sheet_fields.dart, interaction_text_fields.dart, interaction_submit_button.dart | Add/edit sheet: fields, shaking subject validation, morphing save button |
| presentation | widgets/interaction_swipe_background.dart, interaction_delete_dialog.dart, interaction_refresh_notice.dart | Swipe background; delete confirmation; dismissible silent-refresh failure notice |
| presentation | widgets/helpers.dart | Opens the add sheet (fresh cubit per invocation; works without a Bloc in the host context) |
| domain | entities/interaction_entity.dart, interaction_context.dart | Interaction; InteractionContext (customer + optional opportunity) |
| domain | enums/interaction_type.dart | InteractionType — lowercase wire values, `unknown` fallback; consumed by opportunities too |
| domain | params/interactions_criteria.dart, add_interaction_params.dart, update_interaction_params.dart | Filters; five editable fields + owner; exactly the five PATCH fields |
| domain | repositories/interactions_repository.dart, usecases/* | Contract; Get, Add, Update, Delete, WatchInteractionChanges |
| data | datasources/remote/interactions_remote_data_source.dart | GET list/search, POST add, PATCH edit, DELETE-with-body — through BaseApiClient, failures only |
| data | models/interaction_model.dart, interactions_response_model.dart | Strict wire parse; strict `{"Interactions": [...]}` root |
| data | repositories/interactions_repository_impl.dart | Search fan-out merge/dedupe/sort; publishes CrmDataChange on success only |

## 4. Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| Interaction | interactionId, type, subject, description, interactionDate, customerId, employeeId, contactId?, opportunityId? | InteractionModel | Type falls back to `unknown` for unrecognized wire values; date parsed via `WireDates` (UTC-normalized calendar day) |
| InteractionContext | customerId, opportunityId? | — | Never serialized; feeds only the CRM change signal |

## 5. Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetInteractionsUseCase | InteractionsCriteria | ApiResult<List<Interaction>> | Pass-through to repository |
| AddInteractionUseCase | AddInteractionParams | ApiResult<void> | Employee id resolved from CurrentEmployeeIdProvider (cached `user.id`); unauthorized when missing |
| UpdateInteractionUseCase | UpdateInteractionParams + context | ApiResult<void> | Exactly five editable fields; context signals the change only |
| DeleteInteractionUseCase | interactionId + context | ApiResult<void> | DELETE carries interaction_id in the body; context signals the change only |
| WatchInteractionChangesUseCase | — | Stream<CrmDataChange> | Filters the core signal to the interaction kind |

## 6. API & storage

| Endpoint / key (constant) | Method | Notes |
|---------------------------|--------|-------|
| `Endpoints.crmInteractions` | GET | query (ApiKeys) `subject`, `description`, `type`, `customer_id`, `contact_id`, `opportunity_id`; root `{"Interactions": [...]}`, sorted date desc then id desc |
| `Endpoints.crmInteractions` | POST | body `type`, `subject`, `description`, `interaction_date` (`yyyy-MM-dd`), `customer_id`, `employee_id`; optional `contact_id`, `opportunity_id` omitted when null |
| `Endpoints.crmInteractions` | PATCH | body exactly 5 keys: `interaction_id`, `type`, `subject`, `description`, `interaction_date` |
| `Endpoints.crmInteractions` | DELETE | body `{interaction_id}` (never the URL) |

## 7. State

- `InteractionsListBloc` — Bloc (per-event transformers). `Started` (idempotent), `SearchChanged` (debounced + restartable, sent as typed), `FiltersChanged`/`FiltersCleared` (immediate + restartable, replace semantics — null clears), `Refreshed` (restartable; manual and CRM-signal fed).
- `InteractionFormCubit` — Cubit: `Initial → Ready → Submitting → Success/SubmitError`, one-shot per submit.
- `InteractionDeleteCubit` — Cubit: `Initial → InProgress → Success/Failure`, one-shot per delete.
- List states: `Initial`, `Loading`, `Success/Empty` (carry the criteria they were loaded under; `isRefreshing`/`refreshFailure` on silent refresh), `Error`. No pagination — the feed is a full list.

## 8. Dependencies

- Depends on (core): BaseApiClient, CrmDataChangeService, CurrentEmployeeIdProvider, Endpoints/ApiKeys, failure mapper, ApiResult + WireDates, core widgets, core animations (overlays, drawn check, shimmer), core/responsive, core/theme, core/i18n.
- Depends on (features): none.
- Used by (features): crm_shell (feed at `/crm`, owns the three holders); opportunities (detail tab owns its own `InteractionsListBloc`; timeline, tile skeleton, `InteractionType`).
- DI file: `core/di/interactions_injection.dart` — `initInteractionsModule` (datasource/repository/use cases lazy singletons, holders factory); wired after `initAuthModule`.

## 9. Localization

- Namespace: `context.t.crm.crmInteractions.*` in `assets/i18n/en.i18n.json` (slang); feed group headers resolve today/yesterday keys.

## 10. Business rules & edge cases

- Successful mutations publish exactly one `CrmDataChange` (repository); failures publish nothing. Consumers refetch — no patch state is applied locally.
- The Bloc silently refetches under its active criteria when the signal reports a relevant mutation (customer, and bound opportunity, match); a deleted row disappears through the refetch.
- Search runs two parallel GETs (subject + description) merged, deduped and sorted; unsearched is a single GET.
- `InteractionType` maps lowercase wire strings; null/blank/unrecognized → `unknown`, never a crash.
- `InteractionContext` is never serialized; PATCH carries exactly the five editable fields; DELETE id goes in the body.
- The form's dirty check compares dates by calendar day; the sheet always starts from a fresh cubit.

## 11. Tests

`test/features/interactions/` (mocktail + bloc_test), 37 files / 176 cases; shared helpers `interactions_test_mocks.dart` + `test_helpers.dart`:

| Area | Files (cases) |
|------|---------------|
| Use cases | get (2), add (2), update/delete (2), watch (1) |
| Models | interaction_model (7), interactions_response_model (3) |
| Data | remote data source (8), repository search (6), repository mutations (6) |
| Constants | interaction_layout_constants (3) |
| Blocs/Cubits | list lifecycle (5), list filters (2), list CRM-signal refresh (4), form (8), delete (4) |
| Mappers/view models | tile mapper (4), tile data (7) |
| Pure | date_grouping (10), timeline_ordering (7), form_dirty (5), submit_params (2) |
| Widgets | feed_view (3), feed_header (8), feed_content (4), feed_content_diff (5), feed_state_body (12), tile (7), tile_skeleton (3), type_icon (4), timeline (6), add_edit_sheet (4), delete_dialog (3), group_header (4), refresh_notice (1), swipe_background (3), helpers (4) |

Widget tests drive the sliver feed with `whenListen` mock blocs and pump past the one-shot stagger timer (`extraSlow + 1ms`); the restartable-cancel lifecycle test suspends each fetch on its own Completer.

## 12. Known issues / TODO

- `watch_interaction_changes_usecase_test.dart` uses a real `StreamController`; signal delivery is flushed through the event loop.

## 13. Changelog

- 2026-11-15 — Stale feed/tile/add-edit widget tests rewritten for the sliver output (176 cases total); added list-bloc lifecycle (incl. restartable cancel) + filters, form dirty/submit-params pure tests, and group-header / refresh-notice / swipe-background widget tests; feed-content tests split into static-render and diff/stagger files; Tests table updated, shrunken-coverage known issue removed.
- 2026-11-12 — Doc repaired against the working tree: full UI documented (file map grew to the real widget/pure/view-model layer), Tests rewritten to the 29 real files/148 cases, i18n namespace and Screens & routes added, holders noted as `blocs/` (list) and `cubits/` (form/delete), `InteractionType` documented as feature-owned.
- 2026-11-08: UI batch 4 — `FiltersCleared` (search + type, keeps customer/opportunity scope); header owns its search controller and empties it on clear-all; detailed feed skeleton; date header redesigned (pill + count), card modernised, no duplicate date in feed cards.
- 2026-11-07: Add/edit/delete helpers resolve cubits through DI (`getIt`) and close them afterwards; opportunity chip polished (icon, readable colours).
- 2026-11-01: Feature end to end — entities/params, repository + 5 use cases, 2 models (strict parse), remote data source (GET/POST/PATCH/DELETE-with-body), repository impl (search fan-out, success-only signal publish), list Bloc + form/delete Cubits, DI module.
