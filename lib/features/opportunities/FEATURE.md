# Opportunities Feature

> Last verified: 2026-11-01
> Path: `lib/features/opportunities/`

## 1 Purpose

CRM opportunities end to end — paginated list with filters and title search, read-only detail.
Mobile cannot create, edit, or change stage of opportunities. Domain entities, params
and repository contract; data models, remote data source and repository implementation;
and presentation holders (Bloc list + Cubit detail). No screens, routes or i18n yet:
the holders are wired into DI and ready for a screen layer to consume.

## 2 File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/opportunities_list/opportunities_list_bloc.dart | Paginated list: debounced title search + immediate filters + first-load/refresh/load-more, all server-side; NOT subscribed to CRM change signal |
| presentation | cubits/opportunities_list/opportunities_list_event.dart | Started, SearchChanged, FiltersChanged, Refreshed, LoadMoreRequested events |
| presentation | cubits/opportunities_list/opportunities_list_state.dart | Initial, Loading, Success(items+hasMore+nextPage), Empty, Error — `isRefreshing`/`isLoadingMore`/failures |
| presentation | cubits/opportunity_details/opportunity_details_cubit.dart | Read-only detail via list endpoint (`opportunity_id`); silent reload on CRM change signal when `opportunityId` matches |
| presentation | cubits/opportunity_details/opportunity_details_state.dart | Initial, Loading, Success(opportunity), Error — `isRefreshing`/`refreshFailure` on silent refresh |
| domain | entities/opportunity_entity.dart | Opportunity (equatable, read-only) |
| domain | entities/opportunity_customer_entity.dart | OpportunityCustomer (embedded aggregate with contacts/notes/interactions) |
| domain | entities/opportunity_employee_entity.dart | OpportunityEmployee (owner, not signed-in user) |
| domain | entities/customer_contact_entity.dart | CustomerContact (metadata only) |
| domain | entities/embedded_customer_note_entity.dart | EmbeddedCustomerNote (lighter note shape) |
| domain | entities/embedded_customer_interaction_entity.dart | EmbeddedCustomerInteraction (uses core InteractionType) |
| domain | enums/opportunity_stage.dart | OpportunityStage — pipeline order, fromValue fallback to unknown |
| domain | enums/opportunity_status.dart | OpportunityStatus — open/won/lost, fromValue fallback to unknown |
| domain | params/opportunities_criteria.dart | Active filters (title, stage, status, customerId) + copyWith |
| domain | params/get_opportunities_params.dart | criteria + page + pageSize |
| domain | repositories/opportunities_repository.dart | Repository contract (stateless page fetch + detail) |
| domain | usecases/*.dart (3) | GetOpportunities, GetOpportunity, WatchCrmChanges |
| data | datasources/remote/opportunities_remote_data_source.dart | GET page (query `page`, `page_size`, `title?`, `stage?`, `status?`, `customer_id?`), GET one (`opportunity_id` + page=1/page_size=1) — all through BaseApiClient |
| data | models/opportunity_model.dart | Strict wire parse; nested customer + employee models; enums via fromValue |
| data | models/opportunity_customer_model.dart | Customer aggregate with contacts/notes/interactions sub-models |
| data | models/opportunity_employee_model.dart | Owner parse |
| data | models/contact_model.dart | Contact parse |
| data | models/embedded_note_model.dart | Embedded note parse |
| data | models/embedded_interaction_model.dart | Embedded interaction parse (InteractionType via core enum) |
| data | models/opportunities_page_response_model.dart | `{"count": ..., "next": ..., "previous": ..., "results": [...]}` parse |
| data | repositories/opportunities_repository_impl.dart | PagedResult mapping (`hasMore` from `next != null` only; `count` display-only); server order preserved; detail: empty → NotFoundFailure |

## 3 Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| Opportunity | opportunityId, title, estimatedValue, currency, stage, probability, expectedCloseDate, status, lostReason, createdAt, closedAt?, customer, employee | OpportunityModel | Stage/status enums with `unknown` fallback; probability is server data only |
| OpportunityCustomer | customerId, customerCode, firstName, lastName, phone, companyName, email, address, leadSource?, createdAt, updatedAt, contacts[], notes[], interactions[] | OpportunityCustomerModel | Embedded notes/interactions are lighter shapes |
| OpportunityEmployee | employeeId, employeeName | OpportunityEmployeeModel | The opportunity owner, not the logged-in user |
| CustomerContact | contactId, name, jobTitle, email, phone, isPrimary | ContactModel | Metadata only |
| EmbeddedCustomerNote | noteId, employeeId, employeeName, noteText, createdAt | EmbeddedNoteModel | Lighter than standalone CustomerNote |
| EmbeddedCustomerInteraction | interactionId, employeeId, employeeName, type, subject, description, interactionDate, contactId?, opportunityId? | EmbeddedInteractionModel | Uses shared `InteractionType` from core |

## 4 Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetOpportunitiesUseCase | GetOpportunitiesParams | ApiResult<PagedResult<Opportunity>> | Stateless page fetch; `hasMore` from `next != null` |
| GetOpportunityUseCase | int opportunityId | ApiResult<Opportunity> | Same list endpoint with `opportunity_id`; empty → NotFoundFailure |
| WatchCrmChangesUseCase | — | Stream<CrmDataChange> | Passes through all changes (both kinds) |

## 5 API & storage

Wire keys in `core/constants/api_keys.dart`, endpoints in `core/constants/endpoints.dart`:

| Call | Method | Notes |
|------|--------|-------|
| `/crm/opportunities_view/` | GET | query `page`, `page_size`, `title`, `stage`, `status`, `customer_id`, `opportunity_id`; DRF-style envelope |
| `/crm/opportunities_view/` | GET (+`opportunity_id`) | Same endpoint; at most one result; empty = not found |

## 6 State

- `OpportunitiesListBloc`: `Initial` → `Loading` → `Success`/`Empty`/`Error`. Search debounced (300 ms) + restartable; filters immediate + restartable; refresh restartable (keeps data on screen); load-more droppable (ignores repeats in flight). `hasMore` = `next != null`. Never re-sorts across pages. **Not subscribed to CRM change signal.**
- `OpportunityDetailsCubit`: `Initial` → `Loading` → `Success`/`Error`. Load once per opportunity; silent reload on CRM signal when `change.opportunityId == loaded id`.

## 7 DI

`core/di/opportunities_injection.dart` — `initOpportunitiesModule`: remote data source (lazy singleton), repository (lazy singleton), use cases (lazy singleton), holders (factory — one per screen). Depends on `BaseApiClient` and `CrmDataChangeService` from core. Wired into `injection_container.dart` after `initCustomerNotesModule`.

## 8 i18n

None — no screens or user-facing text yet. All future screen text will go through slang.

## 9 Tests

`test/features/opportunities/` (mocktail + bloc_test):
- **Use cases**: get_opportunities (3), get_opportunity (2 incl. not-found), watch (1).
- **Enums**: stage (6 — all wire values + unknown fallback), status (4).
- **Models**: opportunity (10), opportunity_customer (5), opportunity_employee (2), contact (3), embedded_note (4), embedded_interaction (6), opportunities_page_response (3).
- **Remote data source**: 6 tests — page query passthrough (page, page_size, filters), detail query (`opportunity_id` + page=1/page_size=1), error mapping, malformed body → ParsingFailure, enum wire values, `next` never parsed as URL.
- **Repository**: 5 tests — `PagedResult` mapping (`hasMore` from `next`, `nextPage = page + 1`), server order preserved, detail success, detail not-found (empty results).
- **Cubits/Bloc**: list lifecycle (7), list debounce+restartable (4), load-more droppable (3), load-more failure keeps items (2), hasMore false on `next == null` (2), refresh (3), detail success/not-found/signal reload (5).

## 10 Known issues

- No screens, routes or i18n yet — holders are DI-ready but not reachable from the UI.
- `OpportunitiesListBloc` is intentionally not subscribed to the CRM change signal — list items never render embedded notes or interactions.

## 11 Changelog

- 2026-11-01: Opportunities feature end to end (domain → data → presentation → DI → tests planned): `Opportunity`, `OpportunityCustomer`, `OpportunityEmployee`, `CustomerContact`, `EmbeddedCustomerNote`, `EmbeddedCustomerInteraction` entities; `OpportunityStage`/`OpportunityStatus` enums with `unknown` fallback; `OpportunitiesCriteria`, `GetOpportunitiesParams`; `OpportunitiesRepository` + 3 use cases; 7 models; remote data source (GET page + GET one); repository impl (`PagedResult` mapping, detail not-found); `OpportunitiesListBloc` (debounced search, immediate filters, droppable load-more, `hasMore` from `next`), `OpportunityDetailsCubit` (silent signal reload); DI module wired into container; analyze clean, all files ≤300 lines.
