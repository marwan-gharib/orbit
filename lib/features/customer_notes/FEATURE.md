# Customer Notes Feature

> Last verified: 2026-11-04
> Path: `lib/features/customer_notes/`

## 1 Purpose

CRM customer notes end to end — list notes for a customer, add, edit and delete.
Domain entities, params and repository contract; data models, remote data source
and repository implementation; Cubit holders; and the presentation widgets
(`CustomerNotesThread`, `CustomerNoteComposer`, edit sheet, delete dialog,
skeletons and states). No pages, routes or shell wiring yet: the public widgets
are ready for a customer page to embed.

## 2 File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/customer_notes_list/customer_notes_list_cubit.dart | Load notes for a customer, refresh, silent refetch on the CRM change signal (matching customer id) |
| presentation | cubits/customer_notes_list/customer_notes_list_state.dart | Initial, Loading, Success(notes+total), Empty, Error — `isRefreshing`/`refreshFailure` on silent refresh |
| presentation | cubits/customer_note_form/customer_note_form_cubit.dart | One-shot add/edit submit; edit customer id from the held note |
| presentation | cubits/customer_note_form/customer_note_form_state.dart | Initial, Ready, Submitting, Success, SubmitError states |
| presentation | cubits/customer_note_delete/customer_note_delete_cubit.dart | One-shot delete with InProgress/Success/Failure states |
| presentation | cubits/customer_note_delete/customer_note_delete_state.dart | Initial, InProgress, Success, Failure states |
| presentation | view_models/customer_note_view_model.dart | Leaf-safe note values (author, initials, text, createdAt) |
| presentation | mappers/customer_note_mapper.dart | `CustomerNote` → `CustomerNoteViewModel` |
| presentation | constants/note_layout_constants.dart | Shared geometry for the row, its skeleton twin and the composer |
| presentation | widgets/customer_notes_thread.dart | Public thread; owns the list cubit, opens the edit sheet and delete dialog |
| presentation | widgets/customer_notes_view.dart | Header + refresh notice + loading/content/empty/error body |
| presentation | widgets/note_thread_content.dart | Id-diffed list with arrival/edit flash and departure collapse |
| presentation | widgets/note_tile.dart | One note: initials avatar, author, time, clamped body, overflow menu |
| presentation | widgets/note_timestamp.dart | Localized relative time, absolute CRM date in tooltip and semantics |
| presentation | widgets/note_text_body.dart | Six-line clamp with Show more / Show less only when it overflows |
| presentation | widgets/note_thread_header.dart | Title and plural note count |
| presentation | widgets/note_thread_skeleton.dart | Loading twin, one shimmer driver, localized "Loading notes…" |
| presentation | widgets/note_refresh_notice.dart | Dismissible notice after a failed silent refresh |
| presentation | widgets/customer_note_composer.dart | Public bottom bar; owns the persistent form cubit, keyboard-safe |
| presentation | widgets/note_send_button.dart | Circular send action morphing idle/sending/sent/failed |
| presentation | widgets/note_edit_sheet.dart | Bottom-sheet editor with discard confirmation |
| presentation | widgets/note_delete_dialog.dart | Delete confirmation with in-button progress and failure copy |
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

- `CustomerNotesListCubit`: `Initial` → `Loading` → `Success`/`Empty`/`Error`. Load once per customer; `refresh()` from `Initial`/`Error` is a full load, from `Success`/`Empty` it is silent: the same data stays on screen with `isRefreshing: true`, and a failing refresh keeps the data and sets `refreshFailure` instead of dropping to `Error`. CRM change signal triggers a silent refresh when `kind == note` and `customerId` matches the loaded customer.
- `CustomerNoteFormCubit`: `Initial` → `Ready` → `Submitting` → `Success`/`SubmitError`. One-shot per submit; add takes the customer id from the caller, edit from the held note. The composer calls `startAdd()` after a success; sheets and dialog cubits are created per invocation and closed by the thread.
- `CustomerNoteDeleteCubit`: `Initial` → `InProgress` → `Success`/`Failure`. One-shot per delete.

## 7 UI

- `CustomerNotesThread(customerId)` — public, non-scrolling, sizes to its content; owns the list cubit (recreated on customer id change) and performs the getIt lookups for the one-shot form/delete cubits. Never sorts: the repository order is rendered as-is.
- `CustomerNoteComposer(customerId)` — public bottom bar; owns a persistent form cubit, sits above `viewInsets` + bottom safe area, keeps typed text across failures, clears only after a success, disables send on whitespace and while sending.
- Thread states: skeleton on `Initial`/`Loading` (no spinner), content, empty, full error with retry, plus a dismissible warning notice while `refreshFailure` is set (dismissal is UI-local and keyed by failure identity).
- Row: initials avatar (semantics-excluded, author name is read), author, relative time with absolute date in tooltip and semantics, 6-line clamp with Show more/Show less only when the text overflows at the current width and text scale, overflow menu with Edit and Delete.
- Motion: `StaggeredListItem` for the first entrance capped by the core stagger cap, `HighlightFlash` for arrivals and edits, a one-frame-late `AnimatedVisibility` collapse for departures (at most `NoteLayoutConstants.maxDepartingRows` kept mounted), `AnimatedProgressBar` during a silent refresh, `AppAnimatedSwitcher` between thread states, `ShakeWidget` on an edit failure.
- Sheets and dialogs: `AppBottomSheet` with the form cubit supplied by the thread; `NoteEditSheet` receives plain `noteId`/`initialText`, autofocuses, enables Save only when the trimmed text changed, confirms discard only when dirty, blocks pop while submitting and hides its drag handle so a dirty draft cannot be swiped away without the confirmation. `showAppDialog` + `NoteDeleteDialog` receives an `onConfirm` callback, shows progress inside the destructive button, does not dismiss from the barrier or back while deleting, closes only on success and keeps the dialog open with localized failure copy otherwise.

