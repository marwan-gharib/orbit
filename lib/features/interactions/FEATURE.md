# Interactions Feature

> Last verified: 2026-11-01
> Path: `lib/features/interactions/`

## 1 Purpose

CRM interactions end to end — domain entities, params and repository contract; data
models, remote data source and repository implementation; and presentation holders
(Bloc list + Cubit form + Cubit delete). No screens, routes or i18n yet: the holders
are wired into DI and ready for a screen layer to consume.

## 2 File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/interactions_list/interactions_list_bloc.dart | Debounced search + immediate filters + full reloads, all restartable; silent refresh from the CRM change signal (successful mutations anywhere refetch this list under its criteria) |
| presentation | cubits/interactions_list/interactions_list_event.dart | Started, SearchChanged, FiltersChanged, Refreshed events |
| presentation | cubits/interactions_list/interactions_list_state.dart | Initial, Loading, Success, Empty, Error states — criteria carried by all loaded states; `isRefreshing`/`refreshFailure` on silent refresh |
| presentation | cubits/interaction_form/interaction_form_cubit.dart | One-shot add/edit submit; owning context captured at startEdit, never part of the wire payload |
| presentation | cubits/interaction_form/interaction_form_state.dart | Initial, Ready, Submitting, Success, SubmitError states |
| presentation | cubits/interaction_delete/interaction_delete_cubit.dart | One-shot delete with InProgress/Success/Failure states |
| presentation | cubits/interaction_delete/interaction_delete_state.dart | Initial, InProgress, Success, Failure states |
| domain | entities/interaction_entity.dart | Interaction (equatable) |
| domain | entities/interaction_context.dart | InteractionContext (customer + optional opportunity; never serialized) |
| domain | params/interactions_criteria.dart | Active filters (searchText, type, customerId, contactId, opportunityId) |
| domain | params/add_interaction_params.dart | Five editable fields + owning customer id |
| domain | params/update_interaction_params.dart | Exactly the five PATCH-editable wire fields |
| domain | repositories/interactions_repository.dart | Repository contract |
| domain | usecases/*.dart (5) | Get, Add (resolves employee id from CurrentEmployeeIdProvider), Update, Delete, WatchInteractionChanges |
| data | datasources/remote/interactions_remote_data_source.dart | GET list/search, POST add, PATCH edit, DELETE-with-body — all through BaseApiClient, failures only |
| data | models/interaction_model.dart | Strict wire parse (unknown type → unknown; missing description → ''; unparsable date → FormatException) |
| data | models/interactions_response_model.dart | Strict `{"Interactions": [...]}` parse — non-list root or non-object item fails the whole response |
| data | repositories/interactions_repository_impl.dart | One GET when unsearched; two parallel GETs (subject + description) merged/deduped/sorted when searching; publishes CrmDataChange on success only |

## 3 Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| Interaction | interactionId, type, subject, description, interactionDate, customerId, employeeId, contactId?, opportunityId? | InteractionModel | Type falls back to `unknown` for unrecognized wire values; date parsed via `WireDates` (UTC-normalized calendar day) |
| InteractionContext | customerId, opportunityId? | — | Never serialized; feeds only the CRM change signal |

## 4 Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetInteractionsUseCase | InteractionsCriteria | ApiResult<List<Interaction>> | Pass-through to repository |
| AddInteractionUseCase | AddInteractionParams | ApiResult<void> | Employee id resolved from CurrentEmployeeIdProvider (cached `user.id`); unauthorized when missing |
| UpdateInteractionUseCase | UpdateInteractionParams + context | ApiResult<void> | Exactly five editable fields; context signals the change only |
| DeleteInteractionUseCase | interactionId + context | ApiResult<void> | DELETE carries interaction_id in body; context signals the change only |
| WatchInteractionChangesUseCase | — | Stream<CrmDataChange> | Filters core signal to `interaction` kind |

## 5 API & storage

Wire keys in `core/constants/api_keys.dart`, endpoints in `core/constants/endpoints.dart`,
other constants in `core/constants/app_consts.dart`:

| Call | Method | Notes |
|------|--------|-------|
| `/crm/interactions/` | GET | query `subject`, `description`, `type`, `customer_id`, `contact_id`, `opportunity_id`; root `{"Interactions": [...]}`, sorted date desc then id desc |
| `/crm/interactions/` | POST | body `type`, `subject`, `description`, `interaction_date` (`yyyy-MM-dd`), `customer_id`, `employee_id`; optional `contact_id`, `opportunity_id` omitted when null |
| `/crm/interactions/` | PATCH | body exactly 5 keys: `interaction_id`, `type`, `subject`, `description`, `interaction_date` |
| `/crm/interactions/` | DELETE | body `{interaction_id}` (not the URL) |

## 6 State

- `InteractionsListBloc`: `InteractionsListInitial` → `Loading` → `Success`/`Empty`/`Error`. Search debounced + restartable; filters immediate + restartable; refresh restartable. CRM change signal triggers silent `Refreshed` when customer (and opportunity, when bound) match.
- `InteractionFormCubit`: `Initial` → `Ready` → `Submitting` → `Success`/`SubmitError`. One-shot per submit.
- `InteractionDeleteCubit`: `Initial` → `InProgress` → `Success`/`Failure`. One-shot per delete.

## 7 DI

`core/di/interactions_injection.dart` — `initInteractionsModule`: remote data source (lazy singleton), repository (lazy singleton), use cases (lazy singleton), holders (factory — one set per screen). Depends on `BaseApiClient`, `CrmDataChangeService` and `CurrentEmployeeIdProvider` from core. Wired into `injection_container.dart` after `initAuthModule`.

## 7.1 Used by

- `crm_shell` — consumes `InteractionsFeedView` in the CRM shell at `/crm`.

## 8 i18n

None — no screens or user-facing text yet. All future screen text will go through slang.

## 9 Tests

`test/features/interactions/` (mocktail + bloc_test):

- **Use cases**: get (3), add (2), update/delete (2), watch (1).
- **Models**: interaction (7), interactions_response (3).
- **Remote data source**: 9 tests — filter passthrough, type wire value, error mapping, malformed body → ParsingFailure, add 5 wire keys + employee id, owner ids omitted when null, update exactly 5 fields, delete body carries interaction_id, 2xx mutation success.
- **Repository**: search (6) — single-GET sort, filter passthrough, merge/dedupe/subject-wins, subject-fails, description-fails, both-fail subject-wins; mutations (6) — add/update/delete publish exact `CrmDataChange` once on success, never on failure.
- **Cubits/Bloc**: list lifecycle (7), list debounce+signal (4), form (8), delete (4). Shared mocks + fallbacks in `interactions_test_mocks.dart`.

## 10 Known issues

- No screens, routes or i18n yet — holders are DI-ready but not reachable from the UI.
- `watch_interaction_changes_usecase_test.dart` uses a real `StreamController`; signal delivery is flushed through the event loop.

## 11 Changelog

- 2026-11-01: Interactions feature end to end (domain → data → presentation → DI → tests): `Interaction`, `InteractionsCriteria`, `AddInteractionParams`, `UpdateInteractionParams`, `InteractionsRepository` + 5 use cases; `InteractionModel`, `InteractionsResponseModel` (strict parse); remote data source (GET/POST/PATCH/DELETE-with-body); repository impl (search fan-out merge/dedup/sort, success-only `CrmDataChange` publish); `InteractionsListBloc` (debounced search, immediate filters, restartable reloads, CRM signal silent refresh), `InteractionFormCubit`, `InteractionDeleteCubit`; DI module wired into container; 75 tests, analyze clean, all files ≤300 lines.
