# Customer Notes Feature

> Last verified: 2026-11-01
> Path: `lib/features/customer_notes/`

## 1 Purpose

CRM customer notes end to end — list notes for a customer, add, edit and delete.
Domain entities, params and repository contract; data models, remote data source
and repository implementation; and presentation holders (Cubits only — no search,
no debounce, no pagination). No screens, routes or i18n yet: the holders are wired
into DI and ready for a screen layer to consume.

## 2 File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/customer_notes_list/customer_notes_list_cubit.dart | Load notes for a customer, refresh, silent refetch on the CRM change signal (matching customer id) |
| presentation | cubits/customer_notes_list/customer_notes_list_state.dart | Initial, Loading, Success(notes+total), Empty, Error — `isRefreshing`/`refreshFailure` on silent refresh |
| presentation | cubits/customer_note_form/customer_note_form_cubit.dart | One-shot add/edit submit; edit customer id from the held note |
| presentation | cubits/customer_note_form/customer_note_form_state.dart | Initial, Ready, Submitting, Success, SubmitError states |
| presentation | cubits/customer_note_delete/customer_note_delete_cubit.dart | One-shot delete with InProgress/Success/Failure states |
| presentation | cubits/customer_note_delete/customer_note_delete_state.dart | Initial, InProgress, Success, Failure states |
| domain | entities/customer_note_entity.dart | CustomerNote (equatable) |
| domain | entities/note_customer_details_entity.dart | NoteCustomerDetails (equatable) |
| domain | entities/note_employee_details_entity.dart | NoteEmployeeDetails (equatable) |
| domain | entities/customer_notes_result_entity.dart | CustomerNotesResult (notes + total) |
| domain | params/add_customer_note_params.dart | customerId + noteText |
| domain | params/update_customer_note_params.dart | noteId + noteText (note id is path param, not body) |
| domain | repositories/customer_notes_repository.dart | Repository contract |
| domain | usecases/*.dart (5) | Get, Add, Update (+customerId), Delete (+customerId), WatchNoteChanges |
| data | datasources/remote/customer_notes_remote_data_source.dart | GET list by customer_id, POST add, PATCH note_text-only body by id, DELETE by id — all through BaseApiClient |
| data | models/note_model.dart | Strict wire parse; nested customer_details + employee_details models |
| data | models/note_customer_details_model.dart | customer_details parse |
| data | models/note_employee_details_model.dart | employee_details parse |
| data | models/customer_notes_response_model.dart | `{"customer_id": ..., "total": ..., "notes": [...]}` parse |
| data | repositories/customer_notes_repository_impl.dart | Sorts newest-first (createdAt desc, id desc); publishes CrmDataChange on success only |

## 3 Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| CustomerNote | noteId, customerId, employeeId, noteText, createdAt, customerDetails, employeeDetails | NoteModel | createdAt parsed via WireDates (UTC-normalized instant) |
| NoteCustomerDetails | customerId, customerCode, name, companyName | NoteCustomerDetailsModel | |
| NoteEmployeeDetails | employeeId, employeeCode, name, workEmail | NoteEmployeeDetailsModel | |
| CustomerNotesResult | notes, total | CustomerNotesResponseModel | total is server-reported, display-only |

## 4 Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetCustomerNotesUseCase | int customerId | ApiResult<CustomerNotesResult> | Pass-through to repository |
| AddCustomerNoteUseCase | AddCustomerNoteParams | ApiResult<void> | Employee derived server-side; nothing sent about signed-in user |
| UpdateCustomerNoteUseCase | UpdateCustomerNoteParams + customerId | ApiResult<void> | note_text only; customerId signals the change |
| DeleteCustomerNoteUseCase | int noteId + customerId | ApiResult<void> | DELETE by id in path; customerId signals the change |
| WatchNoteChangesUseCase | — | Stream<CrmDataChange> | Filters core signal to `note` kind |

## 5 API & storage

Wire keys in `core/constants/api_keys.dart`, endpoints in `core/constants/endpoints.dart`:

| Call | Method | Notes |
|------|--------|-------|
| `/crm/customer-notes/` | GET | query `customer_id`; root `{"customer_id": ..., "total": ..., "notes": [...]}` |
| `/crm/customer-notes/` | POST | body `customer_id`, `note_text` (201 = success, body not parsed) |
| `/crm/customer-notes/{note_id}/` | PATCH | body `note_text` only |
| `/crm/customer-notes/{note_id}/` | DELETE | no body |

## 6 State

- `CustomerNotesListCubit`: `Initial` → `Loading` → `Success`/`Empty`/`Error`. Load once per customer; refresh reloads the same customer. CRM change signal triggers silent refresh when `kind == note` and `customerId` matches the loaded customer.
- `CustomerNoteFormCubit`: `Initial` → `Ready` → `Submitting` → `Success`/`SubmitError`. One-shot per submit.
- `CustomerNoteDeleteCubit`: `Initial` → `InProgress` → `Success`/`Failure`. One-shot per delete.

## 7 DI

`core/di/customer_notes_injection.dart` — `initCustomerNotesModule`: remote data source (lazy singleton), repository (lazy singleton), use cases (lazy singleton), holders (factory — one per screen). Depends on `BaseApiClient` and `CrmDataChangeService` from core. Wired into `injection_container.dart` after `initInteractionsModule`.

## 8 i18n

None — no screens or user-facing text yet. All future screen text will go through slang.

## 9 Tests

`test/features/customer_notes/` (mocktail + bloc_test):
- **Use cases**: get (2), add (1), update (2), delete (2), watch (1).
- **Models**: note (5), note_customer_details (2), note_employee_details (2), customer_notes_response (3).
- **Remote data source**: 6 tests — GET query passthrough, POST body keys, PATCH note_text-only body, DELETE-by-id path, error mapping, malformed body → ParsingFailure.
- **Repository**: 5 tests — sort newest-first, publish CrmDataChange on success (add/update/delete), never on failure.
- **Cubits**: list lifecycle (6), list signal refresh matching/non-matching (3), form (6), delete (4).

## 10 Known issues

- No screens, routes or i18n yet — holders are DI-ready but not reachable from the UI.

## 11 Changelog

- 2026-11-01: Customer notes feature end to end (domain → data → presentation → DI → tests planned): `CustomerNote`, `NoteCustomerDetails`, `NoteEmployeeDetails`, `CustomerNotesResult`, `AddCustomerNoteParams`, `UpdateCustomerNoteParams`, `CustomerNotesRepository` + 5 use cases; `NoteModel`, `NoteCustomerDetailsModel`, `NoteEmployeeDetailsModel`, `CustomerNotesResponseModel`; remote data source (GET/POST/PATCH/DELETE-by-id); repository impl (newest-first sort, success-only `CrmDataChange` publish); `CustomerNotesListCubit` (customer-scoped load/refresh/silent signal refresh), `CustomerNoteFormCubit`, `CustomerNoteDeleteCubit`; DI module wired into container; analyze clean, all files ≤300 lines.