## 8 DI

`core/di/customer_notes_injection.dart` — `initCustomerNotesModule`: remote data source (lazy singleton), repository (lazy singleton), use cases (lazy singleton), holders (factory — one per screen). Depends on `BaseApiClient` and `CrmDataChangeService` from core. Wired into `injection_container.dart` after `initInteractionsModule`. The thread's getIt lookups are a deliberate DI-4 exception: it is the action container for its one-shot cubits.

## 8.1 Used by

- `crm_shell` — consumes `CustomerNotesThread` and `CustomerNoteComposer` via `OpportunityDetailPage` → `NotesTab`.

## 9 i18n

`crm.crmNotes.*` in `assets/i18n/en.i18n.json` (generated by `dart run slang`): thread title, singular/plural count, loading, empty, composer label/hint, send states, edit/save/discard, delete confirmation, show more/less, refresh failure, `relative.*` (now/minute/hour/day plus plural forms), timestamp accessibility, overflow tooltip. Shared copy reuses `crm.common.*` and `crm.editor.discardTitle`/`discardBody`.

## 10 Tests

`test/features/customer_notes/` (mocktail + bloc_test):

- **Use cases**: get (2), add (1), update (2), delete (2), watch (1).
- **Models**: note (5), note_customer_details (2), note_employee_details (2), customer_notes_response (3).
- **Remote data source**: 6 tests — GET query passthrough, POST body keys, PATCH note_text-only body, DELETE-by-id path, error mapping, malformed body → ParsingFailure.
- **Repository**: 5 tests — sort newest-first, publish CrmDataChange on success (add/update/delete), never on failure.
- **Cubits**: list lifecycle (6), list signal refresh matching/non-matching (3), silent-refresh keep-data and failure (3), form (6), delete (4).
- **Mapper**: 3 tests — author/initials/text/createdAt mapping and empty-name initials.
- **Widgets** (43): timestamp (4), text clamp (3), tile/menu (4), skeleton (2), id-diff content + departure collapse (5), view states + notice (6), composer (5), edit sheet (4), delete dialog (3), thread integration with getIt, edit/delete and sheet/dialog dismissal guards (5), 360x640 + tablet layout at 1.5 text scale (2).

Core additions covered by their own tests: `Formatters.relativeParts` (5), `AppTextField.minLines` (1), `AppBottomSheet.showDragHandle` (1).

## 11 Known issues

- No page or route wires the widgets yet — `CustomerNotesThread` and `CustomerNoteComposer` are reachable only by embedding them in a customer page.

## 12 Changelog

- 2026-11-04: Presentation UI: `CustomerNotesThread`, `CustomerNoteComposer`, `CustomerNotesView`, `NoteThreadContent` (id diff, arrival/edit flash, departure collapse), `NoteTile`/`NoteTimestamp`/`NoteTextBody`/`NoteThreadHeader`, `NoteThreadSkeleton`, `NoteRefreshNotice`, `NoteSendButton`, `NoteEditSheet`, `NoteDeleteDialog`, view model + mapper, layout constants; silent-refresh keep-data behavior in the list cubit; `crm.crmNotes.*` i18n; core additions `Formatters.relativeParts`, `AppTextField.minLines`, `AppBottomSheet.showDragHandle`.
- 2026-11-01: Customer notes feature end to end (domain → data → presentation → DI → tests planned): `CustomerNote`, `NoteCustomerDetails`, `NoteEmployeeDetails`, `CustomerNotesResult`, `AddCustomerNoteParams`, `UpdateCustomerNoteParams`, `CustomerNotesRepository` + 5 use cases; `NoteModel`, `NoteCustomerDetailsModel`, `NoteEmployeeDetailsModel`, `CustomerNotesResponseModel`; remote data source (GET/POST/PATCH/DELETE-by-id); repository impl (newest-first sort, success-only `CrmDataChange` publish); `CustomerNotesListCubit` (customer-scoped load/refresh/silent signal refresh), `CustomerNoteFormCubit`, `CustomerNoteDeleteCubit`; DI module wired into container; analyze clean, all files ≤300 lines.
