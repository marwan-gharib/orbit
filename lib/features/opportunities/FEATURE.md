# Opportunities Feature

> Last verified: 2026-11-12
> Path: `lib/features/opportunities/`

## 1. Purpose

CRM opportunities end to end: a paginated list with title search, stage/status filters and
silent pull-to-refresh, plus a read-only detail page (collapsing header, stage stepper,
probability ring, tabs for overview/contacts/interactions/notes and a "Log it?" prompt after
a call/email). Mobile is read-only — no create, edit or stage move.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| Opportunities tab | `RoutePaths.crm` | — | Composed by `crm_shell` at `/crm`; the route provides `OpportunitiesListBloc` |
| Opportunity detail | `RoutePaths.crmOpportunityDetails` | `id` | Container-transform + AppHero flight; unparsable `id` → invalid-id page |

## 3. File map

| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | blocs/opportunities_list/* | Paginated list Bloc, events and states (search, filters, refresh, load-more) |
| presentation | cubits/opportunity_details/* | Read-only detail Cubit + state; silent CRM-signal reload |
| presentation | constants/opportunity_layout_constants.dart | Shared geometry: card, skeleton twins, detail sections, stepper |
| presentation | constants/opportunity_hero_tags.dart | AppHero ids pairing list card and detail header (title/value/status) |
| presentation | pure/list_highlight_ids.dart | Pure id-diff: which cards flash after a silent refresh |
| presentation | pure/embedded_interaction_to_tile_data.dart, contact_to_interaction_option.dart | Interaction → tile data; contact → uniquely labeled sheet option |
| presentation | widgets/opportunities_tab_view.dart | List tab: header, chips, status filter, refresh, lazy list, state bodies |
| presentation | widgets/opportunities_list_header.dart | Animated count (skeleton while loading), expanding search, filter button + badge |
| presentation | widgets/opportunities_stage_chips.dart, opportunities_status_filter.dart | Stage chips (All + 5) and All/Open/Won/Lost segmented control, sliding indicators |
| presentation | widgets/opportunities_list_sliver.dart | Lazy cards + footer; one-time stagger; flash highlight on refresh |
| presentation | widgets/opportunities_list_footer.dart, opportunities_list_notices.dart | Load-more loader/retry/end; refresh notice; empty and error views |
| presentation | widgets/opportunity_card.dart, opportunity_card_skeleton.dart | Card (whole-surface tap, badge, ring, stage, overdue) and its skeleton twin |
| presentation | widgets/opportunity_detail_page.dart | Detail page: skeleton/success/error switch, mounted tabs, silent refresh |
| presentation | widgets/opportunity_detail_app_bar.dart, opportunity_detail_error_view.dart | Pinned bar + parallax header; full-screen error/not-found with Retry |
| presentation | widgets/opportunity_header.dart | Detail header: title/status/stage/value/dates; AppHero flight |
| presentation | widgets/opportunity_details_card.dart, customer_overview_card.dart | Overview facts card; customer card (avatar, contact info, code) |
| presentation | widgets/status_banner.dart, progress_card.dart, stage_stepper.dart | Won/Lost banner; probability ring + stage stepper; 5-node animated stepper |
| presentation | widgets/opportunity_tab_bar.dart, opportunity_tab_bar_delegate.dart | Sticky tab bar with count badges; its pinned-header delegate |
| presentation | widgets/overview_tab.dart, contacts_tab.dart, interactions_tab.dart, notes_tab.dart | The four detail tabs (tabs stay mounted once visited) |
| presentation | widgets/contact_card.dart, log_it_prompt_sheet.dart | Contact card (primary first); "Log it?" prompt after call/email |
| presentation | widgets/opportunity_detail_skeleton.dart, opportunity_detail_skeleton_overview.dart | Detail and overview-tab skeleton twins (per-section ShimmerScope) |
| domain | entities/*, enums/*, params/* | Opportunity aggregate entities, stage/status enums, criteria + page params |
| domain | repositories/opportunities_repository.dart | Repository contract: stateless page fetch + detail |
| domain | usecases/* | GetOpportunities, GetOpportunity, WatchCrmChanges |
| data | datasources/remote/opportunities_remote_data_source.dart | GET page + GET one through BaseApiClient; GET only |
| data | models/* | Strict wire parse: opportunity, customer, employee, contact, note, interaction, page |
| data | repositories/opportunities_repository_impl.dart | PagedResult mapping; server order; empty detail → NotFoundFailure |

## 4. Entities & models

| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| Opportunity | opportunityId, title, estimatedValue, currency, stage, probability, expectedCloseDate, status, lostReason, createdAt, closedAt?, customer, employee | OpportunityModel | Stage/status enums fall back to `unknown`; probability is server data only |
| OpportunityCustomer | customerId, customerCode, firstName, lastName, phone, companyName, email, address, leadSource?, createdAt, updatedAt, contacts[], notes[], interactions[] | OpportunityCustomerModel | Embedded notes/interactions are lighter shapes |
| OpportunityEmployee | employeeId, employeeName | OpportunityEmployeeModel | The opportunity owner, not the logged-in user |
| CustomerContact | contactId, name, jobTitle, email, phone, isPrimary | ContactModel | Metadata only |
| EmbeddedCustomerNote | noteId, employeeId, employeeName, noteText, createdAt | EmbeddedNoteModel | Lighter than standalone CustomerNote |
| EmbeddedCustomerInteraction | interactionId, employeeId, employeeName, type, subject, description, interactionDate, contactId?, opportunityId? | EmbeddedInteractionModel | Uses the shared `InteractionType` from interactions |

## 5. Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| GetOpportunitiesUseCase | GetOpportunitiesParams | ApiResult<PagedResult<Opportunity>> | Stateless page fetch; `hasMore` from `next != null` |
| GetOpportunityUseCase | int opportunityId | ApiResult<Opportunity> | List endpoint with `opportunity_id`; empty → NotFoundFailure |
| WatchCrmChangesUseCase | — | Stream<CrmDataChange> | Passes through all changes |

## 6. API & storage

| Endpoint / key (constant) | Method | Used by (datasource method) | Cache policy |
|---------------------------|--------|-----------------------------|--------------|
| `Endpoints.crmOpportunitiesView` | GET | page fetch — query `page`, `page_size`, `title`, `stage`, `status`, `customer_id` (ApiKeys) | none |
| `Endpoints.crmOpportunitiesView` | GET | detail — same endpoint adding `opportunity_id`, page=1/page_size=1 | none |

## 7. State

- `OpportunitiesListBloc` — Bloc (needs per-event transformers). Search debounced 300 ms + restartable; `FiltersChanged`/`FiltersCleared` and `Refreshed` restartable; `LoadMoreRequested` droppable. A monotonic query token drops stale responses. Not subscribed to the CRM change signal (intentional).
- `OpportunityDetailsCubit` — Cubit: load once per opportunity; silent reload on the CRM signal for relevant note/interaction changes of this opportunity.
- States: `Initial`, `Loading`, `Success(items, hasMore, nextPage, totalCount, isRefreshing, isLoadingMore, loadMoreFailure, refreshFailure)`, `Empty(totalCount, isRefreshing, refreshFailure)`, `Error(failure)`; detail: `Initial`, `Loading`, `Success(opportunity, isRefreshing, refreshFailure)`, `Error`.
- Pagination: `page`/`page_size` (`AppConsts.crmOpportunitiesPageSize`); `hasMore` from `next != null`; `count` display-only.

## 8. Dependencies

- Depends on (core): BaseApiClient, CrmDataChangeService, Endpoints/ApiKeys/AppConsts, Failure + `context.failureText`, PagedResult, core widgets (AppCard, AppButton, AppTextField, EmptyState, ErrorState), core animations (shimmer, AppHero, AnimatedCounter, chips, staggered, overlays), core/responsive, core/theme, core/i18n, core/router route constants.
- Depends on (features): interactions (InteractionsListBloc, timeline, tile skeleton, helpers, InteractionType), customer_notes (CustomerNotesListCubit, thread + composer).
- Used by (features): crm_shell — `OpportunitiesTabView` + list Bloc at `/crm`.
- DI file: `core/di/opportunities_injection.dart` — `initOpportunitiesModule` (datasource/repository/use cases lazy singletons, holders factory); wired in `injection_container.dart`.

## 9. Localization

- Namespace: `context.t.crm.crmOpportunities.*` in `assets/i18n/en.i18n.json` (slang).

## 10. Business rules & edge cases

- Read-only on mobile: GET only — the list cannot create, edit or move stage.
- `hasMore` derives from `next != null` only; `count` never drives paging; server order preserved (never re-sorted across pages).
- Detail loads through the list endpoint with `opportunity_id`; an empty result is `NotFoundFailure`.
- The list Bloc intentionally never subscribes to the CRM change signal — its items never render embedded notes/interactions.
- Filters use replace semantics: every dispatch carries all filter fields, a null clears one; "clear" also drops the search text.
- A failed silent refresh keeps items and shows a dismissible notice; a failed load-more keeps items and offers Retry; a failed first load shows the error view.
- Contact labels are disambiguated (job title, then phone/email/id) so sheet options stay unique.

## 11. Tests

`test/features/opportunities/` (mocktail + bloc_test), 12 files / 54 cases:

| Area | Files (cases) | Covered behaviors |
|------|---------------|-------------------|
| Enums | opportunity_stage (5), opportunity_status (4) | Wire values + `unknown` fallback |
| Models | opportunity_model (5), embedded_interaction_model (3), embedded_note_model (2), opportunities_page_response_model (3) | Strict parse, envelope, enum fallbacks |
| Data | opportunities_remote_data_source (4), opportunities_repository (4) | Query passthrough + detail query, error mapping; PagedResult mapping, order, not-found |
| Presentation | opportunities_list_bloc (9), opportunity_details_cubit (6) | Lifecycle, search/filters/clear, refresh, load-more; detail load/not-found/signal reload |
| Pure mapper | embedded_interaction_to_tile_data (4) | Embedded interaction → tile data |
| Widget | opportunity_card (5) | Whole-surface tap, overdue tag |
| Shared | opportunities_test_mocks.dart | mocktail mocks |

## 12. Known issues / TODO

- Coverage gap: use-case tests, remaining model tests (customer/employee/contact), `contact_to_interaction_option` and tab-view/detail-widget tests are absent from the working tree (pre-repair snapshot) — restore as its own task.
- `OpportunityTabBarDelegate` still claims fixed min/max extents (`Responsive.adapt(48)`); the same drift class that hit the old pinned list header can appear on off-design-scale surfaces — needs watching or a dedicated task.
- Core `AppButton` label rows can overflow under inflated font metrics (seen at text scale 1.3 in `EmptyState`); out of feature scope — core task.

## 13. Changelog

- 2026-11-12 — Doc repaired against the working tree after the CRM UI restructure: file map synced (list holder moved to `blocs/`, four new files listed), Tests rewritten to the 12 real files/54 cases, obsolete known issues dropped (animated count, removed pinned list header), detail page structure re-verified.
- 2026-11-08: UI batch 4 — list Bloc: `FiltersCleared` + replace-semantics filters, silent pull-to-refresh (failure keeps items); detail: mounted tabs, page-scoped notes/interactions, fading pinned bar; unique contact labels.
- 2026-11-07: UI batch 3 — inline status filter (sheet removed), header count skeleton, natural-height detail header with parallax, facts card redesign.
- 2026-11-05: List UI fixes — plural count + skeleton bone, 28dp sweep-only ring with FittedBox text, load-more footer wrap; removed the nested-scroll intrinsic-dimension crash; regression suite added.
- 2026-11-04: Full UI O1–O4 — layout constants, ProgressRing, hero tags, pure mappers, card + skeleton, tab view, detail page structure, contacts/interactions/notes tabs; pinned-header extent fix (80→72).
- 2026-11-01: Feature end to end — entities/enums/params, repository + 3 use cases, 7 models, remote data source, repository impl, list Bloc + detail Cubit, DI module.
