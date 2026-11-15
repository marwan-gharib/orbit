# Customer Notes Feature

> Last verified: 2026-11-15
> Path: `lib/features/customer_notes/`

## 1. Purpose

CRM customer notes end to end: a newest-first thread for one customer with an add composer,
edit sheet and delete dialog. Domain (entities/params/repository/use cases), data (models,
remote data source, repository impl), Cubit holders and the full widget layer. No routes of
its own — the public `CustomerNotesThread`/`CustomerNoteComposer` are embedded by the
opportunity detail page.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| Notes tab (embedded) | `RoutePaths.crmOpportunityDetails` | `id` (opportunity), customer id | Hosted by opportunities' `NotesTab`; no standalone route |
| Edit sheet / delete dialog | — (overlays) | noteId + initialText / note + customerId | `AppBottomSheet` and `showAppDialog`, opened by the thread |

## 3. File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/customer_notes_list/* | Load notes for a customer, refresh, silent refetch on the CRM signal (matching customer id) |
| presentation | cubits/customer_note_form/* | One-shot add/edit submit; edit customer id from the held note |
| presentation | cubits/customer_note_delete/* | One-shot delete with InProgress/Success/Failure states |
| presentation | view_models/customer_note_view_model.dart, mappers/customer_note_mapper.dart | Leaf-safe note values (author, initials, text, createdAt); CustomerNote → view model |
| presentation | constants/note_layout_constants.dart | Shared geometry: row, skeleton twin, composer |
| presentation | widgets/customer_notes_thread.dart | Public thread; owns (or takes a page-owned) list cubit, opens edit sheet + delete dialog |
| presentation | widgets/customer_notes_view.dart | Header + refresh notice + loading/content/empty/error body |
| presentation | widgets/note_thread_content.dart | Id-diffed list with arrival/edit flash and departure collapse |
| presentation | widgets/note_tile.dart, note_timestamp.dart, note_text_body.dart, note_thread_header.dart | Row (avatar, author, menu), relative time + tooltip semantics, 6-line clamp with Show more/less, title + plural count |
| presentation | widgets/note_thread_skeleton.dart, note_refresh_notice.dart | Loading twin (one shimmer driver, localized copy); dismissible silent-refresh failure notice |
| presentation | widgets/customer_note_composer.dart, note_send_button.dart | Public bottom bar; owns the persistent form cubit, keyboard-safe; send action morphing idle/sending/sent/failed |
| presentation | widgets/note_edit_sheet.dart, note_delete_dialog.dart | Bottom-sheet editor with discard confirmation; delete dialog with in-button progress |
| domain | entities/customer_note_entity.dart, note_customer_details_entity.dart, note_employee_details_entity.dart, customer_notes_result_entity.dart | CustomerNote; embedded customer/employee details; result (notes + total) |
| domain | params/add_customer_note_params.dart, update_customer_note_params.dart | customerId + noteText; noteId + noteText (note id is a path param, not body) |
| domain | repositories/customer_notes_repository.dart, usecases/* | Contract; Get, Add, Update (+customerId), Delete (+customerId), WatchNoteChanges |
| data | datasources/remote/customer_notes_remote_data_source.dart | GET list by customer_id, POST add, PATCH note_text-only body by id, DELETE by id — through BaseApiClient |
| data | models/note_model.dart, note_customer_details_model.dart, note_employee_details_model.dart, customer_notes_response_model.dart | Strict wire parse; nested details; `{"customer_id", "total", "notes"}` root |
| data | repositories/customer_notes_repository_impl.dart | Sorts newest-first (createdAt desc, id desc); publishes CrmDataChange on success only |

## 4. Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| CustomerNote | noteId, customerId, employeeId, noteText, createdAt, customerDetails, employeeDetails | NoteModel | createdAt parsed via `WireDates` (UTC-normalized instant) |
| NoteCustomerDetails | customerId, customerCode, name, companyName | NoteCustomerDetailsModel | |
| NoteEmployeeDetails | employeeId, employeeCode, name, workEmail | NoteEmployeeDetailsModel | |
| CustomerNotesResult | notes, total | CustomerNotesResponseModel | total is server-reported, display-only |

## 5. Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetCustomerNotesUseCase | int customerId | ApiResult<CustomerNotesResult> | Pass-through to repository |
| AddCustomerNoteUseCase | AddCustomerNoteParams | ApiResult<void> | Employee derived server-side; nothing about the signed-in user is sent |
| UpdateCustomerNoteUseCase | UpdateCustomerNoteParams + customerId | ApiResult<void> | note_text only; customerId signals the change |
| DeleteCustomerNoteUseCase | int noteId + customerId | ApiResult<void> | DELETE by id in path; customerId signals the change |
| WatchNoteChangesUseCase | — | Stream<CrmDataChange> | Filters the core signal to the note kind |

## 6. API & storage

| Endpoint / key (constant) | Method | Notes |
|---------------------------|--------|-------|
| `Endpoints.crmCustomerNotes` | GET | query `customer_id` (ApiKeys); root `{"customer_id", "total", "notes"}` |
| `Endpoints.crmCustomerNotes` | POST | body `customer_id`, `note_text`; 201 = success, body not parsed |
| `Endpoints.crmCustomerNoteById` | PATCH | body `note_text` only; note id is a path segment |
| `Endpoints.crmCustomerNoteById` | DELETE | no body |

## 7. State

- `CustomerNotesListCubit`: `Initial` → `Loading` → `Success`/`Empty`/`Error`. Load once per customer; `refresh()` from `Initial`/`Error` is a full load, from `Success`/`Empty` it is silent (`isRefreshing: true`; failure keeps data and sets `refreshFailure`). CRM signal triggers a silent refresh when kind == note and customerId matches.
- `CustomerNoteFormCubit`: `Initial` → `Ready` → `Submitting` → `Success`/`SubmitError`; one-shot; add takes the customer id from the caller, edit from the held note; the composer calls `startAdd()` after a success.
- `CustomerNoteDeleteCubit`: `Initial` → `InProgress` → `Success`/`Failure`; one-shot.
- The thread recreates its list cubit on customer change; a page that must keep notes alive across tab switches passes its own cubit (used by the opportunity detail page).

## 8. Dependencies

- Depends on (core): BaseApiClient, CrmDataChangeService, Endpoints/ApiKeys, WireDates, core widgets, core animations (overlays, stagger, flash, shake, progress, switcher, shimmer), core/responsive, core/theme, core/i18n.
- Depends on (features): none.
- Used by (features): opportunities — its detail page owns the page-scoped list cubit and hosts the thread + composer in the Notes tab.
- DI file: `core/di/customer_notes_injection.dart` — `initCustomerNotesModule` (datasource/repository/use cases lazy singletons, holders factory); wired after `initInteractionsModule`. The thread's getIt lookups are a deliberate DI-4 exception: it is the action container for its one-shot cubits.

## 9. Localization

- Namespace: `context.t.crm.crmNotes.*` in `assets/i18n/en.i18n.json` (slang): thread title, singular/plural count, composer, send states, edit/save/discard, delete, show more/less, refresh failure, `relative.*` (now/minute/hour/day + plurals), timestamp accessibility, overflow tooltip; shared copy reuses `crm.common.*` and `crm.editor.*`.

## 10. Business rules & edge cases

- The repository order is rendered as-is — the thread never sorts (newest-first: createdAt desc, id desc).
- A silent refresh keeps data on screen with a dismissible failure notice; data is only dropped when there is none yet.
- Rows are id-diffed: arrivals/edits flash, departures collapse one frame late, at most `NoteLayoutConstants.maxDepartingRows` stay mounted.
- The 6-line clamp shows Show more/Show less only when the text overflows at the current width and text scale.
- `NoteEditSheet`: Save enabled only when the trimmed text changed, discard confirmed only when dirty, pop blocked while submitting, drag handle hidden so a dirty draft cannot be swiped away.
- `NoteDeleteDialog`: progress inside the destructive button, barrier/back dismissal blocked while deleting, closes only on success, otherwise localized failure copy.
- Composer: sits above `viewInsets` + bottom safe area, keeps typed text across failures, clears only after a success, disables send on whitespace and while sending.
- Note timestamps: relative time, absolute CRM date in tooltip and semantics; the avatar is semantics-excluded so the author name is read.

## 11. Tests

`test/features/customer_notes/` (mocktail + bloc_test), 27 files / 104 cases; shared `customer_notes_test_mocks.dart`:

| Area | Files (cases) |
|------|---------------|
| Use cases | get (3), add (4), update (4), delete (3), watch (2) |
| Models | note (3), note_customer_details (2), note_employee_details (2), customer_notes_response (3) |
| Data | remote data source (5), repository (5) |
| Cubits | list (9), form (7), delete (4) |
| Mapper | customer_note_mapper (3) |
| Widgets | timestamp (4), text body (3), tile (4), skeleton (2), thread content (5), view (6), composer (5), edit sheet (4), delete dialog (3), thread (5), refresh notice (2), layout at 360x640 + tablet at text scale 1.5 (2) |

Core additions covered by their own tests: `Formatters.relativeParts`, `AppTextField.minLines`, `AppBottomSheet.showDragHandle`.

## 12. Known issues / TODO

none.

## 13. Changelog

- 2026-11-15 — Test suite completed (18 new cases: 5 use-case tests — get/add/update/delete/watch — plus the refresh-notice widget test); Tests table updated to 27 files/104 cases, use-case-gap known issue removed.

- 2026-11-12 — Doc repaired against the working tree: restructured to the 13 template sections, endpoints by constant name (`Endpoints.crmCustomerNotes` / `crmCustomerNoteById`), Tests rewritten to the real 20 files/86 cases (the doc's use-case tests do not exist), the thread's optional page-owned cubit documented, obsolete "no page wires the widgets yet" issue dropped.
- 2026-11-08: `CustomerNotesThread` accepts an optional page-owned `cubit` so notes survive tab switches (used by the opportunity detail page).
- 2026-11-04: Presentation UI end to end — thread/composer/view, id-diff content, tile/timestamp/clamp, skeleton, notice, send button, edit sheet, delete dialog, view model + mapper, layout constants; silent-refresh keep-data; `crm.crmNotes.*` i18n; core additions `Formatters.relativeParts`, `AppTextField.minLines`, `AppBottomSheet.showDragHandle`.
- 2026-11-01: Feature end to end — entities/params, repository + 5 use cases, 4 models, remote data source (GET/POST/PATCH/DELETE-by-id), repository impl (newest-first sort, success-only signal publish), 3 Cubits, DI module.
