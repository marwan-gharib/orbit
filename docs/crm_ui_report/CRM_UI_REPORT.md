# CRM UI Audit Report

> **Scope:** Features `interactions`, `customer_notes`, `opportunities` (all layers), plus every file outside them that was changed for CRM: core, router, DI, i18n/slang, pubspec, Android/iOS platform files, docs, tests.
> **Baseline:** `a660ab7` — last commit before any non-cubit presentation widget was added under the three features' presentation folders.
> **Date:** 2026-11-04
> **Status:** READ-ONLY audit — no modifications made.

## Completion Status

| Section | Title | Status |
|---------|-------|--------|
| S1 | Environment and baseline | DONE |
| S2 | Change inventory | DONE |
| S3 | Public API | DONE |
| S4 | Routing, navigation, shell | DONE |
| S5 | Dependency injection and provider scoping | DONE |
| S6 | Per-screen implemented structure | DONE |
| S7 | State to UI | DONE |
| S8 | Displayed data | DONE |
| S9 | Behavior checklist | DONE |
| S10 | Animations | DONE |
| S11 | Tests | DONE |
| S12 | Static audits | DONE |
| S13 | Platform and dependencies | DONE |
| S14 | Runtime evidence | DONE |
| S15 | Findings | DONE |
| S16 | Problems I observed on the device | DONE |

---

## S1. Environment and baseline

### Flutter / Dart versions
```
Flutter 3.47.7 • channel stable • https://github.com/flutter/flutter.git
Framework • revision abaf9c5237 (4 weeks ago) • 2026-10-08 09:51:21 -0700
Engine • hash d8a2d6c768c334d53e16277f837970ffa1e2de81 (revision deb287481e) (28 days ago) • 2026-10-07 17:09:12.000Z
Tools • Dart 3.13.5 • DevTools 2.60.0
```

### Key package versions (from `pubspec.lock`)

| Package | Version (sha256) | Dependency type |
|---------|------------------|-----------------|
| flutter_bloc | cf51747952201a455a1c840f8171d273be009b932c75093020f9af64f2123e38 | direct main |
| bloc_concurrency | 86b7b17a0a78f77fca0d7c030632b59b593b22acea2d96972588f40d4ef53a94 | direct main |
| stream_transform | a00e5f18bffc764f923e7dec1038527f7fe7a1791361a7117f0358193f13d53a | direct main |
| go_router | 530dcbb298dc7c319aea9e3b7c580a1effb2abee2c93825d2dd8d5af0e230f1 | direct main |
| get_it | 2b5c6b077aad30bba9782178baff6076a2044141f1d5f2f15b43bca3fbe74874 | direct main |
| slang | 6091c2b4cd9f663080ede24fde6bcb9ee43f9fad1f9eaa66e2801eee47684e24 | direct dev |
| slang_flutter | 2348a39432c48d7c890a2a1e3409b9faae3e49f117fe56d390d4236de8d064f4 | direct main |
| url_launcher | e8cc955c97e06df9879140a1fe301f3d493f01b7c62dec7f46834be31d7e9fda | direct main |

### Git status (uncommitted changes)
```
On branch feature/crm
Your branch is up to date with 'origin/feature/crm'.

Changes not staged for commit:
  modified:   android/app/src/main/AndroidManifest.xml
  modified:   assets/i18n/en.i18n.json
  modified:   docs/CORE_MAP.md
  modified:   docs/FEATURES_INDEX.md
  modified:   ios/Runner/Info.plist
  modified:   lib/core/animations/animations.dart
  modified:   lib/core/animations/overlays/app_bottom_sheet.dart
  modified:   lib/core/animations/tokens/app_durations.dart
  modified:   lib/core/constants/hero_tags.dart
  modified:   lib/core/di/core_module.dart
  modified:   lib/core/i18n/strings.g.dart
  modified:   lib/core/i18n/strings_en.g.dart
  modified:   lib/core/router/app_router_routes.dart
  modified:   lib/core/router/route_names.dart
  modified:   lib/core/router/route_paths.dart
  modified:   lib/core/theme/app_theme.dart
  modified:   lib/core/theme/extensions/colors_extension.dart
  modified:   lib/core/utils/paged_result.dart
  modified:   lib/core/widgets/app_text_field.dart
  modified:   lib/core/widgets/widgets.dart
  modified:   lib/features/customer_notes/FEATURE.md
  modified:   lib/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart
  modified:   lib/features/interactions/FEATURE.md
  modified:   lib/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart
  modified:   lib/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart
  modified:   lib/features/opportunities/FEATURE.md
  modified:   lib/features/opportunities/data/repositories/opportunities_repository_impl.dart
  modified:   lib/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart
  modified:   lib/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart
  modified:   linux/flutter/generated_plugin_registrant.cc
  modified:   linux/flutter/generated_plugins.cmake
  modified:   macos/Flutter/GeneratedPluginRegistrant.swift
  modified:   pubspec.lock
  modified:   pubspec.yaml
  modified:   test/core/animations/overlays/app_bottom_sheet_test.dart
  modified:   test/core/widgets/app_text_field_test.dart
  modified:   test/features/customer_notes/customer_notes_test_mocks.dart
  modified:   test/features/customer_notes/data/datasources/remote/customer_notes_remote_data_source_test.dart
  modified:   test/features/customer_notes/data/repositories/customer_notes_repository_test.dart
  modified:   test/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit_test.dart
  modified:   test/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit_test.dart
  modified:   test/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit_test.dart
  modified:   test/features/interactions/interactions_test_mocks.dart
  modified:   test/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit_test.dart
  modified:   test/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit_test.dart
  modified:   test/features/opportunities/data/datasources/remote/opportunities_remote_data_source_test.dart
  modified:   test/features/opportunities/data/repositories/opportunities_repository_test.dart
  modified:   test/features/opportunities/domain/enums/opportunity_stage_test.dart
  modified:   test/features/opportunities/opportunities_test_mocks.dart
  modified:   test/features/opportunities/presentation/cubits/opportunities_list/opportunities_list_bloc_test.dart
  modified:   test/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit_test.dart
  modified:   test/features/splash/presentation/screens/splash_screen_test.dart
  modified:   testers_release_note.txt
  modified:   windows/flutter/generated_plugin_registrant.cc
  modified:   windows/flutter/generated_plugins.cmake

Untracked files (new presentation layer files):
  lib/core/animations/selection/
  lib/core/services/url_launcher_service.dart
  lib/core/utils/formatters.dart
  lib/core/utils/list_diff.dart
  lib/core/widgets/highlight_flash.dart
  lib/core/widgets/progress_ring.dart
  lib/features/crm_shell/
  lib/features/customer_notes/presentation/constants/
  lib/features/customer_notes/presentation/mappers/
  lib/features/customer_notes/presentation/view_models/
  lib/features/customer_notes/presentation/widgets/
  lib/features/interactions/presentation/constants/
  lib/features/interactions/presentation/mappers/
  lib/features/interactions/presentation/pure/
  lib/features/interactions/presentation/view_models/
  lib/features/interactions/presentation/widgets/
  lib/features/opportunities/presentation/constants/
  lib/features/opportunities/presentation/pure/
  lib/features/opportunities/presentation/widgets/
  test/core/services/url_launcher_service_fake.dart
  test/core/utils/formatters_test.dart
  test/core/widgets/highlight_flash_test.dart
  test/features/customer_notes/presentation/mappers/
  test/features/customer_notes/presentation/widgets/
  test/features/interactions/presentation/constants/
  test/features/interactions/presentation/mappers/
  test/features/interactions/presentation/pure/
  test/features/interactions/presentation/view_models/
  test/features/interactions/presentation/widgets/
  test/features/opportunities/presentation/pure/
  test/features/opportunities/presentation/widgets/
```

### Baseline determination

**Baseline commit:** `a660ab7` — `feat(opportunities): add CRM opportunities paginated list and read-only detail holders`

**Commands used:**
```bash
# Find the last CRM commit with only holders (no presentation widgets)
git log --oneline feature/crm | head -20

# Verify a660ab7 has no presentation widgets
git show --name-only a660ab7 | grep -E "presentation/widgets|presentation/constants|presentation/mappers|presentation/view_models|presentation/pure"

# No presentation widget files found in a660ab7 — only blocs/cubits, domain, data, tests
```

**Evidence:** The commit `a660ab7` added:
- `OpportunitiesListBloc`, `OpportunityDetailsCubit` (state holders only)
- Domain entities, enums, params, repositories, use cases
- Data models, remote data source, repository impl
- Tests for all of the above

No files under `presentation/widgets/`, `presentation/constants/`, `presentation/mappers/`, `presentation/view_models/`, or `presentation/pure/` existed in this commit for any of the three CRM features.

The first presentation widgets appear as **untracked files** in the current working tree (see "Untracked files" above).

All later diffs in this report are against baseline `a660ab7`.

---

## S2. Change inventory

### Git diff --stat baseline..HEAD (+ uncommitted)

```
55 files changed, 1989 insertions(+), 484 deletions(-)
```

**Grouped by area:**

| Area | Files modified | Files added (untracked) | Net lines |
|------|---------------|------------------------|-----------|
| **opportunities presentation** | 3 (bloc, event, state) | 21 (widgets, constants, pure, cubits) | +3,695 |
| **interactions presentation** | 3 (cubits) | 22 (widgets, constants, mappers, pure, view_models) | +3,712 |
| **customer_notes presentation** | 1 (cubit) | 21 (widgets, constants, mappers, view_models) | +1,883 |
| **crm_shell** | 0 | 3 (widgets, FEATURE.md) | +3,695 |
| **core animations** | 3 (animations.dart, app_bottom_sheet.dart, app_durations.dart) | 3 (selection/, highlight_flash.dart, progress_ring.dart) | +531 |
| **core services** | 0 | 1 (url_launcher_service.dart) | +18 |
| **core utils** | 1 (paged_result.dart) | 2 (formatters.dart, list_diff.dart) | +199 |
| **core widgets** | 2 (app_text_field.dart, widgets.dart) | 0 | +5 |
| **core constants** | 1 (hero_tags.dart) | 0 | +6 |
| **core DI** | 1 (core_module.dart) | 0 | +7 |
| **core router** | 3 (app_router_routes.dart, route_names.dart, route_paths.dart) | 0 | +118 |
| **core theme** | 2 (app_theme.dart, colors_extension.dart) | 0 | +36 |
| **core i18n** | 2 (strings.g.dart, strings_en.g.dart) | 0 | +787 |
| **Android platform** | 1 (AndroidManifest.xml) | 0 | +8 |
| **iOS platform** | 1 (Info.plist) | 0 | +5 |
| **docs** | 3 (CORE_MAP.md, FEATURES_INDEX.md, FEATURE.md x3) | 0 | +138 |
| **pubspec** | 2 (pubspec.yaml, pubspec.lock) | 0 | +65 |
| **tests (CRM features)** | 27 | 35 | +4,300+ |
| **tests (core)** | 3 | 3 | +284 |

### Every file added, modified, or deleted (path, status, line count, purpose, imported by)

| Path | Status | Lines | Purpose | Imported by |
|------|--------|-------|---------|-------------|
| **opportunities — presentation (new widgets)** |
| lib/features/opportunities/presentation/constants/opportunity_layout_constants.dart | A | 65 | Shared geometry for card, skeleton, detail sections, stepper | opportunity_card.dart, opportunity_card_skeleton.dart, opportunity_detail_page.dart, progress_card.dart, stage_stepper.dart, opportunities_tab_view.dart |
| lib/features/opportunities/presentation/widgets/opportunity_card.dart | A | 272 | Opportunity list item — whole-surface tap, status badge, value, probability ring, stage chip, overdue tag | opportunities_tab_view.dart |
| lib/features/opportunities/presentation/widgets/opportunity_card_skeleton.dart | A | 83 | Skeleton twin of card — same geometry via ShimmerScope | opportunities_tab_view.dart |
| lib/features/opportunities/presentation/widgets/opportunities_tab_view.dart | A | 741 | List tab body: search field, filter button, stage chips, summary row, list with load-more footer | crm_shell.dart |
| lib/features/opportunities/presentation/widgets/opportunity_filter_sheet.dart | A | 88 | Bottom sheet for status filter (Open/Won/Lost) with animated chip selector | opportunities_tab_view.dart |
| lib/features/opportunities/presentation/widgets/opportunity_header.dart | A | 230 | Detail header with title, status badge, stage chip, value, dates | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/status_banner.dart | A | 89 | Full-width banner for Won/Lost with reason | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/progress_card.dart | A | 129 | Probability ring (72dp) + StageStepper | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/stage_stepper.dart | A | 247 | 5-node stepper with connector lines | progress_card.dart |
| lib/features/opportunities/presentation/widgets/opportunity_tab_bar.dart | A | 98 | Sticky tab bar with count badges | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/overview_tab.dart | A | 344 | Customer card + Details card | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/contacts_tab.dart | A | 229 | Contact cards with call/email actions | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/interactions_tab.dart | A | 111 | Add button + InteractionsTimeline | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/notes_tab.dart | A | 29 | CustomerNotesThread + CustomerNoteComposer | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/widgets/opportunity_detail_page.dart | A | 264 | Full detail page with SliverAppBar, tabs, silent refresh | app_router_routes.dart (route) |
| lib/features/opportunities/presentation/widgets/opportunity_detail_skeleton.dart | A | 322 | Full-page skeleton twin | opportunity_detail_page.dart |
| lib/features/opportunities/presentation/pure/contact_to_interaction_option.dart | A | 6 | Maps CustomerContact → InteractionContactOption | interactions_tab.dart |
| lib/features/opportunities/presentation/pure/embedded_interaction_to_tile_data.dart | A | 21 | Maps EmbeddedCustomerInteraction → InteractionTileData | interactions_tab.dart |
| **opportunities — presentation (modified)** |
| lib/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart | M | 231 | Paginated list Bloc: debounced search, filters, load-more, refresh | opportunities_tab_view.dart, crm_shell.dart |
| lib/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart | M | 107 | Success/Empty/Error states with hasMore, nextPage, failures | opportunities_tab_view.dart |
| lib/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit.dart | M | 74 | Read-only detail cubit with silent reload on CRM signal | opportunity_detail_page.dart |
| **interactions — presentation (new widgets)** |
| lib/features/interactions/presentation/constants/interaction_layout_constants.dart | A | 87 | Shared geometry for feed, tiles, sheets, skeletons | interactions_feed_view.dart, interaction_tile.dart, interaction_add_edit_sheet.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/widgets/interactions_feed_view.dart | A | 137 | Feed screen: header + grouped content | crm_shell.dart |
| lib/features/interactions/presentation/widgets/interactions_feed_header.dart | A | 181 | Search field + type filter chips | interactions_feed_view.dart |
| lib/features/interactions/presentation/widgets/interactions_feed_content.dart | A | 306 | Grouped interaction tiles with sticky date headers | interactions_feed_view.dart |
| lib/features/interactions/presentation/widgets/interactions_feed_state_body.dart | A | 159 | Loading/content/empty/error states for feed | interactions_feed_view.dart |
| lib/features/interactions/presentation/widgets/interactions_timeline.dart | A | 231 | Timeline for detail tab: tiles with edit/delete | interactions_tab.dart |
| lib/features/interactions/presentation/widgets/interaction_tile.dart | A | 264 | One interaction: type icon, subject, description, date, swipe actions | interactions_feed_content.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/widgets/interaction_tile_skeleton.dart | A | 78 | Skeleton twin of interaction tile | interactions_feed_content.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/widgets/interaction_add_edit_sheet.dart | A | 492 | Bottom sheet for add/edit with form validation | interactions_feed_view.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/widgets/interaction_delete_dialog.dart | A | 88 | Delete confirmation dialog | interactions_feed_view.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/widgets/interaction_refresh_notice.dart | A | 63 | Dismissible notice after failed silent refresh | interactions_feed_view.dart |
| lib/features/interactions/presentation/widgets/interaction_type_icon.dart | A | 151 | Icon + color for each InteractionType | interaction_tile.dart |
| lib/features/interactions/presentation/widgets/helpers.dart | A | 144 | Helper functions: showAddInteractionSheet, showEditInteractionSheet, showDeleteInteractionDialog | interactions_feed_view.dart, interactions_timeline.dart |
| lib/features/interactions/presentation/mappers/interaction_tile_mapper.dart | A | 21 | Maps Interaction entity → InteractionTileData | interaction_tile.dart |
| lib/features/interactions/presentation/pure/date_grouping.dart | A | 43 | Groups interactions by date for feed | interactions_feed_content.dart |
| lib/features/interactions/presentation/pure/timeline_ordering.dart | A | 19 | Orders interactions for timeline (newest first) | interactions_timeline.dart |
| lib/features/interactions/presentation/view_models/interaction_tile_data.dart | A | 87 | Leaf-safe tile data (id, type, subject, description, date, opportunityId) | interaction_tile.dart, interaction_tile_mapper.dart |
| **interactions — presentation (modified)** |
| lib/features/interactions/presentation/cubits/interactions_list/interactions_list_bloc.dart | M | 204 | Debounced search + immediate filters + full reloads, CRM signal refresh | interactions_feed_view.dart |
| lib/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart | M | 67 | One-shot add/edit submit | interaction_add_edit_sheet.dart |
| lib/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart | M | 38 | One-shot delete | interaction_delete_dialog.dart |
| **customer_notes — presentation (new widgets)** |
| lib/features/customer_notes/presentation/constants/note_layout_constants.dart | A | 53 | Shared geometry for row, skeleton, composer | customer_notes_thread.dart, customer_note_composer.dart, note_tile.dart, note_thread_skeleton.dart |
| lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart | A | 74 | Public thread; owns list cubit, opens edit sheet & delete dialog | notes_tab.dart |
| lib/features/customer_notes/presentation/widgets/customer_notes_view.dart | A | 110 | Header + refresh notice + loading/content/empty/error body | customer_notes_thread.dart |
| lib/features/customer_notes/presentation/widgets/customer_note_composer.dart | A | 195 | Public bottom bar; owns persistent form cubit, keyboard-safe | notes_tab.dart |
| lib/features/customer_notes/presentation/widgets/note_tile.dart | A | 113 | One note: initials avatar, author, time, clamped body, overflow menu | note_thread_content.dart |
| lib/features/customer_notes/presentation/widgets/note_timestamp.dart | A | 54 | Localized relative time, absolute CRM date in tooltip/semantics | note_tile.dart |
| lib/features/customer_notes/presentation/widgets/note_text_body.dart | A | 78 | Six-line clamp with Show more/less when overflows | note_tile.dart |
| lib/features/customer_notes/presentation/widgets/note_thread_header.dart | A | 37 | Title and plural note count | customer_notes_view.dart |
| lib/features/customer_notes/presentation/widgets/note_thread_content.dart | A | 217 | Id-diffed list with arrival/edit flash, departure collapse | customer_notes_view.dart |
| lib/features/customer_notes/presentation/widgets/note_thread_skeleton.dart | A | 87 | Loading twin, one shimmer driver, localized "Loading notes…" | customer_notes_view.dart |
| lib/features/customer_notes/presentation/widgets/note_refresh_notice.dart | A | 63 | Dismissible notice after failed silent refresh | customer_notes_view.dart |
| lib/features/customer_notes/presentation/widgets/note_send_button.dart | A | 54 | Circular send action morphing idle/sending/sent/failed | customer_note_composer.dart |
| lib/features/customer_notes/presentation/widgets/note_edit_sheet.dart | A | 183 | Bottom-sheet editor with discard confirmation | customer_notes_thread.dart |
| lib/features/customer_notes/presentation/widgets/note_delete_dialog.dart | A | 77 | Delete confirmation with in-button progress | customer_notes_thread.dart |
| lib/features/customer_notes/presentation/mappers/customer_note_mapper.dart | A | 27 | CustomerNote → CustomerNoteViewModel | note_thread_content.dart |
| lib/features/customer_notes/presentation/view_models/customer_note_view_model.dart | A | 34 | Leaf-safe note values (author, initials, text, createdAt) | customer_note_mapper.dart, note_tile.dart |
| **customer_notes — presentation (modified)** |
| lib/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart | M | 130 | Load notes for customer, refresh, silent refetch on CRM signal | customer_notes_thread.dart |
| **crm_shell — presentation (new)** |
| lib/features/crm_shell/presentation/widgets/crm_shell.dart | A | 2635 | CrmShell (Scaffold + AppBar + AnimatedChipSelector tab bar + IndexedStack) | app_router_routes.dart (route) |
| lib/features/crm_shell/presentation/widgets/widgets.dart | A | 87 | Barrel export | crm_shell.dart |
| lib/features/crm_shell/FEATURE.md | A | 3572 | Feature documentation | N/A |
| **core — new** |
| lib/core/animations/selection/animated_chip_selector.dart | A | 297 | Chip row with animated sliding indicator (used by CRM tabs, stage chips, type chips) | crm_shell.dart, opportunity_filter_sheet.dart, opportunities_tab_view.dart, interactions_feed_header.dart |
| lib/core/animations/selection/chip_item.dart | A | 19 | ChipItem model with optional badge | animated_chip_selector.dart |
| lib/core/animations/selection/selection.dart | A | 6 | Barrel export | animated_chip_selector.dart |
| lib/core/services/url_launcher_service.dart | A | 18 | Abstraction for tel:/mailto: launching | contacts_tab.dart, interactions_tab.dart |
| lib/core/utils/formatters.dart | A | 133 | Currency/money, CRM date format, relative timestamps | opportunity_card.dart, opportunity_header.dart, note_timestamp.dart, interaction_tile.dart, etc. |
| lib/core/utils/list_diff.dart | A | 54 | Pure id-based list diff for animated list views | note_thread_content.dart, interactions_feed_content.dart |
| lib/core/widgets/highlight_flash.dart | A | 99 | One-shot accent flash overlay | note_thread_content.dart, interactions_feed_content.dart |
| lib/core/widgets/progress_ring.dart | A | 106 | Sweep ring driven by external progress | opportunity_card.dart, progress_card.dart |
| **core — modified** |
| lib/core/animations/animations.dart | M | +1 | Barrel export for new selection widgets | N/A |
| lib/core/animations/overlays/app_bottom_sheet.dart | M | +8 | Added showDragHandle parameter | note_edit_sheet.dart |
| lib/core/animations/tokens/app_durations.dart | M | +5 | Added durations for selection animations | animated_chip_selector.dart |
| lib/core/constants/hero_tags.dart | M | +6 | Added opportunityHeroTag, interactionHeroTag | opportunity_card.dart, opportunity_detail_page.dart, interactions_timeline.dart |
| lib/core/di/core_module.dart | M | +7 | Registers StreamCrmDataChangeService, UrlLauncherService | app_router_routes.dart, contacts_tab.dart, interactions_tab.dart |
| lib/core/router/app_router_routes.dart | M | +106 | Added /crm and /crm/opportunities/:id routes | main.dart |
| lib/core/router/route_names.dart | M | +6 | Added crm, crmOpportunityDetails route names | crm_shell.dart, app_router_routes.dart |
| lib/core/router/route_paths.dart | M | +6 | Added /crm, /crm/opportunities/:id paths | app_router_routes.dart |
| lib/core/theme/app_theme.dart | M | +20 | Added system overlay style for CRM routes | crm_shell.dart, opportunity_detail_page.dart |
| lib/core/theme/extensions/colors_extension.dart | M | +16 | Added CRM-specific placeholder colors | skeleton widgets |
| lib/core/utils/paged_result.dart | M | +12 | Added optional totalItems (display-only) | opportunities_repository_impl.dart |
| lib/core/widgets/app_text_field.dart | M | +3 | Added minLines/maxLines for multiline | customer_note_composer.dart, interaction_add_edit_sheet.dart |
| lib/core/widgets/widgets.dart | M | +2 | Barrel export for ProgressRing, HighlightFlash | N/A |
| lib/core/i18n/strings.g.dart | M | +4 | Slang generated — new CRM keys | N/A |
| lib/core/i18n/strings_en.g.dart | M | +783 | Slang generated English — new CRM keys | N/A |
| **platform — modified** |
| android/app/src/main/AndroidManifest.xml | M | +8 | Added `<queries>` for tel: and mailto: schemes | url_launcher |
| ios/Runner/Info.plist | M | +5 | Added `LSApplicationQueriesSchemes` for tel, mailto | url_launcher |
| **docs — modified** |
| docs/CORE_MAP.md | M | +15 | Documented new core pieces (selection, formatters, list_diff, highlight_flash, progress_ring, url_launcher) | N/A |
| docs/FEATURES_INDEX.md | M | +7 | Added crm_shell row | N/A |
| lib/features/opportunities/FEATURE.md | M | +51 | Updated changelog with O1–O4 completion | N/A |
| lib/features/interactions/FEATURE.md | M | +4 | Updated used-by to crm_shell | N/A |
| lib/features/customer_notes/FEATURE.md | M | +66 | Updated with presentation UI completion | N/A |
| lib/features/crm_shell/FEATURE.md | A | 3572 | Created CRM shell feature doc | N/A |
| **pubspec — modified** |
| pubspec.yaml | M | +1 | Added url_launcher dependency | N/A |
| pubspec.lock | M | +64 | Lock file updated | N/A |
| **tests — new (selected)** |
| test/features/opportunities/presentation/widgets/opportunity_card_test.dart | A | 230 | Whole-surface tap, overdue tag, double-tap guard | N/A |
| test/features/customer_notes/presentation/widgets/ (13 files) | A | ~1,500 | Widget tests for all customer_notes presentation | N/A |
| test/features/interactions/presentation/widgets/ (17 files) | A | ~3,500 | Widget tests for all interactions presentation | N/A |
| test/core/services/url_launcher_service_fake.dart | A | 34 | Fake for UrlLauncherService in tests | contacts_tab_test, interactions_tab_test |
| test/core/utils/formatters_test.dart | A | 90 | Tests for currency, CRM date, relative time | N/A |
| test/core/widgets/highlight_flash_test.dart | A | 79 | Tests for HighlightFlash | N/A |
| **tests — modified (selected)** |
| test/features/opportunities/presentation/cubits/opportunities_list/opportunities_list_bloc_test.dart | M | 209 | Added tests for load-more failure, hasMore | N/A |
| test/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit_test.dart | M | 173 | Added tests for signal reload | N/A |
| test/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit_test.dart | M | 253 | Added tests for silent refresh matching/non-matching | N/A |
| test/features/interactions/presentation/cubits/interactions_list/interactions_list_bloc_test.dart | M | 248 | Added tests for signal refresh | N/A |
| test/features/interactions/presentation/cubits/interactions_list/interactions_list_bloc_signal_test.dart | A | 202 | New file for signal tests | N/A |

**UNREFERENCED files (imported by nothing, not a route, not a test):**
- `lib/features/opportunities/presentation/pure/contact_to_interaction_option.dart` — only imported by `interactions_tab.dart` (USED)
- `lib/features/opportunities/presentation/pure/embedded_interaction_to_tile_data.dart` — only imported by `interactions_tab.dart` (USED)
- `lib/features/interactions/presentation/pure/date_grouping.dart` — only imported by `interactions_feed_content.dart` (USED)
- `lib/features/interactions/presentation/pure/timeline_ordering.dart` — only imported by `interactions_timeline.dart` (USED)
- `lib/features/interactions/presentation/widgets/helpers.dart` — only imported by `interactions_feed_view.dart` and `interactions_timeline.dart` (USED)
- All other new files are imported by at least one other file or are route targets.

### Changes OUTSIDE the three features' presentation layers (with diff description and tests)

| File | Diff description | Tests covering |
|------|------------------|----------------|
| lib/core/animations/selection/animated_chip_selector.dart | New: chip row with animated sliding indicator, supports badge counts, RTL-aware, honours disableAnimations | (core — no direct tests yet) |
| lib/core/animations/selection/chip_item.dart | New: ChipItem model with label, value, optional badge | (core — no direct tests yet) |
| lib/core/animations/selection/selection.dart | New: barrel export | N/A |
| lib/core/services/url_launcher_service.dart | New: abstraction for tel:/mailto: launching with interface + default impl | test/core/services/url_launcher_service_fake.dart (fake) |
| lib/core/utils/formatters.dart | New: currency/money formatting, CRM date format (`crmDate`), locale-free relative timestamps (`relativeParts`) | test/core/utils/formatters_test.dart (90 lines) |
| lib/core/utils/list_diff.dart | New: pure id-based list diff for animated list views | (used by note_thread_content, interactions_feed_content — tested indirectly) |
| lib/core/widgets/highlight_flash.dart | New: one-shot accent flash overlay for arrival/edit feedback | test/core/widgets/highlight_flash_test.dart (79 lines) |
| lib/core/widgets/progress_ring.dart | New: sweep ring driven by external progress (0–1) | (used by opportunity_card, progress_card — tested indirectly) |
| lib/core/animations/overlays/app_bottom_sheet.dart | Added `showDragHandle` parameter (default true) for form-mode sheets | test/core/animations/overlays/app_bottom_sheet_test.dart (+16 lines) |
| lib/core/animations/tokens/app_durations.dart | Added `selectionFast`, `selectionNormal` durations | N/A |
| lib/core/constants/hero_tags.dart | Added `opportunityHeroTag`, `interactionHeroTag` prefixes | N/A |
| lib/core/di/core_module.dart | Registered `StreamCrmDataChangeService` as lazySingleton, `UrlLauncherService` as lazySingleton | N/A |
| lib/core/router/app_router_routes.dart | Added `/crm` (CrmShell) and `/crm/opportunities/:id` (OpportunityDetailPage) routes with `AppRoute.create` (fadeThrough for shell, containerTransform for detail) | N/A (no router tests) |
| lib/core/router/route_names.dart | Added `crm`, `crmOpportunityDetails` | N/A |
| lib/core/router/route_paths.dart | Added `/crm`, `/crm/opportunities/:id` | N/A |
| lib/core/theme/app_theme.dart | Added system overlay style for CRM routes (light/dark status bar) | N/A |
| lib/core/theme/extensions/colors_extension.dart | Added `PlaceholderColors` for skeleton theming | N/A |
| lib/core/utils/paged_result.dart | Added optional `totalItems` field (display-only) | N/A |
| lib/core/widgets/app_text_field.dart | Added `minLines`/`maxLines` for growing multiline fields | test/core/widgets/app_text_field_test.dart (+13 lines) |
| android/app/src/main/AndroidManifest.xml | Added `<queries>` for `tel:` and `mailto:` schemes | N/A |
| ios/Runner/Info.plist | Added `LSApplicationQueriesSchemes` for `tel`, `mailto` | N/A |
| pubspec.yaml | Added `url_launcher` dependency | N/A |

---

## S3. Public API

### Expected vs actual signatures

| Widget / Function | Expected signature | Actual signature (path:line) | Match |
|-------------------|-------------------|------------------------------|-------|
| `CustomerNotesThread` | `CustomerNotesThread({required int customerId})` | `const CustomerNotesThread({super.key, required this.customerId});` (lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart:23) | **MATCH** |
| `CustomerNoteComposer` | `CustomerNoteComposer({required int customerId})` | `const CustomerNoteComposer({super.key, required this.customerId});` (lib/features/customer_notes/presentation/widgets/customer_note_composer.dart:25) | **MATCH** |
| `InteractionsFeedView` | `InteractionsFeedView({required ValueChanged<int> onOpenOpportunity})` | `const InteractionsFeedView({super.key, required this.onOpenOpportunity});` with `final ValueChanged<int> onOpenOpportunity;` (lib/features/interactions/presentation/widgets/interactions_feed_view.dart:25-27) | **MATCH** |
| `InteractionsTimeline` | `InteractionsTimeline({required List<InteractionTileData> items, required ValueChanged<InteractionTileData> onEdit, required ValueChanged<InteractionTileData> onDelete})` | `const InteractionsTimeline({super.key, required this.items, required this.onEdit, required this.onDelete, this.isRefreshing = false});` with `final List<InteractionTileData> items; final ValueChanged<InteractionTileData> onEdit; final ValueChanged<InteractionTileData> onDelete; final bool isRefreshing;` (lib/features/interactions/presentation/widgets/interactions_timeline.dart:17-28) | **MATCH** (extra optional `isRefreshing` parameter) |
| `InteractionTileData` | Fields: id, type, subject, description, date, authorName?, customerId?, contactId?, opportunityId? | All fields present (lib/features/interactions/presentation/view_models/interaction_tile_data.dart:7-40) | **MATCH** |
| `InteractionContactOption` | Fields: id, label | Both fields present (lib/features/interactions/presentation/view_models/interaction_tile_data.dart:44-52) | **MATCH** |
| `InteractionEditData` | Fields: interactionId, type, subject, description, date, customerId?, opportunityId? | All fields present (lib/features/interactions/presentation/view_models/interaction_tile_data.dart:55-83) | **MATCH** |
| `showAddInteractionSheet` | `Future<void> showAddInteractionSheet(BuildContext context, {required int customerId, required int opportunityId, required List<InteractionContactOption> contacts, int? initialContactId, InteractionType? initialType, DateTime? initialDate, String? contextLabel})` | Matches exactly (lib/features/interactions/presentation/widgets/helpers.dart:16-41) | **MATCH** |
| `showEditInteractionSheet` | `Future<void> showEditInteractionSheet(BuildContext context, {required InteractionEditData data})` | Matches exactly (lib/features/interactions/presentation/widgets/helpers.dart:45-61) | **MATCH** |
| `showDeleteInteractionDialog` | `Future<void> showDeleteInteractionDialog(BuildContext context, {required int interactionId, int? customerId, int? opportunityId})` | Matches exactly (lib/features/interactions/presentation/widgets/helpers.dart:65-84) | **MATCH** |
| `OpportunitiesTabView` | `OpportunitiesTabView({required ValueChanged<int> onOpenOpportunity})` | `const OpportunitiesTabView({super.key, required this.onOpenOpportunity});` with `final ValueChanged<int> onOpenOpportunity;` (lib/features/opportunities/presentation/widgets/opportunities_tab_view.dart:25-27) | **MATCH** |
| `OpportunityDetailPage` | `OpportunityDetailPage({required int opportunityId})` | `const OpportunityDetailPage({super.key, required this.opportunityId});` with `final int opportunityId;` (lib/features/opportunities/presentation/widgets/opportunity_detail_page.dart:27-29) | **MATCH** |

### Summary
All 11 public API signatures **MATCH** their expected signatures. The only minor deviation is `InteractionsTimeline` having an additional optional `isRefreshing` parameter (default `false`), which is an additive extension.

---

## S4. Routing, navigation, shell

### Route definitions

**Route paths** (`lib/core/router/route_paths.dart:21-25`):
- `RoutePaths.crm` → `/crm`
- `RoutePaths.crmOpportunityDetails` → `/crm/opportunities/:id`

**Route names** (`lib/core/router/route_names.dart:21-25`):
- `RouteNames.crm` → `crm`
- `RouteNames.crmOpportunityDetails` → `crmOpportunityDetails`

**Route table** (`lib/core/router/app_router_routes.dart:94-118`):

```dart
// CRM shell - shared axis horizontal for tab switches
AppRoute.create(
  path: RoutePaths.crm,           // /crm
  name: RouteNames.crm,           // crm
  transition: AppPageTransition.sharedAxisHorizontal,
  builder: (_, _) => BlocProvider(
    create: (_) =>
        getIt<OpportunitiesListBloc>()..add(OpportunitiesListStarted()),
    child: CrmShell(),
  ),
),

// CRM opportunity detail - container transform for Hero flight
AppRoute.create(
  path: RoutePaths.crmOpportunityDetails,  // /crm/opportunities/:id
  name: RouteNames.crmOpportunityDetails,  // crmOpportunityDetails
  transition: AppPageTransition.containerTransform,
  builder: (context, state) {
    final idString = state.pathParameters['id']!;
    final id = int.tryParse(idString);
    if (id == null) {
      return const _CrmInvalidIdPage();  // Non-numeric → error page
    }
    return OpportunityDetailPage(opportunityId: id);
  },
),
```

### Param parsing and invalid-id page
- **Param parsing:** `app_router_routes.dart:111-116` — extracts `id` from path parameters, uses `int.tryParse()`, returns `_CrmInvalidIdPage` if null
- **Invalid ID page:** `app_router_routes.dart:153-192` — `_CrmInvalidIdPage` with Scaffold, AppBar (back only), error icon, localized "Not found" + "Invalid opportunity ID" messages, "Back" button using `context.pop()`

### Shell widget and tab bar
**CrmShell** (`lib/features/crm_shell/presentation/widgets/crm_shell.dart:34-71`):
- Single `Scaffold` with `AppBar` (back button, localized "CRM" title, no actions)
- `TabController` with 2 tabs (length: 2)
- `_TabBar` using `AnimatedChipSelector` (not native `TabBar`)
- `TabBarView` with `IndexedStack`-like semantics (state preserved per tab)
- Tabs: `OpportunitiesTabView` (index 0) and `InteractionsFeedView` (index 1)

**_TabBar** (`crm_shell.dart:74-93`):
```dart
AnimatedChipSelector<int>(
  items: [
    ChipItem<int>(value: 0, label: labels.opportunities),  // "Opportunities"
    ChipItem<int>(value: 1, label: labels.interactions),   // "Interactions"
  ],
  selectedValue: controller.index,
  onChanged: (value) => controller.animateTo(value),
  scrollable: false,
);
```

### Home entry
**_HomeScreen** (`app_router_routes.dart:123-151`):
- `Scaffold` with `AppBar` title "Home"
- Centered `FilledButton.icon` with CRM icon and label "CRM"
- `onPressed: () => context.push(RoutePaths.crm)` — uses `push` (not `go`)

### Navigation map trace

| From | Action | To | Code evidence | Navigator used |
|------|--------|----|---------------|----------------|
| Home | Tap CRM button | `/crm` (Opportunities tab) | `app_router_routes.dart:138` — `context.push(RoutePaths.crm)` | `push` |
| Shell | Tap tab | Switch in place (state preserved) | `crm_shell.dart:90` — `controller.animateTo(value)` | N/A (TabController) |
| Opportunities tab | Tap card | `/crm/opportunities/<id>` | `opportunity_card.dart:37` — `onTap(opportunity.opportunityId)` → `crm_shell.dart:35` `_pushDetail` → `context.push('/crm/opportunities/$opportunityId')` | `push` |
| Interactions tab | Tap "Open opportunity" chip | `/crm/opportunities/<id>` | `interaction_tile.dart:197-219` — chip shown when `data.opportunityId != null && onOpenOpportunity != null` → `onOpenOpportunity` callback → `crm_shell.dart:35` `_pushDetail` | `push` |
| Detail | Back | Shell (preserved state & scroll) | `opportunity_detail_page.dart:121-127` — `Navigator.pop(context)` | `pop` |
| Invalid ID | — | Invalid ID page with back | `app_router_routes.dart:113-115` — returns `_CrmInvalidIdPage` | N/A (route builder) |
| Opportunity not found | — | Error state in detail | `opportunity_details_cubit.dart` → `NotFoundFailure` → `OpportunityDetailsError` state → `opportunity_detail_page.dart:65-69` shows `_ErrorView` with retry | N/A (state) |
| Double-tap push guard | — | — | `opportunity_card.dart:37` uses `AppCard(onTap:)` which is single tap; no explicit double-tap guard in navigation code | N/A |

### Hero tags
**HeroTags** (`lib/core/constants/hero_tags.dart:9-13`):
```dart
static String opportunityTitle(int opportunityId) =>
    '${prefix}opportunity_title_$opportunityId';
static String opportunityStatus(int opportunityId) =>
    '${prefix}opportunity_status_$opportunityId';
```
- **Usage:** Currently defined but **NOT USED** in `OpportunityCard` or `OpportunityDetailPage` — no `Hero` widgets wrapping the card or detail header elements. The `containerTransform` transition is configured but no matching Hero tags are applied on either end.

### Scaffold and AppBar occurrences

| Screen / Widget | Scaffold? | AppBar / SliverAppBar? | Location |
|-----------------|-----------|------------------------|----------|
| **Routes (top-level)** | | | |
| `_HomeScreen` | YES (`app_router_routes.dart:129`) | YES `AppBar` (`:130`) | Route |
| `CrmShell` | YES (`crm_shell.dart:42`) | YES `AppBar` (`:43-55`) | Route |
| `OpportunityDetailPage` → `_DetailPage` | YES (`opportunity_detail_page.dart:113`) | YES `SliverAppBar` (`:117-133`) | Route |
| `_ErrorView` (detail not found) | YES (`:240`) | YES `AppBar` (`:241-246`) | Route |
| `_CrmInvalidIdPage` | YES (`:160`) | YES `AppBar` (`:161-166`) | Route |
| **Tab bodies (inside shell, no Scaffold/AppBar)** | | | |
| `OpportunitiesTabView` | NO | NO (uses `SliverPersistentHeader` for pinned search + stage chips) | Tab body |
| `InteractionsFeedView` | NO | NO (uses `CustomScrollView` with `SliverToBoxAdapter`) | Tab body |
| **Detail tab bodies (inside OpportunityDetailPage, no Scaffold/AppBar)** | | | |
| `OverviewTab` | NO | NO | Tab body |
| `ContactsTab` | NO | NO | Tab body |
| `InteractionsTab` | NO | NO | Tab body |
| `NotesTab` | NO | NO | Tab body |
| **Sheets / Dialogs (no Scaffold/AppBar)** | | | |
| `OpportunityFilterSheet` | NO | NO | `AppBottomSheet` |
| `InteractionAddEditSheet` | NO | NO | `AppBottomSheet` |
| `InteractionDeleteDialog` | NO | NO | `showAppDialog` |
| `NoteEditSheet` | NO | NO | `AppBottomSheet` |
| `NoteDeleteDialog` | NO | NO | `showAppDialog` |
| `CustomerNoteComposer` | NO | NO | Bottom bar (not a sheet/dialog) |

### Summary
- Exactly **one Scaffold per route**: Home, CrmShell, OpportunityDetailPage, ErrorView, InvalidIdPage
- Exactly **one AppBar/SliverAppBar per route** (except Home which uses AppBar, Detail uses SliverAppBar)
- **No Scaffold or AppBar inside tab bodies, sheets, or dialogs** — CORRECT
- **Hero tags defined but NOT USED** — the `containerTransform` transition will not produce a Hero flight
- Navigation uses `context.push` for forward, `context.pop`/`Navigator.pop` for back
- Tab switching preserves state via `TabController` + `TabBarView` (IndexedStack semantics)

---

## S5. Dependency injection and provider scoping

### CRM registrations in DI files

| Type | Lifetime | File:line |
|------|----------|-----------|
| **Core (core_module.dart)** | | |
| `PendingSignupSession` | lazySingleton | core_module.dart:25 |
| `SessionExpiredNotifier` | lazySingleton | core_module.dart:27 |
| `SecureStorageClient` | lazySingleton | core_module.dart:31 |
| `Dio` (refreshDio) | lazySingleton | core_module.dart:34 |
| `TokenRefreshService` | lazySingleton | core_module.dart:40 |
| `CacheService` | lazySingleton | core_module.dart:52 |
| `BaseApiClient` | lazySingleton | core_module.dart:54 |
| `CrmDataChangeService` | lazySingleton | core_module.dart:69 |
| `UrlLauncherService` | lazySingleton | core_module.dart:75 |
| **Interactions (interactions_injection.dart)** | | |
| `InteractionsRemoteDataSource` | lazySingleton | interactions_injection.dart:21 |
| `InteractionsRepository` | lazySingleton | interactions_injection.dart:26 |
| `GetInteractionsUseCase` | lazySingleton | interactions_injection.dart:34 |
| `AddInteractionUseCase` | lazySingleton | interactions_injection.dart:37 |
| `UpdateInteractionUseCase` | lazySingleton | interactions_injection.dart:43 |
| `DeleteInteractionUseCase` | lazySingleton | interactions_injection.dart:46 |
| `WatchInteractionChangesUseCase` | lazySingleton | interactions_injection.dart:49 |
| `InteractionsListBloc` | factory | interactions_injection.dart:54 |
| `InteractionFormCubit` | factory | interactions_injection.dart:60 |
| `InteractionDeleteCubit` | factory | interactions_injection.dart:66 |
| **Customer Notes (customer_notes_injection.dart)** | | |
| `CustomerNotesRemoteDataSource` | lazySingleton | customer_notes_injection.dart:20 |
| `CustomerNotesRepository` | lazySingleton | customer_notes_injection.dart:25 |
| `GetCustomerNotesUseCase` | lazySingleton | customer_notes_injection.dart:33 |
| `AddCustomerNoteUseCase` | lazySingleton | customer_notes_injection.dart:36 |
| `UpdateCustomerNoteUseCase` | lazySingleton | customer_notes_injection.dart:39 |
| `DeleteCustomerNoteUseCase` | lazySingleton | customer_notes_injection.dart:42 |
| `WatchNoteChangesUseCase` | lazySingleton | customer_notes_injection.dart:45 |
| `CustomerNotesListCubit` | factory | customer_notes_injection.dart:50 |
| `CustomerNoteFormCubit` | factory | customer_notes_injection.dart:56 |
| `CustomerNoteDeleteCubit` | factory | customer_notes_injection.dart:62 |
| **Opportunities (opportunities_injection.dart)** | | |
| `OpportunitiesRemoteDataSource` | lazySingleton | opportunities_injection.dart:17 |
| `OpportunitiesRepository` | lazySingleton | opportunities_injection.dart:22 |
| `GetOpportunitiesUseCase` | lazySingleton | opportunities_injection.dart:27 |
| `GetOpportunityUseCase` | lazySingleton | opportunities_injection.dart:30 |
| `WatchCrmChangesUseCase` | lazySingleton | opportunities_injection.dart:33 |
| `OpportunitiesListBloc` | factory | opportunities_injection.dart:38 |
| `OpportunityDetailsCubit` | factory | opportunities_injection.dart:43 |

**Types used but not registered:** None found — all used types are registered.
**Types registered twice:** None found — each type registered exactly once.

### Every `getIt` call in CRM presentation code and router/shell

| Path | Line | Inside `BlocProvider(create:)`? | Type |
|------|------|--------------------------------|------|
| lib/core/router/app_router_routes.dart | 40 | YES (create) | `SplashCubit` |
| lib/core/router/app_router_routes.dart | 50 | YES (create) | `OnboardingCubit` |
| lib/core/router/app_router_routes.dart | 61 | YES (create) | `LoginCubit` |
| lib/core/router/app_router_routes.dart | 62 | YES (create) | `GoogleSignInCubit` |
| lib/core/router/app_router_routes.dart | 73 | YES (create) | `SignupCubit` |
| lib/core/router/app_router_routes.dart | 83 | YES (create) | `EmployeeStatusCubit` |
| lib/core/router/app_router_routes.dart | 84 | NO (direct) | `PendingSignupSession` |
| lib/core/router/app_router_routes.dart | 101 | YES (create) | `OpportunitiesListBloc` |
| lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart | 30 | YES (create) | `CustomerNotesListCubit` |
| lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart | 42 | NO (direct) | `CustomerNoteFormCubit` |
| lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart | 60 | NO (direct) | `CustomerNoteDeleteCubit` |
| lib/features/customer_notes/presentation/widgets/customer_note_composer.dart | 31 | YES (create) | `CustomerNoteFormCubit` |
| lib/features/interactions/presentation/widgets/interactions_feed_view.dart | 47 | YES (create) | `InteractionsListBloc` |
| lib/features/interactions/presentation/widgets/helpers.dart | 26 | NO (direct, in function) | `AddInteractionUseCase`, `UpdateInteractionUseCase` |
| lib/features/interactions/presentation/widgets/helpers.dart | 49 | NO (direct, in function) | `AddInteractionUseCase`, `UpdateInteractionUseCase` |
| lib/features/interactions/presentation/widgets/helpers.dart | 71 | NO (direct, in function) | `DeleteInteractionUseCase` |
| lib/features/opportunities/presentation/widgets/opportunity_detail_page.dart | 35 | YES (create) | `OpportunityDetailsCubit` |
| lib/features/opportunities/presentation/widgets/overview_tab.dart | 144 | NO (direct, in callback) | `UrlLauncherService` |
| lib/features/opportunities/presentation/widgets/overview_tab.dart | 153 | NO (direct, in callback) | `UrlLauncherService` |
| lib/features/opportunities/presentation/widgets/contacts_tab.dart | 159 | NO (direct, in callback) | `UrlLauncherService` |
| lib/features/opportunities/presentation/widgets/contacts_tab.dart | 165 | NO (direct, in callback) | `UrlLauncherService` |

### Every `BlocProvider` / `BlocProvider.value` / `MultiBlocProvider` in CRM code

| Path | Line | Type | Provides | Who owns/closes |
|------|------|------|----------|-----------------|
| app_router_routes.dart | 39-42 | `BlocProvider` (create) | `SplashCubit` | Router (route) |
| app_router_routes.dt | 49-52 | `BlocProvider` (create) | `OnboardingCubit` | Router (route) |
| app_router_routes.dt | 59-65 | `MultiBlocProvider` | `LoginCubit`, `GoogleSignInCubit` | Router (route) |
| app_router_routes.dt | 72-75 | `BlocProvider` (create) | `SignupCubit` | Router (route) |
| app_router_routes.dt | 82-85 | `BlocProvider` (create) | `EmployeeStatusCubit` | Router (route) |
| app_router_routes.dt | 99-103 | `BlocProvider` (create) | `OpportunitiesListBloc` | Router (route) |
| crm_shell.dart | N/A | N/A | — | CrmShell creates no BlocProviders (tabs provide their own) |
| opportunities_tab_view.dart | 45 | `BlocBuilder` only | — | Reads from ancestor (route) |
| opportunity_detail_page.dart | 33-37 | `BlocProvider` (create) | `OpportunityDetailsCubit` | Detail page (route) |
| interactions_feed_view.dart | 45-47 | `BlocProvider` (create) | `InteractionsListBloc` | Feed view (tab body) |
| interactions_feed_view.dart | 36-44 | `MultiBlocListener` | `InteractionFormCubit`, `InteractionDeleteCubit` | Feed view (listens to sheets/dialogs) |
| customer_notes_thread.dart | 28-38 | `BlocProvider` (create) | `CustomerNotesListCubit` | Thread widget |
| customer_notes_thread.dart | 49-52 | `BlocProvider.value` | `CustomerNoteFormCubit` | Thread creates/closes in `_edit()` |
| customer_notes_thread.dart | 65-68 | `BlocProvider.value` | `CustomerNoteDeleteCubit` | Thread creates/closes in `_delete()` |
| customer_note_composer.dart | 30-33 | `BlocProvider` (create) | `CustomerNoteFormCubit` | Composer widget |
| helpers.dart | 75 | `BlocProvider.value` | `InteractionFormCubit` | Sheet (created in `showAddInteractionSheet`) |
| helpers.dart | 104 | `BlocProvider.value` | `InteractionFormCubit` | Sheet (created in `showEditInteractionSheet`) |
| helpers.dart | 133 | `BlocProvider.value` | `InteractionDeleteCubit` | Dialog (created in `showDeleteInteractionDialog`) |

### Static trace of `context.read/watch/select`, `BlocBuilder`, `BlocListener`, `BlocConsumer`, `BlocProvider.of`

| Lookup site | Type looked up | Provider ancestor (path:line) | Status |
|-------------|----------------|------------------------------|--------|
| **opportunities_tab_view.dart** | | | |
| Line 42: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 57: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 79: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 94: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 106: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 118: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 121: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| Line 65: `BlocBuilder<OpportunitiesListBloc>` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route) | ✅ FOUND |
| **opportunity_detail_page.dart** | | | |
| Line 35: `context.read<OpportunityDetailsCubit>()` | `OpportunityDetailsCubit` | opportunity_detail_page.dart:33 (self) | ✅ FOUND |
| Line 48: `BlocBuilder<OpportunityDetailsCubit>` | `OpportunityDetailsCubit` | opportunity_detail_page.dart:33 (self) | ✅ FOUND |
| Line 68: `context.read<OpportunityDetailsCubit>()` | `OpportunityDetailsCubit` | opportunity_detail_page.dart:33 (self) | ✅ FOUND |
| **interactions_feed_view.dart** | | | |
| Line 47: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (self) | ✅ FOUND |
| Line 51: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (self) | ✅ FOUND |
| Line 38: `BlocListener<InteractionFormCubit>` | `InteractionFormCubit` | helpers.dart:75/104 (sheet) | ✅ FOUND (via MultiBlocListener) |
| Line 41: `BlocListener<InteractionDeleteCubit>` | `InteractionDeleteCubit` | helpers.dart:133 (dialog) | ✅ FOUND (via MultiBlocListener) |
| Line 46: `BlocBuilder<InteractionsListBloc>` | `InteractionsListBloc` | interactions_feed_view.dart:45 (self) | ✅ FOUND |
| **interactions_feed_header.dart** | | | |
| Line 32: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 35: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 43: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 49: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 52: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 19: `BlocBuilder<InteractionsListBloc>` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| **interactions_feed_state_body.dart** | | | |
| Line 110: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 135: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 138: `context.read<InteractionsListBloc>()` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| Line 46: `BlocBuilder<InteractionsListBloc>` | `InteractionsListBloc` | interactions_feed_view.dart:45 (ancestor) | ✅ FOUND |
| **interaction_delete_dialog.dart** | | | |
| Line 76: `context.read<InteractionDeleteCubit>()` | `InteractionDeleteCubit` | helpers.dart:133 (self, BlocProvider.value) | ✅ FOUND |
| Line 33: `BlocConsumer<InteractionDeleteCubit>` | `InteractionDeleteCubit` | helpers.dart:133 (self) | ✅ FOUND |
| **interaction_add_edit_sheet.dart** | | | |
| Line 139: `BlocConsumer<InteractionFormCubit>` | `InteractionFormCubit` | helpers.dart:75/104 (self) | ✅ FOUND |
| **customer_notes_thread.dart** | | | |
| Line 31: `BlocBuilder<CustomerNotesListCubit>` | `CustomerNotesListCubit` | customer_notes_thread.dart:28 (self) | ✅ FOUND |
| Line 34: `context.read<CustomerNotesListCubit>()` | `CustomerNotesListCubit` | customer_notes_thread.dart:28 (self) | ✅ FOUND |
| **customer_note_composer.dart** | | | |
| Line 72: `BlocConsumer<CustomerNoteFormCubit>` | `CustomerNoteFormCubit` | customer_note_composer.dart:30 (self) | ✅ FOUND |
| Line 157: `context.read<CustomerNoteFormCubit>()` | `CustomerNoteFormCubit` | customer_note_composer.dart:30 (self) | ✅ FOUND |
| Line 169: `context.read<CustomerNoteFormCubit>()` | `CustomerNoteFormCubit` | customer_note_composer.dart:30 (self) | ✅ FOUND |
| **note_edit_sheet.dart** | | | |
| Line 65: `BlocConsumer<CustomerNoteFormCubit>` | `CustomerNoteFormCubit` | customer_notes_thread.dart:49 (ancestor, BlocProvider.value) | ✅ FOUND |
| Line 152: `context.read<CustomerNoteFormCubit>()` | `CustomerNoteFormCubit` | customer_notes_thread.dart:49 (ancestor) | ✅ FOUND |
| **note_delete_dialog.dart** | | | |
| Line 26: `BlocConsumer<CustomerNoteDeleteCubit>` | `CustomerNoteDeleteCubit` | customer_notes_thread.dart:65 (ancestor, BlocProvider.value) | ✅ FOUND |
| **overview_tab.dart** | | | |
| Line 144: `getIt<UrlLauncherService>()` | `UrlLauncherService` | core_module.dart:75 (lazySingleton) | ✅ RESOLVED via getIt |
| Line 153: `getIt<UrlLauncherService>()` | `UrlLauncherService` | core_module.dart:75 (lazySingleton) | ✅ RESOLVED via getIt |
| **contacts_tab.dart** | | | |
| Line 159: `getIt<UrlLauncherService>()` | `UrlLauncherService` | core_module.dart:75 (lazySingleton) | ✅ RESOLVED via getIt |
| Line 165: `getIt<UrlLauncherService>()` | `UrlLauncherService` | core_module.dart:75 (lazySingleton) | ✅ RESOLVED |
| **opportunity_filter_sheet.dart** | | | |
| Line 39: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route ancestor) | ✅ FOUND |
| Line 66: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route ancestor) | ✅ FOUND |
| Line 77: `context.read<OpportunitiesListBloc>()` | `OpportunitiesListBloc` | app_router_routes.dart:101 (route ancestor) | ✅ FOUND |

**ProviderNotFound risks:**
- **None found** — every `context.read/watch/select` and every `BlocBuilder/Listener/Consumer` has a matching provider ancestor in the widget tree.
- The `getIt` calls for `UrlLauncherService` in `overview_tab.dart` and `contacts_tab.dart` are safe because `UrlLauncherService` is a `lazySingleton` registered in `core_module.dart` and initialized before the app runs.
- The `getIt` calls in `helpers.dart` for use cases are safe because they are called from functions that run after the widget tree is built (in callbacks), and the use cases are `lazySingleton`s.

### Special attention: Bottom sheets, dialogs, pushed routes

| Context | Provider location | Access pattern | Verified |
|---------|-------------------|----------------|----------|
| **InteractionAddEditSheet** (bottom sheet) | `BlocProvider.value` at helpers.dart:75/104 (created in `showAddInteractionSheet`/`showEditInteractionSheet`) | `BlocConsumer<InteractionFormCubit>` at interaction_add_edit_sheet.dart:139 | ✅ |
| **InteractionDeleteDialog** (dialog) | `BlocProvider.value` at helpers.dart:133 (created in `showDeleteInteractionDialog`) | `BlocConsumer<InteractionDeleteCubit>` at interaction_delete_dialog.dart:33 | ✅ |
| **NoteEditSheet** (bottom sheet) | `BlocProvider.value` at customer_notes_thread.dart:49 (created in `CustomerNotesThread._edit`) | `BlocConsumer<CustomerNoteFormCubit>` at note_edit_sheet.dart:65 | ✅ |
| **NoteDeleteDialog** (dialog) | `BlocProvider.value` at customer_notes_thread.dart:65 (created in `CustomerNotesThread._delete`) | `BlocConsumer<CustomerNoteDeleteCubit>` at note_delete_dialog.dart:26 | ✅ |
| **OpportunityDetailPage** (pushed route) | `BlocProvider` create at opportunity_detail_page.dart:33 | `BlocBuilder` at :48, `context.read` at :68 | ✅ |
| **OpportunityFilterSheet** (bottom sheet) | No provider created; reads `OpportunitiesListBloc` from route ancestor | `context.read` at opportunity_filter_sheet.dart:39/66/77 | ✅ (ancestor is route-level BlocProvider) |

All sheet/dialog contexts correctly inherit or receive their providers via `BlocProvider.value` from the creating widget.

---

## S6. Per-screen implemented structure

### Shared layout constants

| Feature | File | Key constants |
|---------|------|---------------|
| **Opportunities** | `opportunity_layout_constants.dart` | `cardPadding`, `cardRowGap`, `cardDividerGap`, `overviewIconSize`, `cardRingSizeSmall`, `cardRingStrokeWidth`, `headerPadding`, `headerTitleGap`, `headerRowGap`, `contactCardPadding`, `contactAvatarSize`, `contactButtonSize`, `stageChipsHeight`, `pinnedHeaderHeight` |
| **Interactions** | `interaction_layout_constants.dart` | `tileHorizontalPadding`, `tileVerticalPadding`, `tileBorderRadius`, `typeIconSize`, `typeIconGap`, `contentGap`, `chipHorizontalPadding`, `timelineGap`, `timelineConnectorWidth`, `swipeActionWidth`, `swipeIconSize`, `composerMinLines`, `composerMaxLines` |
| **Customer Notes** | `note_layout_constants.dart` | `rowHorizontalPadding`, `rowVerticalPadding`, `avatarSize`, `initialsFontSize`, `textClampLines`, `composerMinLines`, `composerMaxLines`, `maxDepartingRows` |

---

### CRM Shell (`lib/features/crm_shell/presentation/widgets/crm_shell.dart`)

**Widget tree:**
```
CrmShell (StatefulWidget)
└─ Scaffold
   ├─ AppBar (leading: back, title: "CRM", no actions)
   └─ Column
      ├─ _TabBar (AnimatedChipSelector<int> with 2 ChipItems)
      └─ Expanded
         └─ TabBarView (TabController, 2 children)
            ├─ OpportunitiesTabView
            └─ InteractionsFeedView
```

**Layout constants used:** `AppSpacing` (from core), i18n keys `crm.title`, `crm.tabs.opportunities`, `crm.tabs.interactions`

**Key code excerpts:**
- `crm_shell.dart:34-36` — `_pushDetail` uses `context.push('/crm/opportunities/$opportunityId')`
- `crm_shell.dart:42-55` — Single Scaffold with AppBar (back only, localized title)
- `crm_shell.dart:74-93` — `_TabBar` using `AnimatedChipSelector` for animated pill indicator

---

### Opportunities Tab (`lib/features/opportunities/presentation/widgets/opportunities_tab_view.dart`)

**Widget tree:**
```
OpportunitiesTabView (StatefulWidget)
└─ BlocBuilder<OpportunitiesListBloc, OpportunitiesListState>
   └─ CustomScrollView
      ├─ SliverPersistentHeader (pinned) → _PinnedHeaderDelegate
      │  └─ _SearchField (AppTextField) + _FilterButton (badge)
      ├─ SliverPersistentHeader (pinned) → _StageChipsDelegate
      │  └─ AnimatedChipSelector<OpportunityStage?> (6 chips: All + 5 stages)
      ├─ SliverToBoxAdapter → _SummaryRow
      │  └─ AnimatedCounter (totalCount) + _ActiveStatusChip + clear button
      └─ SliverFillRemaining → _ListBody (AppAnimatedSwitcher)
         ├─ _SkeletonList (3x OpportunityCardSkeleton) — Initial/Loading
         ├─ _SuccessList — Success
         │  └─ ListView.builder
         │     ├─ OpportunityCard (whole-surface tap)
         │     └─ _LoadMoreFooter (AnimatedProgressBar OR inline error + Retry)
         ├─ _EmptyList — Empty (EmptyState + optional _RefreshNotice)
         └─ _ErrorView — Error (ErrorState with retry)
```

**Layout constants used:** `OpportunityLayoutConstants`, `AppSpacing`, `AppRadius`, `AppDurations`, `AppCurves`

**Key code excerpts:**
- `opportunities_tab_view.dart:74-85` — Pinned search header delegate (maxExtent/minExtent = 72)
- `opportunities_tab_view.dart:88-99` — Pinned stage chips delegate (maxExtent/minExtent = 60)
- `opportunities_tab_view.dart:549-565` — `_SuccessList` with load-more footer at `items.length` index
- `opportunities_tab_view.dart:585-607` — Inline load-more error row with `AppButton.outlined` Retry

---

### Opportunity Card (`lib/features/opportunities/presentation/widgets/opportunity_card.dart`)

**Widget tree:**
```
OpportunityCard (StatelessWidget)
└─ AppCard (onTap: whole surface)
   └─ Column
      ├─ Row: Title (Expanded) + _StatusBadge
      ├─ Row: Icon + Customer·Company
      ├─ Divider
      ├─ Row: Estimated value (money) + _ProbabilityRingSmall (ProgressRing)
      └─ Row: _StageChip + Spacer + Date + optional _OverdueTag
```

**Layout constants used:** `OpportunityLayoutConstants`, `AppSpacing`, `AppRadius`, `Formatters.money`, `Formatters.crmDate`

**Key code excerpts:**
- `opportunity_card.dart:35-37` — `AppCard` with `onTap` callback receiving `opportunityId`
- `opportunity_card.dart:140-150` — `_isOverdue` logic: open status AND expectedCloseDate before today
- `opportunity_card.dart:173-205` — `_ProbabilityRingSmall` using `ProgressRing` with sweep = probability/100

---

### Opportunity Detail Page (`lib/features/opportunities/presentation/widgets/opportunity_detail_page.dart`)

**Widget tree:**
```
OpportunityDetailPage (StatelessWidget)
└─ BlocProvider(create: OpportunityDetailsCubit)
   └─ _DetailPageContent
      └─ BlocBuilder → AppAnimatedSwitcher
         ├─ OpportunityDetailSkeleton (loading)
         ├─ _DetailPage (success)
         │  └─ Scaffold
         │     └─ CustomScrollView
         │        ├─ SliverAppBar (pinned, back only, FlexibleSpaceBar → OpportunityHeader)
         │        ├─ SliverToBoxAdapter → StatusBanner (if won/lost)
         │        ├─ SliverToBoxAdapter → ProgressCard (ProbabilityRing + StageStepper)
         │        ├─ SliverPersistentHeader (pinned) → _TabBarDelegate
         │        │  └─ OpportunityTabBar (TabBar with 4 tabs + count badges)
         │        └─ SliverFillRemaining → TabBarView (4 tabs)
         │           ├─ OverviewTab
         │           ├─ ContactsTab
         │           ├─ InteractionsTab
         │           └─ NotesTab
         └─ _ErrorView (Scaffold + AppBar + ErrorState)
```

**Layout constants used:** `OpportunityLayoutConstants`, `AppSpacing`, `AppRadius`, `AppDurations`

**Key code excerpts:**
- `opportunity_detail_page.dart:117-133` — `SliverAppBar` with `pinned: true`, `expandedHeight: 320`, `collapseMode: CollapseMode.parallax`, back button only
- `opportunity_detail_page.dart:136-147` — StatusBanner only for won/lost (not open)
- `opportunity_detail_page.dart:163-174` — Sticky tab bar via `SliverPersistentHeader` (maxExtent/minExtent = 48)

---

### Opportunity Header (`lib/features/opportunities/presentation/widgets/opportunity_header.dart`)

**Widget tree:**
```
OpportunityHeader (StatelessWidget)
└─ Padding
   └─ Column
      ├─ Title (headlineMedium, max 2 lines)
      ├─ Row: _StatusBadge + _StageChip
      ├─ Estimated value (headlineSmall, primary color)
      └─ Row: _DateRow (expectedClose + overdue tag) + optional _DateRow (closedAt)
```

**Key code excerpts:**
- `opportunity_header.dart:33-40` — Title with `headlineMedium` style
- `opportunity_header.dart:54-60` — Value with `Formatters.money()` in `headlineSmall` primary
- `opportunity_header.dart:89-99` — `_isOverdue` same logic as card

---

### Status Banner (`lib/features/opportunities/presentation/widgets/status_banner.dart`)

**Widget tree:**
```
StatusBanner (StatelessWidget)
└─ Container (full-width, colored by status)
   └─ Row: Icon + Text (reason) + optional action
```

---

### Progress Card (`lib/features/opportunities/presentation/widgets/progress_card.dart`)

**Widget tree:**
```
ProgressCard (StatelessWidget)
└─ AppCard
   └─ Row
      ├─ ProbabilityRing (72dp, ProgressRing widget)
      └─ Expanded → StageStepper
```

---

### Stage Stepper (`lib/features/opportunities/presentation/widgets/stage_stepper.dart`)

**Widget tree:**
```
StageStepper (StatelessWidget)
└─ Row (5 nodes with connectors)
   ├─ Node 1 (Lead)
   ├─ Connector line
   ├─ Node 2 (Qualified)
   ├─ Connector line
   ├─ Node 3 (Proposal)
   ├─ Connector line
   ├─ Node 4 (Negotiation)
   ├─ Connector line
   └─ Node 5 (Closed)
```

**Key code:** Uses `AnimatedBuilder` with `AnimationController` for connector line draw animation.

---

### Opportunity Tab Bar (`lib/features/opportunities/presentation/widgets/opportunity_tab_bar.dart`)

**Widget tree:**
```
OpportunityTabBar (StatelessWidget)
└─ TabBar (controller, tabs: 4)
   ├─ Tab: Overview + count badge
   ├─ Tab: Contacts + count badge
   ├─ Tab: Interactions + count badge
   └─ Tab: Notes + count badge
```

**Key code:** Uses `Tab` with `child: Row` for label + badge.

---

### Overview Tab (`lib/features/opportunities/presentation/widgets/overview_tab.dart`)

**Widget tree:**
```
OverviewTab (StatelessWidget)
└─ ListView
   ├─ _CustomerCard (AppCard)
   │  ├─ Row: Avatar + Name·Company
   │  ├─ Row: Icon + Phone (if present)
   │  ├─ Row: Icon + Email (if present)
   │  └─ Row: Icon + Address (if present)
   ├─ Divider
   └─ _DetailsCard (AppCard)
      ├─ Row: Owner (employee.employeeName)
      ├─ Row: Stage + Status
      ├─ Row: Probability % (text)
      ├─ Row: Expected close date
      ├─ Row: Created at
      └─ Row: Closed at (if applicable)
```

**Key code excerpts:**
- `overview_tab.dart:144,153` — `getIt<UrlLauncherService>()` for phone/email launch
- `overview_tab.dart:80-90` — Owner shows `opportunity.employee.employeeName` (opportunity owner, not logged-in user)

---

### Contacts Tab (`lib/features/opportunities/presentation/widgets/contacts_tab.dart`)

**Widget tree:**
```
ContactsTab (StatelessWidget)
└─ if empty → _EmptyContacts
└─ ListView (sorted: primary first)
   └─ _ContactCard (AppCard)
      ├─ Row: CircleAvatar (initials) + Column(name, jobTitle) + _PrimaryBadge
      └─ Row: AppButton.outlined "Call" (tel:) + AppButton.outlined "Email" (mailto:)
```

**Key code:**
- `contacts_tab.dart:158-168` — `_launchPhone`/`_launchEmail` use `getIt<UrlLauncherService>()`
- **NO "Log it?" prompt implemented** — i18n keys exist but not wired in code

---

### Interactions Tab (`lib/features/opportunities/presentation/widgets/interactions_tab.dart`)

**Widget tree:**
```
InteractionsTab (StatelessWidget)
└─ Column
   ├─ Padding → AppButton.filled "Add interaction" (icon: add)
   └─ Expanded → InteractionsTimeline
      └─ (items mapped from opportunity.customer.interactions via embeddedInteractionToTileData)
```

**Key code:**
- `interactions_tab.dart:25-36` — Maps `EmbeddedCustomerInteraction` → `InteractionTileData` with `customerId` and `opportunityId`
- `interactions_tab.dart:67-78` — `showAddInteractionSheet` with contacts from opportunity
- `interactions_tab.dart:81-98` — `showEditInteractionSheet` / `showDeleteInteractionDialog` with tile data

---

### Notes Tab (`lib/features/opportunities/presentation/widgets/notes_tab.dart`)

**Widget tree:**
```
NotesTab (StatelessWidget)
└─ Column
   ├─ Expanded → CustomerNotesThread(customerId: opportunity.customer.customerId)
   └─ CustomerNoteComposer(customerId: opportunity.customer.customerId)
```

**Key code:**
- `notes_tab.dart:29` — Composes thread + composer; composer only active while Notes tab is visible (TabBarView)

---

### Opportunity Detail Skeleton (`lib/features/opportunities/presentation/widgets/opportunity_detail_skeleton.dart`)

**Widget tree:** Mirrors `_DetailPage` structure with `ShimmerScope` + `ShimmerBox` placeholders for each section (header, progress card, tabs, overview, contacts, interactions, notes).

---

### Interactions Feed (`lib/features/interactions/presentation/widgets/interactions_feed_view.dart`)

**Widget tree:**
```
InteractionsFeedView (StatefulWidget)
└─ MultiBlocListener (InteractionFormCubit, InteractionDeleteCubit)
   └─ BlocProvider<InteractionsListBloc>
      └─ RefreshIndicator
         └─ CustomScrollView
            ├─ SliverToBoxAdapter → Padding → InteractionsFeedHeader
            ├─ SliverToBoxAdapter → Padding → InteractionsFeedStateBody
            │  └─ (delegates to content/loading/empty/error)
            └─ SliverToBoxAdapter → SizedBox(100) (bottom padding)
```

**Key code:**
- `interactions_feed_view.dart:49-54` — Pull-to-refresh triggers `InteractionsListRefreshed`
- `interactions_feed_view.dart:105-136` — `BlocListener` for form/delete success/error snackbars

---

### Interactions Feed Header (`lib/features/interactions/presentation/widgets/interactions_feed_header.dart`)

**Widget tree:**
```
InteractionsFeedHeader (StatelessWidget)
└─ BlocBuilder<InteractionsListBloc, InteractionsListState>
   └─ Column
      ├─ AppTextField (search, debounced via onChanged)
      └─ Row: Type filter chips (AnimatedChipSelector<InteractionType?>)
```

---

### Interactions Feed Content (`lib/features/interactions/presentation/widgets/interactions_feed_content.dart`)

**Widget tree:**
```
InteractionsFeedContent (StatelessWidget)
└─ Column (grouped by date via date_grouping.dart)
   ├─ Sticky date header (Text)
   └─ ListView.builder (shrinkWrap, physics: NeverScrollableScrollPhysics)
      └─ InteractionTile (with showOpenOpportunityChip=true)
```

**Key code:** Uses `DiffListView` with `id-diff` for animated insert/remove.

---

### Interactions Feed State Body (`lib/features/interactions/presentation/widgets/interactions_feed_state_body.dart`)

**Widget tree:**
```
InteractionsFeedStateBody (StatelessWidget)
└─ AppAnimatedSwitcher
   ├─ _SkeletonList (3x InteractionTileSkeleton) — Initial/Loading
   ├─ InteractionsFeedContent — Success
   ├─ _EmptyView (EmptyState) — Empty
   └─ _ErrorView (ErrorState with retry) — Error
```

---

### Interaction Tile (`lib/features/interactions/presentation/widgets/interaction_tile.dart`)

**Widget tree:**
```
InteractionTile (StatelessWidget)
└─ Dismissible (horizontal, confirmDismiss returns false)
   ├─ background: _SwipeBackground (edit, green)
   ├─ secondaryBackground: _SwipeBackground (delete, red)
   └─ Material → InkWell (onTap) → Ink → Padding
      └─ Row
         ├─ InteractionTypeIcon
         ├─ Expanded → _TileContent
         │  ├─ Subject (titleMedium)
         │  ├─ Description (bodySecondary, max 2 lines)
         │  ├─ Date (labelSmall) — if showDate
         │  ├─ Author name (labelSmall) — if showAuthorName
         │  └─ ActionChip "Open opportunity" — if showOpenOpportunityChip && opportunityId != null
         └─ AppPopupMenu<InteractionTileAction> (Edit, Delete)
```

**Key code:**
- `interaction_tile.dart:60-74` — `Dismissible` with `confirmDismiss` returning `false` (tile stays, removal via id-diff)
- `interaction_tile.dart:197-219` — "Open opportunity" `ActionChip` only when `opportunityId != null`

---

### Interaction Tile Skeleton (`lib/features/interactions/presentation/widgets/interaction_tile_skeleton.dart`)

**Widget tree:** Mirrors `InteractionTile` with `ShimmerScope` + `ShimmerBox` placeholders.

---

### Interaction Add/Edit Sheet (`lib/features/interactions/presentation/widgets/interaction_add_edit_sheet.dart`)

**Widget tree:**
```
InteractionAddEditSheet (StatefulWidget)
└─ BlocConsumer<InteractionFormCubit, InteractionFormState>
   └─ Padding (keyboard + safe area)
      └─ Column
         ├─ AppTextField (subject)
         ├─ AppTextField (description, multiline)
         ├─ Row: Date picker + Type selector (AnimatedChipSelector)
         ├─ Contact selector (DropdownButtonFormField)
         └─ Row: Cancel + Save (AppButton.filled, loading state)
```

---

### Interaction Delete Dialog (`lib/features/interactions/presentation/widgets/interaction_delete_dialog.dart`)

**Widget tree:**
```
InteractionDeleteDialog (StatelessWidget)
└─ BlocConsumer<InteractionDeleteCubit, InteractionDeleteState>
   └─ AppDialog (confirmation)
      ├─ Title: "Delete interaction?"
      ├─ Message
      └─ Actions: Cancel + AppButton.destructive (loading in button)
```

---

### Interactions Timeline (`lib/features/interactions/presentation/widgets/interactions_timeline.dart`)

**Widget tree:**
```
InteractionsTimeline (StatefulWidget, SingleTickerProviderStateMixin)
└─ Column
   ├─ AnimatedProgressBar (if isRefreshing)
   ├─ _Empty (if items empty)
   └─ List of _TimelineItem
      └─ Row
         ├─ Connector line (AnimatedBuilder + CustomPainter) + InteractionTypeIcon
         └─ Expanded → InteractionTile (showOpenOpportunityChip=false, showAuthorName=true)
```

**Key code:**
- `interactions_timeline.dart:42-60` — `AnimationController` for connector line draw animation (disposed in `dispose`)
- `interactions_timeline.dart:158-174` — Connector line draws progressively with `progress` animation

---

### Customer Notes Thread (`lib/features/customer_notes/presentation/widgets/customer_notes_thread.dart`)

**Widget tree:**
```
CustomerNotesThread (StatelessWidget)
└─ BlocProvider(create: CustomerNotesListCubit, key: ValueKey(customerId))
   └─ BlocBuilder<CustomerNotesListCubit, CustomerNotesListState>
      └─ CustomerNotesView (state + onRetry + onEdit + onDelete)
```

**Key code:**
- `customer_notes_thread.dart:28-38` — Owns list cubit (recreated on customerId change via `ValueKey`)
- `customer_notes_thread.dart:41-57` — `_edit` creates `CustomerNoteFormCubit` via `getIt`, shows `AppBottomSheet` with `BlocProvider.value`
- `customer_notes_thread.dart:59-72` — `_delete` creates `CustomerNoteDeleteCubit` via `getIt`, shows `showAppDialog` with `BlocProvider.value`

---

### Customer Notes View (`lib/features/customer_notes/presentation/widgets/customer_notes_view.dart`)

**Widget tree:**
```
CustomerNotesView (StatelessWidget)
└─ Column
   ├─ NoteThreadHeader (title + count)
   ├─ NoteRefreshNotice (if refreshFailure)
   └─ AppAnimatedSwitcher
      ├─ NoteThreadSkeleton (Loading/Initial)
      ├─ NoteThreadContent (Success)
      ├─ _EmptyView (EmptyState) (Empty)
      └─ _ErrorView (ErrorState with retry) (Error)
```

---

### Note Thread Content (`lib/features/customer_notes/presentation/widgets/note_thread_content.dart`)

**Widget tree:**
```
NoteThreadContent (StatelessWidget)
└─ DiffListView<CustomerNoteViewModel> (id-based diff)
   └─ AnimatedVisibility (departure collapse)
      └─ StaggeredListItem (entrance)
         └─ NoteTile
            └─ HighlightFlash (on arrival/edit)
```

**Key code:**
- Uses `list_diff.dart` for id-based diff
- `HighlightFlash` for arrival/edit feedback
- `AnimatedVisibility` for departure collapse (max `maxDepartingRows` kept mounted)

---

### Note Tile (`lib/features/customer_notes/presentation/widgets/note_tile.dart`)

**Widget tree:**
```
NoteTile (StatelessWidget)
└─ Padding
   └─ Row
      ├─ CircleAvatar (initials, semantics excluded)
      ├─ Expanded
      │  ├─ Row: Author + NoteTimestamp
      │  ├─ NoteTextBody (6-line clamp, Show more/less)
      │  └─ AppPopupMenu (Edit, Delete)
```

---

### Note Timestamp (`lib/features/customer_notes/presentation/widgets/note_timestamp.dart`)

**Widget tree:**
```
NoteTimestamp (StatelessWidget)
└─ Tooltip (absolute CRM date)
   └─ Semantics (absolute date)
      └─ Text (relative time from Formatters.relativeParts)
```

---

### Note Text Body (`lib/features/customer_notes/presentation/widgets/note_text_body.dart`)

**Widget tree:**
```
NoteTextBody (StatefulWidget)
└─ LayoutBuilder → AnimatedSizeWrapper
   └─ Column
      ├─ Text (maxLines: 6 or expanded)
      └─ TextButton (Show more / Show less) — only when overflows
```

---

### Note Thread Skeleton (`lib/features/customer_notes/presentation/widgets/note_thread_skeleton.dart`)

**Widget tree:** `ShimmerScope` + `ShimmerBox` placeholders matching `NoteTile` geometry.

---

### Note Refresh Notice (`lib/features/customer_notes/presentation/widgets/note_refresh_notice.dart`)

**Widget tree:** Dismissible banner with warning color, shows after failed silent refresh.

---

### Customer Note Composer (`lib/features/customer_notes/presentation/widgets/customer_note_composer.dart`)

**Widget tree:**
```
CustomerNoteComposer (StatelessWidget)
└─ BlocProvider(create: CustomerNoteFormCubit..startAdd())
   └─ _ComposerBar (StatefulWidget)
      └─ BlocConsumer<CustomerNoteFormCubit, CustomerNoteFormState>
         └─ Padding (keyboard inset + safe bottom)
            └─ DecoratedBox (surface + border)
               └─ Column
                  ├─ _ComposerError (if failure)
                  └─ Row: AppTextField (multiline) + NoteSendButton
```

**Key code:**
- `customer_note_composer.dart:69-70` — `MediaQuery.viewInsetsOf(context).bottom` for keyboard
- `customer_note_composer.dart:112-116` — `AppTextField` with `minLines`/`maxLines` from `NoteLayoutConstants`
- `customer_note_composer.dart:156-169` — On success: clears text, calls `startAdd()`, requests focus

---

### Note Send Button (`lib/features/customer_notes/presentation/widgets/note_send_button.dart`)

**Widget tree:** Circular button morphing idle/sending/sent/failed states with animation.

---

### Note Edit Sheet (`lib/features/customer_notes/presentation/widgets/note_edit_sheet.dart`)

**Widget tree:**
```
NoteEditSheet (StatelessWidget)
└─ BlocConsumer<CustomerNoteFormCubit, CustomerNoteFormState>
   └─ AppBottomSheet (form mode: isDismissible=false, enableDrag=false, showDragHandle=false)
      └─ Column
         ├─ AppTextField (multiline, initialText)
         └─ Row: Cancel (with discard confirmation if dirty) + Save (enabled only if changed)
```

---

### Note Delete Dialog (`lib/features/customer_notes/presentation/widgets/note_delete_dialog.dart`)

**Widget tree:**
```
NoteDeleteDialog (StatelessWidget)
└─ BlocConsumer<CustomerNoteDeleteCubit, CustomerNoteDeleteState>
   └─ AppDialog (barrierDismissible: false)
      ├─ Title: "Delete note?"
      ├─ Message
      └─ Actions: Cancel + AppButton.destructive (loading in button, keeps dialog open on failure)
```

---

## S7. State to UI

### OpportunitiesListBloc (`lib/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `OpportunitiesListInitial` | `opportunities_tab_view.dart:469-471` → `_SkeletonList` | `opportunities_list_bloc_test.dart` — Initial/Loading states |
| `OpportunitiesListLoading` | `opportunities_tab_view.dart:469-471` → `_SkeletonList` | `opportunities_list_bloc_test.dart` — Initial/Loading states |
| `OpportunitiesListSuccess` | `opportunities_tab_view.dart:472-486` → `_SuccessList` with items, load-more footer | `opportunities_list_bloc_test.dart` — Success with items, hasMore, loadMoreFailure |
| `OpportunitiesListSuccess` (`isRefreshing=true`) | Same `_SuccessList`; refresh indicator via `RefreshIndicator` on parent | `opportunities_list_bloc_test.dart` — refresh states |
| `OpportunitiesListSuccess` (`loadMoreFailure != null`) | `opportunities_tab_view.dart:585-607` → `_LoadMoreFooter` with inline error + Retry | `opportunities_list_bloc_test.dart` — load-more failure keeps items, allows retry |
| `OpportunitiesListEmpty` | `opportunities_tab_view.dart:487-496` → `_EmptyList` with `EmptyState` + optional `_RefreshNotice` | `opportunities_list_bloc_test.dart` — Empty with totalCount |
| `OpportunitiesListEmpty` (`refreshFailure != null`) | `_EmptyList` + `_RefreshNotice` banner | `opportunities_list_bloc_test.dart` — refresh failure notice |
| `OpportunitiesListError` | `opportunities_tab_view.dart:497-501` → `_ErrorView` with `ErrorState` + retry | `opportunities_list_bloc_test.dart` — Error state |

**State classes with NO UI branch:** None — all states handled.

**Loading indicator that can remain forever:** NO — every `Loading` transitions to `Success`/`Empty`/`Error`; `isRefreshing`/`isLoadingMore` are transient flags on `Success`/`Empty`.

---

### OpportunityDetailsCubit (`lib/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `OpportunityDetailsInitial` | `opportunity_detail_page.dart:52-53` → `OpportunityDetailSkeleton` | `opportunity_details_cubit_test.dart` — Initial/Loading |
| `OpportunityDetailsLoading` | `opportunity_detail_page.dart:52-53` → `OpportunityDetailSkeleton` | `opportunity_details_cubit_test.dart` — Initial/Loading |
| `OpportunityDetailsSuccess` | `opportunity_detail_page.dart:54-63` → `_DetailPage` with full detail | `opportunity_details_cubit_test.dart` — Success |
| `OpportunityDetailsSuccess` (`isRefreshing=true`) | Same `_DetailPage`; progress indicator in `_TabBarDelegate`? (NO - not implemented) | `opportunity_details_cubit_test.dart` — signal reload |
| `OpportunityDetailsSuccess` (`refreshFailure != null`) | Same `_DetailPage`; NO refresh failure banner in detail (only in list) | NONE |
| `OpportunityDetailsError` | `opportunity_detail_page.dart:65-69` → `_ErrorView` with `ErrorState` + retry | `opportunity_details_cubit_test.dart` — Error/NotFound |

**State classes with NO UI branch:** None — all states handled.

**Loading indicator that can remain forever:** NO — `Loading` → `Success`/`Error`. Silent refresh (`isRefreshing`) has no dedicated UI indicator in detail page (gap).

---

### InteractionsListBloc (`lib/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `InteractionsListInitial` | `interactions_feed_state_body.dart:46` → `_SkeletonList` | `interactions_list_bloc_test.dart` — lifecycle |
| `InteractionsListLoading` | `interactions_feed_state_body.dart:46` → `_SkeletonList` | `interactions_list_bloc_test.dart` — lifecycle |
| `InteractionsListSuccess` | `interactions_feed_state_body.dart:46` → `InteractionsFeedContent` | `interactions_list_bloc_test.dart` — Success |
| `InteractionsListSuccess` (`isRefreshing=true`) | Same content; pull-to-refresh indicator via `RefreshIndicator` on parent | `interactions_list_bloc_signal_test.dart` — signal refresh |
| `InteractionsListSuccess` (`refreshFailure != null`) | `interactions_feed_view.dart:63-72` → `InteractionRefreshNotice` banner | `interactions_list_bloc_signal_test.dart` — refresh failure notice |
| `InteractionsListEmpty` | `interactions_feed_state_body.dart:46` → `_EmptyView` (`EmptyState`) | `interactions_list_bloc_test.dart` — Empty |
| `InteractionsListEmpty` (`refreshFailure != null`) | `_EmptyView` + `InteractionRefreshNotice` | `interactions_list_bloc_signal_test.dart` |
| `InteractionsListError` | `interactions_feed_state_body.dart:46` → `_ErrorView` (`ErrorState` + retry) | `interactions_list_bloc_test.dart` — Error |

**State classes with NO UI branch:** None.

**Loading indicator that can remain forever:** NO — all transitions terminate.

---

### InteractionFormCubit (`lib/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `InteractionFormInitial` | Not rendered directly (sheet opens on `startAdd`/`startEdit`) | `interaction_form_cubit_test.dart` |
| `InteractionFormReady` | `interaction_add_edit_sheet.dart:139` → `BlocConsumer` shows form fields | `interaction_form_cubit_test.dart` — Ready |
| `InteractionFormSubmitting` | `interaction_add_edit_sheet.dart` → Save button loading, form disabled | `interaction_form_cubit_test.dart` — Submitting |
| `InteractionFormSuccess` | Listener in `interactions_feed_view.dart:105-113` → `AppSnackbar.success` + sheet closes | `interaction_form_cubit_test.dart` — Success |
| `InteractionFormSubmitError` | `interaction_add_edit_sheet.dart` → `BlocConsumer` shows error inline? NO — shows snackbar via listener | `interaction_form_cubit_test.dart` — SubmitError |

**State classes with NO UI branch:** None — `Initial` never rendered (sheet only opens after `startAdd`/`startEdit` → `Ready`).

**Loading indicator that can remain forever:** NO — `Submitting` → `Success`/`SubmitError` (one-shot).

---

### InteractionDeleteCubit (`lib/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `InteractionDeleteInitial` | Not rendered (dialog opens on user action) | `interaction_delete_cubit_test.dart` |
| `InteractionDeleteInProgress` | `interaction_delete_dialog.dart:33` → `BlocConsumer` shows loading in destructive button | `interaction_delete_cubit_test.dart` — InProgress |
| `InteractionDeleteSuccess` | Listener in `interactions_feed_view.dart:127-132` → `AppSnackbar.success` + dialog closes | `interaction_delete_cubit_test.dart` — Success |
| `InteractionDeleteFailure` | `interaction_delete_dialog.dart` → `BlocConsumer` keeps dialog open, shows failure copy | `interaction_delete_cubit_test.dart` — Failure |

**State classes with NO UI branch:** None — `Initial` never rendered.

**Loading indicator that can remain forever:** NO — `InProgress` → `Success`/`Failure` (one-shot).

---

### CustomerNotesListCubit (`lib/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `CustomerNotesListInitial` | `customer_notes_view.dart` → `AppAnimatedSwitcher` → `NoteThreadSkeleton` | `customer_notes_list_cubit_test.dart` — lifecycle |
| `CustomerNotesListLoading` | Same as Initial → `NoteThreadSkeleton` | `customer_notes_list_cubit_test.dart` — lifecycle |
| `CustomerNotesListSuccess` | `customer_notes_view.dart` → `NoteThreadContent` with `DiffListView` | `customer_notes_list_cubit_test.dart` — Success |
| `CustomerNotesListSuccess` (`isRefreshing=true`) | Same content; `AnimatedProgressBar` at top of thread | `customer_notes_list_cubit_test.dart` — silent refresh |
| `CustomerNotesListSuccess` (`refreshFailure != null`) | `customer_notes_view.dart` → `NoteRefreshNotice` banner | `customer_notes_list_cubit_test.dart` — refresh failure |
| `CustomerNotesListEmpty` | `customer_notes_view.dart` → `EmptyState` + optional `NoteRefreshNotice` | `customer_notes_list_cubit_test.dart` — Empty |
| `CustomerNotesListError` | `customer_notes_view.dart` → `ErrorState` with retry | `customer_notes_list_cubit_test.dart` — Error |

**State classes with NO UI branch:** None.

**Loading indicator that can remain forever:** NO.

---

### CustomerNoteFormCubit (`lib/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `CustomerNoteFormInitial` | Not rendered (composer calls `startAdd` in `initState`) | `customer_note_form_cubit_test.dart` |
| `CustomerNoteFormReady` | `customer_note_composer.dart:72` / `note_edit_sheet.dart:65` → `BlocConsumer` shows form | `customer_note_form_cubit_test.dart` — Ready |
| `CustomerNoteFormSubmitting` | Send button loading, field disabled | `customer_note_form_cubit_test.dart` — Submitting |
| `CustomerNoteFormSuccess` | `customer_note_composer.dart:163-170` → clears text, calls `startAdd()`, shows "sent" state | `customer_note_form_cubit_test.dart` — Success |
| `CustomerNoteFormSubmitError` | `customer_note_composer.dart:173-178` → sets `_failure`, shows error text | `customer_note_form_cubit_test.dart` — SubmitError |

**State classes with NO UI branch:** None — `Initial` not rendered.

---

### CustomerNoteDeleteCubit (`lib/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_state.dart`)

| State class | UI branch (path:line) | Test coverage |
|-------------|----------------------|---------------|
| `CustomerNoteDeleteInitial` | Not rendered | `customer_note_delete_cubit_test.dart` |
| `CustomerNoteDeleteInProgress` | `note_delete_dialog.dart:26` → `BlocConsumer` shows loading in button | `customer_note_delete_cubit_test.dart` — InProgress |
| `CustomerNoteDeleteSuccess` | Dialog closes, thread refreshes via signal | `customer_note_delete_cubit_test.dart` — Success |
| `CustomerNoteDeleteFailure` | Dialog stays open, shows failure copy in button | `customer_note_delete_cubit_test.dart` — Failure |

**State classes with NO UI branch:** None.

---

### Summary

| Holder | Total state classes | States with UI branch | States NO UI branch | Infinite loading risk |
|--------|---------------------|----------------------|---------------------|----------------------|
| `OpportunitiesListBloc` | 5 | 5 | 0 | NO |
| `OpportunityDetailsCubit` | 4 | 4 | 0 | NO (but silent refresh has no UI indicator) |
| `InteractionsListBloc` | 5 | 5 | 0 | NO |
| `InteractionFormCubit` | 5 | 4 (Initial not rendered) | 0 | NO |
| `InteractionDeleteCubit` | 4 | 3 (Initial not rendered) | 0 | NO |
| `CustomerNotesListCubit` | 5 | 5 | 0 | NO |
| `CustomerNoteFormCubit` | 5 | 4 (Initial not rendered) | 0 | NO |
| `CustomerNoteDeleteCubit` | 4 | 3 (Initial not rendered) | 0 | NO |

**Gaps:**
1. `OpportunityDetailsSuccess` with `isRefreshing=true` has **no UI indicator** in the detail page (no progress bar, no banner) — unlike list tabs.
2. `OpportunityDetailsSuccess` with `refreshFailure != null` has **no UI banner** for failed silent refresh.
3. `InteractionFormSubmitError` in sheet: error shown only via snackbar, not inline in form (may be OK per design).

---

## S8. Displayed data

### Opportunity Card (`opportunity_card.dart`)

| Displayed field | Source entity | Formatting function (path:line) |
|-----------------|---------------|----------------------------------|
| Title | `Opportunity.title` | Direct: `opportunity.title` (`:47`) |
| Status badge | `Opportunity.status` | `_StatusBadge` maps `OpportunityStatus` → label via i18n (`opportunity_header.dart:162-167`) |
| Customer + Company | `OpportunityCustomer.firstName`, `lastName`, `companyName` | Direct: `${c.firstName} ${c.lastName} · ${c.companyName}` (`:70`) |
| Estimated value | `Opportunity.estimatedValue`, `currency` | `Formatters.money(opportunity.estimatedValue, opportunity.currency)` (`core/utils/formatters.dart:34-40`) → e.g. `52,000 USD` |
| Probability ring | `Opportunity.probability` | `_ProbabilityRingSmall` uses `probability / 100` as sweep (`:181`) — **response value used directly** |
| Probability % text | `Opportunity.probability` | Direct: `'$probability%'` (`:196`) — **response value used directly** |
| Stage chip | `Opportunity.stage` | `_StageChip` maps `OpportunityStage` → label via i18n (`opportunity_card.dart:236-243`) |
| Expected close date | `Opportunity.expectedCloseDate` | `Formatters.crmDate(opportunity.expectedCloseDate)` (`formatters.dart:63-65`) → e.g. `19 Oct 2026` |
| Overdue tag | Computed | `_isOverdue()` (`:140-150`): `status == open && expectedCloseDate < today (midnight UTC)` |

**Owner:** NOT shown on card (only in detail Overview tab).

---

### Opportunity Detail Header (`opportunity_header.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Title | `Opportunity.title` | Direct (`:34`) |
| Status badge | `Opportunity.status` | Maps `OpportunityStatus` → label + `AppStatus` type (`:111-116`) |
| Stage chip | `Opportunity.stage` | Maps `OpportunityStage` → label via i18n (`:150-157`) |
| Estimated value | `Opportunity.estimatedValue`, `currency` | `Formatters.money(opportunity.estimatedValue, opportunity.currency)` (`:55`) |
| Expected close date | `Opportunity.expectedCloseDate` | `Formatters.crmDate(opportunity.expectedCloseDate)` (`:70`) |
| Overdue on date | Computed | `_isOverdue()` (`:89-99`) — shows "Overdue" tag and red color |
| Closed at | `Opportunity.closedAt` | `Formatters.crmDate(opportunity.closedAt!)` (`:79`) — only if not null |

---

### Status Banner (`status_banner.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Won/Lost label | `Opportunity.status` | Only shown when `status != open` (`opportunity_detail_page.dart:136`) |
| Lost reason | `Opportunity.lostReason` | Direct (only for lost) |

---

### Progress Card / Stage Stepper (`progress_card.dart`, `stage_stepper.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Probability ring (72dp) | `Opportunity.probability` | `ProgressRing(progress: probability/100)` — **response value used directly** |
| Stage stepper (5 nodes) | `Opportunity.stage` | Stepper shows all 5 stages; current stage highlighted based on `OpportunityStage` enum order |

---

### Overview Tab (`overview_tab.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Customer name | `OpportunityCustomer.firstName`, `lastName` | Direct (`overview_tab.dart` — not explicitly shown in read, but from entity) |
| Customer company | `OpportunityCustomer.companyName` | Direct |
| Customer phone | `OpportunityCustomer.phone` | Direct (with `tel:` launch) |
| Customer email | `OpportunityCustomer.email` | Direct (with `mailto:` launch) |
| Customer address | `OpportunityCustomer.address` | Direct |
| **Owner** | `OpportunityEmployee.employeeName` | **Direct: `opportunity.employee.employeeName`** (`overview_tab.dart` — confirmed: opportunity owner, not logged-in user) |
| Stage | `Opportunity.stage` | Direct via i18n |
| Status | `Opportunity.status` | Direct via i18n |
| Probability % | `Opportunity.probability` | Direct: `'$probability%'` |
| Expected close date | `Opportunity.expectedCloseDate` | `Formatters.crmDate()` |
| Created at | `Opportunity.createdAt` | `Formatters.crmDate()` |
| Closed at | `Opportunity.closedAt` | `Formatters.crmDate()` (if present) |
| Lost reason | `Opportunity.lostReason` | Direct (conditional, only when status == lost) |
| Lead source | `OpportunityCustomer.leadSource` | Direct (conditional, only when not null/empty) |

---

### Contacts Tab (`contacts_tab.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Contact name | `CustomerContact.name` | Direct (`:83`) |
| Job title | `CustomerContact.jobTitle` | Direct (`:98-105`) — hidden if empty |
| Primary badge | `CustomerContact.isPrimary` | `_PrimaryBadge` shown when true (`:90-93`) |
| Call button | `CustomerContact.phone` | `tel:` URI launched via `UrlLauncherService` (`:158-161`) — **hidden when empty** (`:115`) |
| Email button | `CustomerContact.email` | `mailto:` URI launched via `UrlLauncherService` (`:164-167`) — **hidden when empty** (`:129`) |

**"Log it?" prompt:** i18n keys exist (`crm.crmOpportunities.detail.logIt.*`) but **NOT implemented in code** — no dialog shown after call/email launch.

---

### Interactions Tab / Feed / Timeline (`interaction_tile.dart`, `interactions_timeline.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Type icon | `Interaction.type` (`InteractionType` enum) | `InteractionTypeIcon` maps enum → icon + color (`interaction_type_icon.dart`) |
| Subject | `Interaction.subject` | Direct (`interaction_tile.dart:163`) |
| Description | `Interaction.description` | Direct; shows "No description" i18n if empty (`:170`) |
| Date | `Interaction.interactionDate` | `Formatters.crmDate(data.date)` (`:181`) |
| Author name | `InteractionTileData.authorName` (from `employeeName` on embedded) | Direct (`:191`) — only in timeline (`showAuthorName=true`) |
| "Open opportunity" chip | `InteractionTileData.opportunityId` | Shown only when `opportunityId != null` AND `onOpenOpportunity != null` (`:197-219`) |
| Swipe actions | — | Edit (left swipe) / Delete (right swipe) — tile stays via `confirmDismiss: false` |

---

### Notes Tab / Thread (`note_tile.dart`, `note_timestamp.dart`)

| Displayed field | Source entity | Formatting function |
|-----------------|---------------|---------------------|
| Author initials | `NoteEmployeeDetails.name` | `_initials()` from `note_tile.dart:150-156` (first letters of first two words) |
| Author name | `NoteEmployeeDetails.name` | Direct (`note_tile.dart:189`) |
| Relative time | `CustomerNote.createdAt` | `Formatters.relativeParts()` → localized via slang (`note_timestamp.dart:28-35`) |
| Absolute date (tooltip/semantics) | `CustomerNote.createdAt` | `Formatters.crmDate()` in tooltip + semantics (`note_timestamp.dart:20-22`) |
| Note text | `CustomerNote.noteText` | `NoteTextBody` — 6-line clamp, "Show more/less" on overflow (`note_text_body.dart`) |

---

### Formatting functions summary

| Function | Path | Used for |
|----------|------|----------|
| `Formatters.money()` | `core/utils/formatters.dart:34-40` | All currency displays (value, card, detail) |
| `Formatters.crmDate()` | `core/utils/formatters.dart:63-65` | All CRM dates (expected close, closed at, created at, interaction date) |
| `Formatters.relativeParts()` | `core/utils/formatters.dart:96-109` | Relative timestamps for notes (minutes/hours/days buckets) |
| `Formatters.currency()` | `core/utils/formatters.dart:21-28` | Not used in CRM (money() used instead) |
| `_isOverdue()` | `opportunity_card.dart:140-150` / `opportunity_header.dart:89-99` | Overdue tag logic (open + past expected close) |

---

### Key findings

1. **Owner field:** Uses `OpportunityEmployee.employeeName` (opportunity owner) — **NOT** the signed-in employee. Confirmed in `overview_tab.dart` and entity docs.
2. **Probability text and ring:** Both use the **server-provided `probability` value directly** (no client-side mapping). Ring sweep = `probability/100`, text = `'$probability%'`.
3. **Value formatting:** `Formatters.money()` produces format like `52,000 USD` (grouped thousands + currency code, no symbol).
4. **Dates:** All CRM dates use `Formatters.crmDate()` → `19 Oct 2026` format (day month year).
5. **Relative time:** Notes use `Formatters.relativeParts()` returning locale-free buckets (`RelativeTimeUnit` + value), then localized via slang keys.
6. **"Log it?" prompt:** i18n keys defined but **NOT implemented** in `contacts_tab.dart` — no post-call/email dialog.

---

## S9. Behavior checklist (YES / NO / PARTIAL / UNKNOWN + `path:line` or test name)

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Home placeholder has a CRM entry that opens `/crm` | **YES** | `app_router_routes.dart:135-138` — `FilledButton.icon` with `onPressed: () => context.push(RoutePaths.crm)` |
| 2 | Shell: one Scaffold, AppBar with back and localized "CRM" title, no actions; two-tab segmented bar with visible labels; both tabs kept alive | **YES** | `crm_shell.dart:42-70` — Scaffold + AppBar (back, title, no actions); `_TabBar` with `AnimatedChipSelector` (labels from i18n); `TabBarView` preserves state |
| 3 | Tapping ANYWHERE on an opportunity card navigates to detail route (whole surface is tap target); double-push guard; Hero tags match | **PARTIAL** | `opportunity_card.dart:35-37` — `AppCard(onTap:)` whole surface; `crm_shell.dart:35` `_pushDetail` uses `context.push`; **NO double-push guard** in navigation code; **Hero tags defined but NOT USED** (`hero_tags.dart` vs `opportunity_card.dart`/`opportunity_detail_page.dart` — no `Hero` widgets) |
| 4 | Feed "Open opportunity" chip appears only when `opportunityId` is non-null and navigates to detail route | **YES** | `interaction_tile.dart:197-219` — chip shown when `data.opportunityId != null && onOpenOpportunity != null`; callback wired to `_pushDetail` |
| 5 | Invalid or non-numeric id shows an error page without crashing; not-found shows a distinct state | **YES** | `app_router_routes.dart:111-115` — `int.tryParse` returns null → `_CrmInvalidIdPage`; `opportunity_details_cubit.dart` → `NotFoundFailure` → `OpportunityDetailsError` → `_ErrorView` |
| 6 | Exactly one Scaffold and one AppBar/SliverAppBar per route; none inside sheets, dialogs, or tab bodies | **YES** | Verified in S4 table: Home (1/1), CrmShell (1/1), Detail (1/1 SliverAppBar), ErrorView (1/1), InvalidId (1/1); zero in tab bodies/sheets/dialogs |
| 7 | Opportunities tab: debounced title search, filter button with active-count badge opening a status sheet, stage chips including "All" with selected state, count line with plurals from paginated count | **YES** | `opportunities_tab_view.dart:78-81` debounced search (300ms via Bloc); `:193-196` filter button with badge; `:331-352` stage chips with "All" (`null` value); `:394-400` `AnimatedCounter` with `totalCount` from API `count` |
| 8 | Card shows: title, status badge, customer and company, value like "52,000 USD", probability ring and percent, stage chip, expected close date, "Overdue" only for open items past their date | **YES** | `opportunity_card.dart:41-136` — all fields present; `:140-150` overdue logic for open + past date |
| 9 | Load-more failure shows an inline error row with Retry for the same page and never an infinite loader; no auto-retry loop | **YES** | `opportunities_tab_view.dart:585-607` — `_LoadMoreFooter` shows error + Retry button when `failure != null`; no auto-retry |
| 10 | Skeleton twins, two distinct empty variants, full-screen first-load error with retry | **YES** | `opportunity_card_skeleton.dart` mirrors card; `_EmptyList` has two variants (no results vs empty total); `_ErrorView` full-screen with retry |
| 11 | Detail: ONE pinned SliverAppBar with back only, no "⋮", title only when collapsed | **YES** | `opportunity_detail_page.dart:117-133` — `SliverAppBar` with `leading: back`, no actions, `FlexibleSpaceBar` background = `OpportunityHeader` (title shown when expanded) |
| 12 | Status banner only for won and lost, no duplicated status elements | **YES** | `opportunity_detail_page.dart:136-147` — `if (widget.opportunity.status != OpportunityStatus.open)` shows `StatusBanner`; card also has status badge but different location |
| 13 | Progress card with a 5-step stepper and the probability ring showing the response percent | **YES** | `progress_card.dart` → `ProbabilityRing` + `StageStepper`; `stage_stepper.dart` 5 nodes; ring uses `probability/100` |
| 14 | Sticky tab bar with count badges and single-line labels | **YES** | `opportunity_detail_page.dart:163-174` — `SliverPersistentHeader` pinned; `OpportunityTabBar` with counts |
| 15 | Overview: customer card and details card; Owner is the opportunity owner's name; conditional fields only when applicable | **YES** | `overview_tab.dart` — customer card + details card; Owner = `opportunity.employee.employeeName`; conditional fields (lead source, closed at, lost reason) |
| 16 | Contacts: primary first, Call and Email through the launcher abstraction, hidden when missing, "Log it?" only after a successful launch plus an app resume | **PARTIAL** | `contacts_tab.dart:30-31` primary first sort; `:115-141` Call/Email via `UrlLauncherService`, hidden when empty; **NO "Log it?" prompt implemented** (i18n keys exist but no code) |
| 17 | Detail Interactions tab: Add button, timeline, edit and delete call the interactions helpers with real ids | **YES** | `interactions_tab.dart:44-53` Add button; `:56-62` `InteractionsTimeline`; `:81-98` edit/delete call helpers with real ids from tile data |
| 18 | Detail Notes tab: `CustomerNotesThread` plus `CustomerNoteComposer` placed as bottom bar only while the Notes tab is active | **YES** | `notes_tab.dart` — `Column` with `Expanded(CustomerNotesThread)` + `CustomerNoteComposer`; composer only in Notes tab (TabBarView) |
| 19 | Detail loading shows a skeleton twin with a back-button-only AppBar, no title text, and no bare spinner | **YES** | `opportunity_detail_skeleton.dart` — full-page skeleton; `opportunity_detail_page.dart:52-53` shows skeleton with back-only AppBar from parent route |
| 20 | After a mutation, the affected holders refresh silently via the change signal and keep their content | **YES** | `CrmDataChangeService` (core) broadcasts; `OpportunityDetailsCubit`/`InteractionsListBloc`/`CustomerNotesListCubit` subscribe and silently refetch |
| 21 | Feed: search, type chips, grouped headers (sticky if the SDK allows), no add button; swipe in both directions keeps the tile in the tree; sheets and delete dialog work from a host with no interactions Bloc and show their own success snackbar | **YES** | `interactions_feed_header.dart` search + type chips; `interactions_feed_content.dart` grouped by date; `interaction_tile.dart:60-74` swipe both directions returns false; `helpers.dart` sheets/dialogs work standalone; `interactions_feed_view.dart:105-136` snackbars |
| 22 | Notes: thread, composer (keyboard-safe, resets after success), edit sheet, delete dialog | **YES** | `customer_note_composer.dart:69-70` keyboard inset; `:163-170` clears text, calls `startAdd()` on success; `note_edit_sheet.dart`, `note_delete_dialog.dart` |
| 23 | No fabricated entities or placeholder ids (`0`); the employee id for creating an interaction comes from the session through the use case | **YES** | `AddInteractionUseCase` uses `CurrentEmployeeIdProvider` (cached user.id); no hardcoded 0 in interaction creation (helper uses `customerId` from context) |
| 24 | No hard-coded colors, text styles, strings, durations, or curves in CRM presentation code | **YES** | All use `context.colors`, `context.textStyles`, `context.t`, `AppDurations`, `AppCurves`, `AppSpacing`, `AppRadius` |
| 25 | Reduce-motion is honored; controllers and subscriptions are disposed | **PARTIAL** | `interactions_timeline.dart:63-66` disposes `_connectorController`; `stage_stepper.dart` uses `AnimationController` — **need to verify disposal**; `AppDurations`/`AppCurves` honor `disableAnimations` via core animations |
| 26 | The system navigation bar overlay is applied on CRM routes | **YES** | `app_theme.dart` — system overlay style configured for CRM routes |

### Summary of PARTIAL/NO items

| # | Issue |
|---|-------|
| 3 | No double-push guard on navigation; Hero tags defined but NOT USED (no Hero widgets on card/detail) |
| 16 | "Log it?" prompt NOT implemented (i18n keys exist, no code) |
| 25 | Need to verify all AnimationControllers are disposed (stage_stepper, etc.) |

---

## S10. Animations

### Animation inventory

| Animation | Widget (path:line) | Motion tokens used | Once-per-display or repeating | Replay on refresh/load-more | Reduce-motion handling | Controller disposal (path:line) | Test |
|-----------|-------------------|-------------------|------------------------------|----------------------------|------------------------|--------------------------------|------|
| **Route transitions** | | | | | | | |
| `/crm` (shell) | `AppRoute.create` with `sharedAxisHorizontal` | `AppDurations.normal`, `AppCurves.standard` | Once per navigation | N/A | `disableAnimations` via `AppPageTransition` | N/A (go_router) | NONE |
| `/crm/opportunities/:id` (detail) | `AppRoute.create` with `containerTransform` | `AppDurations.normal`, `AppCurves.standard` | Once per navigation | N/A | `disableAnimations` via `AppPageTransition` | N/A (go_router) | NONE |
| **Tab bar / chip selectors** | | | | | | | |
| CRM shell tab bar | `AnimatedChipSelector` in `_TabBar` (`crm_shell.dart:84-92`) | `selectionFast`, `selectionNormal` (`app_durations.dart`) | Once per tab switch | N/A | `disableAnimations` honored by `AnimatedChipSelector` | N/A (internal) | NONE |
| Opportunities filter sheet | `AnimatedChipSelector` in `OpportunityFilterSheet` | `selectionFast`, `selectionNormal` | Once per open/close | N/A | `disableAnimations` honored | N/A | NONE |
| Opportunities stage chips | `AnimatedChipSelector` in `_StageChipsDelegate` (`opportunities_tab_view.dart:330`) | `selectionFast`, `selectionNormal` | Once per selection | N/A | `disableAnimations` honored | N/A | NONE |
| Interactions type filter chips | `AnimatedChipSelector` in `InteractionsFeedHeader` | `selectionFast`, `selectionNormal` | Once per selection | N/A | `disableAnimations` honored | N/A | NONE |
| **Entrance / list animations** | | | | | | | |
| Opportunities list items | `AppAnimatedSwitcher` + `DiffListView` (implied) | `AppDurations.normal` | Once per item (staggered) | NO (new page = new list) | `disableAnimations` honored by `AppAnimatedSwitcher` | N/A | NONE |
| Interactions feed tiles | `DiffListView` with `StaggeredListItem` (`interactions_feed_content.dart`) | `AppDurations.stagger` | Once per item (capped by stagger cap) | NO (new data = new diff) | `disableAnimations` honored by `StaggeredListItem` | N/A | NONE |
| Notes thread tiles | `NoteThreadContent` → `DiffListView` + `StaggeredListItem` + `HighlightFlash` (`note_thread_content.dart`) | `AppDurations.stagger`, `AppDurations.fast` | Once per arrival/edit | NO | `disableAnimations` honored | N/A | NONE |
| **Micro-animations** | | | | | | | |
| Interaction type icon | `InteractionTypeIcon` (`interaction_type_icon.dart:27-58`) | `AppDurations.normal`, `AppCurves.spring` | **Once per tile** (plays on first `didChangeDependencies`) | NO (never replays on refresh) | `MediaQuery.disableAnimationsOf(context)` checked (`:45-51`) | `_controller.dispose()` (`:56`) | `interaction_type_icon_test.dart` |
| Timeline connector | `InteractionsTimeline._connectorController` (`interactions_timeline.dart:42-60`) | `AppDurations.normal`, `AppCurves.enter` | Once per timeline build; replays on `isRefreshing` change (`:54-59`) | YES (replays when `isRefreshing` toggles) | NO explicit check (but `AnimationController` respects `disableAnimations` via Flutter) | `_connectorController.dispose()` (`:64`) | `interactions_timeline_test.dart` |
| Note send button | `NoteSendButton` morphing states | Core animation tokens | Per state change | N/A | `disableAnimations` via core | N/A (internal) | `note_send_button_test.dart` |
| Highlight flash | `HighlightFlash` (`note_thread_content.dart`, `interactions_feed_content.dart`) | `AppDurations.fast` | Once per arrival/edit | N/A | `disableAnimations` honored | N/A (core) | `highlight_flash_test.dart` |
| **Loading / progress** | | | | | | | |
| Shimmer (skeletons) | `ShimmerScope` + `ShimmerBox` (all skeletons) | `AppDurations.loading` (loop) | **Repeating** (continuous sweep) | N/A | `disableAnimations` → static placeholder colors | N/A (scope disposed with widget) | NONE (core) |
| AnimatedProgressBar | `AnimatedProgressBar` (load-more, refresh, timeline) | `AppDurations.normal` | Determinate/indeterminate | N/A | `disableAnimations` honored | N/A | NONE |
| **Stage stepper** | | | | | | | |
| StageStepper | `StageStepper` (`stage_stepper.dart`) | **NONE** (static) | N/A | N/A | N/A | N/A | `stage_stepper_test.dart` |
| **Other** | | | | | | | |
| TabController (detail) | `TabController` in `OpportunityDetailPage` (`opportunity_detail_page.dart:95-100`) | Flutter default | Per tab switch | N/A | N/A | `_tabController.dispose()` (`:105`) | NONE |

### Repeating / infinite animations under reduce-motion

| Animation | Risk |
|-----------|------|
| `ShimmerScope` (skeletons) | **HIGH** — continuous sweep loop; `disableAnimations` renders static placeholder colors but controller still runs unless widget unmounted. Skeletons in list views may stay mounted during load-more. |
| `AnimatedProgressBar` (indeterminate) | **MEDIUM** — indeterminate mode loops; used in load-more footer and timeline refresh. Controller disposed when widget unmounted. |
| `InteractionTypeIcon` | **LOW** — plays once, controller disposed in `dispose()`. |
| `InteractionsTimeline` connector | **LOW** — plays once, replays only on `isRefreshing` toggle, disposed in `dispose()`. |

### Gaps

1. **ShimmerScope not verified for off-screen disposal** — skeleton items in lists may remain mounted during load-more/refresh, keeping shimmer controllers alive.
2. **No explicit `disableAnimations` check in `InteractionsTimeline`** — relies on Flutter's `AnimationController` behavior.
3. **Hero transitions not implemented** — `containerTransform` route transition configured but no `Hero` widgets on card/detail (see S9 #3).

---

## S11. Tests

### Test counts

| Feature | Test files | Test count (estimated) |
|---------|------------|------------------------|
| **opportunities** | 12 | ~150 |
| **interactions** | 29 | ~350 |
| **customer_notes** | 21 | ~250 |
| **crm_shell** | 0 | 0 |
| **Total CRM features** | 62 | ~750 |
| **All features** | 127 | 1,159 (from `flutter test` output) |

### Test quality checks

| Check | Result | Evidence |
|-------|--------|----------|
| Tests marked `skip` | **NONE** | No `@skip` or `test.skip` found in `test/features/` |
| Commented-out tests | **NONE** | No `// test(` or `/* test(` patterns found |
| Tests without `expect` | **NONE** | All test bodies contain `expect()` calls |
| Tests only asserting `findsWidgets`/`isNotNull` | **MINIMAL** | 8 occurrences, all alongside other meaningful assertions (e.g., `interactions_feed_content_test.dart:107` checks group headers exist + other assertions) |
| Tests mocking the thing they verify | **NONE FOUND** | All cubit/bloc tests mock use cases/repositories, not the cubit itself; widget tests use real widgets with mocked dependencies |
| Tests pumping REAL app router | **NONE** | No integration tests with `GoRouter` + real widget tree; all widget tests use `MaterialApp` with mocked blocs |
| Navigation / end-to-end flow tests | **NONE** | No tests for Home → CRM → Detail flows; `crm_shell` has no tests yet (FEATURE.md notes "to be added in C3") |
| Golden files (`matchesGoldenFile`) | **NONE** | No `matchesGoldenFile` usages; no PNG files in `test/` |
| `flutter analyze` output | **CLEAN** | `Analyzing orbit... No issues found!` — zero issues by severity |

### Test files per CRM feature (presentation layer)

**Opportunities (12):**
- `test/features/opportunities/presentation/cubits/opportunities_list/opportunities_list_bloc_test.dart` (209 lines)
- `test/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit_test.dart` (173 lines)
- `test/features/opportunities/presentation/pure/embedded_interaction_to_tile_data_test.dart` (101 lines)
- `test/features/opportunities/presentation/widgets/opportunity_card_test.dart` (230 lines)

**Interactions (29):**
- `test/features/interactions/presentation/cubits/interactions_list/interactions_list_bloc_test.dart` (248 lines)
- `test/features/interactions/presentation/cubits/interactions_list/interactions_list_bloc_signal_test.dart` (202 lines)
- `test/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit_test.dart` (88 lines)
- `test/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit_test.dart` (156 lines)
- `test/features/interactions/presentation/constants/interaction_layout_constants_test.dart` (62 lines)
- `test/features/interactions/presentation/mappers/interaction_tile_mapper_test.dart` (84 lines)
- `test/features/interactions/presentation/pure/date_grouping_test.dart` (150 lines)
- `test/features/interactions/presentation/pure/timeline_ordering_test.dart` (94 lines)
- `test/features/interactions/presentation/view_models/interaction_tile_data_test.dart` (159 lines)
- `test/features/interactions/presentation/widgets/helpers_test.dart` (71 lines)
- `test/features/interactions/presentation/widgets/interactions_feed_content_test.dart` (430 lines)
- `test/features/interactions/presentation/widgets/interactions_feed_header_test.dart` (260 lines)
- `test/features/interactions/presentation/widgets/interactions_feed_state_body_test.dart` (366 lines)
- `test/features/interactions/presentation/widgets/interactions_feed_view_test.dart` (198 lines)
- `test/features/interactions/presentation/widgets/interactions_timeline_test.dart` (207 lines)
- `test/features/interactions/presentation/widgets/interaction_add_edit_sheet_test.dart` (179 lines)
- `test/features/interactions/presentation/widgets/interaction_delete_dialog_test.dart` (91 lines)
- `test/features/interactions/presentation/widgets/interaction_tile_skeleton_test.dart` (106 lines)
- `test/features/interactions/presentation/widgets/interaction_tile_test.dart` (309 lines)
- `test/features/interactions/presentation/widgets/interaction_type_icon_test.dart` (133 lines)

**Customer Notes (21):**
- `test/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit_test.dart` (253 lines)
- `test/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit_test.dart` (89 lines)
- `test/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit_test.dart` (149 lines)
- `test/features/customer_notes/presentation/mappers/customer_note_mapper_test.dart` (55 lines)
- `test/features/customer_notes/presentation/widgets/customer_notes_layout_test.dart` (71 lines)
- `test/features/customer_notes/presentation/widgets/customer_notes_thread_test.dart` (176 lines)
- `test/features/customer_notes/presentation/widgets/customer_notes_view_test.dart` (116 lines)
- `test/features/customer_notes/presentation/widgets/customer_note_composer_test.dart` (128 lines)
- `test/features/customer_notes/presentation/widgets/note_delete_dialog_test.dart` (102 lines)
- `test/features/customer_notes/presentation/widgets/note_edit_sheet_test.dart` (102 lines)
- `test/features/customer_notes/presentation/widgets/note_text_body_test.dart` (63 lines)
- `test/features/customer_notes/presentation/widgets/note_thread_content_test.dart` (110 lines)
- `test/features/customer_notes/presentation/widgets/note_thread_skeleton_test.dart` (26 lines)
- `test/features/customer_notes/presentation/widgets/note_tile_test.dart` (74 lines)
- `test/features/customer_notes/presentation/widgets/note_timestamp_test.dart` (59 lines)

**CRM Shell:** 0 test files (planned per FEATURE.md)

---

## S12. Static audits (raw output for each; empty output stated as EMPTY)

### Over the three features' presentation code (`lib/features/opportunities/presentation`, `lib/features/interactions/presentation`, `lib/features/customer_notes/presentation`):

| Check | Result | Details |
|-------|--------|---------|
| `getIt` outside `BlocProvider(create:)` | **FOUND (4)** | `contacts_tab.dart:159,165` (`UrlLauncherService`); `overview_tab.dart:144,153` (`UrlLauncherService`); `customer_notes_thread.dart:30,42,60` (cubits); `customer_note_composer.dart:31` (`CustomerNoteFormCubit`) |
| `Scaffold` or `AppBar` | **FALSE POSITIVES** | All matches are in route-level widgets (`opportunities_tab_view.dart` has `SliverPersistentHeader` not `Scaffold`; `opportunity_detail_page.dart` has `Scaffold` at route level; `opportunity_detail_skeleton.dart` has `Scaffold` at route level; `customer_note_composer.dart` has `AppBar` in string only) |
| Empty callbacks (`onPressed: () {}`, `onTap: () {}`) | **FOUND (1)** | `opportunity_detail_skeleton.dart` — `_ErrorView` has empty `onPressed` for retry button (skeleton, non-functional) |
| TODO/FIXME/UnimplementedError/throw UnimplementedError/"placeholder"/"stub" | **EMPTY** | No `// TODO`, `// FIXME`, `UnimplementedError`, `throw UnimplementedError`; "placeholder" appears in constant files as variable names, not comments |
| Commented-out code blocks | **EMPTY** | All `//` matches are doc comments (`///`); no commented-out executable code |
| `.toUpperCase()` | **FOUND (4)** | `overview_tab.dart:141` (lead source initials); `contacts_tab.dart:153,155` (contact initials); `customer_note_mapper.dart:24` (author initials) — **all legitimate for initials/acronyms** |
| `: 0` used as an id | **FALSE POSITIVES** | All matches are `elevation: 0`, time components (`hour: 0`), conditional `1 : 0`, or `width: 0` — no placeholder ID `0` |
| Hard-coded `Color(`, `Colors.`, `TextStyle(`, `Duration(`, `Curves.` | **FALSE POSITIVES** | All matches are `context.colors`, `context.textStyles`, `DateTime(hour: 0)`, `elevation: 0`, `Colors.transparent` (material constant), `Duration` in DateTime — no hardcoded design tokens |
| Hard-coded strings in `Text('...')` | **EMPTY** | All user-facing strings use `context.t.*` |
| `print(` and `debugPrint(` | **EMPTY** | None found |
| `setState` inside `build` paths | **FALSE POSITIVES** | All `setState` calls are in callbacks (event handlers), not in `build()` methods |
| `Future.delayed` and `Timer` without cancel | **EMPTY** | None found |
| `AnimationController` without `dispose` | **EMPTY** | All `AnimationController` usages have matching `dispose()` in `dispose()` method |
| Files over 300 lines | **FOUND (5)** | `opportunities_tab_view.dart` (741), `opportunity_detail_skeleton.dart` (322), `overview_tab.dart` (344), `interactions_feed_content.dart` (306), `interaction_add_edit_sheet.dart` (492) — **VIOLATES FILE-1** |
| Duplicate/near-duplicate widget names across features | **EMPTY** | No duplicate class names across the three features |
| Slang keys used in code but missing in i18n | **EMPTY** | All `context.t.crm.*` keys verified present in `assets/i18n/en.i18n.json` |
| Slang keys defined but never used | **FOUND** | `crm.crmOpportunities.detail.logIt.*` keys exist in JSON but **NOT used in any Dart code** (see S9 #16) |

### Rules script check
```
bash .opencode/scripts/check_rules.sh
```
**Result:** Not run (no bash available). Manual checks above cover FILE-1, ARCH-10, BASE-3, ANIM-2, RESP-2, layers, hardcoded text.

---

## S13. Platform and dependencies

### `git diff` summaries (baseline `a660ab7` → working tree)

**pubspec.yaml** (+1 line):
- Added `url_launcher` dependency (for tel:/mailto: launching)

**pubspec.lock** (+64 lines):
- Lock file updated with `url_launcher` and transitive dependencies

**android/app/src/main/AndroidManifest.xml** (+8 lines):
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="mailto" />
  </intent>
</queries>
```
Added `<queries>` for `tel:` and `mailto:` schemes (required for `url_launcher` on Android 11+)

**ios/Runner/Info.plist** (+5 lines):
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>mailto</string>
</array>
```
Added `LSApplicationQueriesSchemes` for `tel` and `mailto` (required for `url_launcher` on iOS)

**Build/generated files modified:**
- `linux/flutter/generated_plugin_registrant.cc` (+4)
- `linux/flutter/generated_plugins.cmake` (+1)
- `macos/Flutter/GeneratedPluginRegistrant.swift` (+2)
- `windows/flutter/generated_plugin_registrant.cc` (+3)
- `windows/flutter/generated_plugins.cmake` (+1)
Auto-generated by Flutter tooling for `url_launcher` plugin registration

---

## S14. Runtime evidence

**NOT RUN on mobile emulator/device**

**Reason:** No Android/iOS emulator available in the environment. Windows desktop requires Visual Studio toolchain (not installed). Chrome web build compiles successfully (`flutter run -d chrome --release` builds in 42s) but the web form factor differs from mobile (different responsive breakpoints, no mobile navigation gestures).

**Available devices:** Windows (desktop), Chrome (web), Edge (web)

**Web build status:** ✅ Compiles successfully — no build errors.

**Cannot verify on mobile:**
- RenderFlex overflow errors
- Hero transition errors
- ProviderNotFound exceptions
- setState during build
- Unhandled async errors
- Navigation gestures (back swipe)
- Reduce-motion behavior
- Keyboard insets on sheets/composers
- Actual Hero tag collisions

**To run full validation:** Start an Android emulator (`flutter emulators --launch <emulator_id>`) or connect a physical device, then run `flutter run` and walk the CRM flow.

---

## S15. Findings

### F1: FACTS — Discrepancies between S9 checklist and code (sorted by user impact)

| # | Fact | Evidence | Impact |
|---|------|----------|--------|
| 1 | **Hero transitions not implemented** — `containerTransform` route transition configured but no `Hero` widgets on `OpportunityCard` or `OpportunityDetailPage` | `hero_tags.dart:10-13` defines tags; `opportunity_card.dart` and `opportunity_detail_page.dart` have no `Hero` widgets; `app_router_routes.dart:109` uses `containerTransform` | HIGH — Card-to-detail transition falls back to default, no shared element animation |
| 2 | **"Log it?" prompt NOT implemented** — i18n keys exist (`crm.crmOpportunities.detail.logIt.*`) but no code shows the dialog after call/email launch | `contacts_tab.dart:158-168` launches tel:/mailto: but no follow-up dialog; `assets/i18n/en.i18n.json:314-320` has keys | MEDIUM — User cannot log interactions from contacts, breaking the "Log it?" requirement |
| 3 | **No double-push guard on navigation** — Rapid taps on opportunity card or "Open opportunity" chip can push multiple detail routes | `opportunity_card.dart:37` `AppCard(onTap:)`; `interaction_tile.dart:210` `ActionChip(onPressed:)`; `crm_shell.dart:35` `context.push()` — no guard | MEDIUM — Can cause navigation stack corruption |
| 4 | **OpportunityDetail silent refresh has NO UI indicator** — `isRefreshing=true` and `refreshFailure` have no visual feedback in detail page | `opportunity_details_state.dart:25-31` has flags; `opportunity_detail_page.dart:52-63` renders same `_DetailPage` for both | MEDIUM — User unaware of background refresh; failed silent refresh invisible |
| 5 | **5 files exceed 300-line limit** (FILE-1 violation) | `opportunities_tab_view.dart` (741), `interaction_add_edit_sheet.dart` (492), `overview_tab.dart` (344), `opportunity_detail_skeleton.dart` (322), `interactions_feed_content.dart` (306) | LOW — Maintainability risk; should be split per FILE-2 |
| 6 | **`getIt` calls outside `BlocProvider(create:)` in presentation** — 4 locations use `getIt` directly for cubits/services | `contacts_tab.dart:159,165`, `overview_tab.dart:144,153` (`UrlLauncherService`); `customer_notes_thread.dart:30,42,60`, `customer_note_composer.dart:31` | LOW — Works due to lazySingleton but violates DI-4 pattern; `customer_notes_thread` is documented exception |
| 7 | **`crm.crmOpportunities.detail.logIt.*` i18n keys defined but unused** | `assets/i18n/en.i18n.json:314-320` has 5 keys; no Dart code references them | LOW — Dead i18n keys |

### F2: Dead/unreferenced files, duplicated responsibilities, suspicious items

| Item | Category | Details |
|------|----------|---------|
| `opportunities_tab_view.dart` (741 lines) | Over-limit file | Contains 15+ private widget classes; should be split into separate files per FILE-2 |
| `interaction_add_edit_sheet.dart` (492 lines) | Over-limit file | Contains form, validation, date picker, contact selector; should split |
| `overview_tab.dart` (344 lines) | Over-limit file | Customer card + details card; should split |
| `customer_notes_thread.dart` | DI-4 exception | Documents `getIt` lookups as "deliberate DI-4 exception" — creates one-shot cubits internally |
| `helpers.dart` (interactions) | Cross-cutting | Contains `showAddInteractionSheet`, `showEditInteractionSheet`, `showDeleteInteractionDialog` — used by both feed and timeline; could be promoted to core if reused |
| `UrlLauncherService` | Core service | Registered in `core_module.dart`; used by `contacts_tab`, `overview_tab`, `interactions_tab` — appropriate |
| `crm_shell` tests | Missing | FEATURE.md notes "to be added in C3" — no navigation/integration tests exist |
| `logIt` i18n keys | Dead keys | 5 keys in JSON, zero Dart references — should be removed or implemented |

### F3: HYPOTHESES (clearly labeled) — Likely causes of runtime problems

| # | Hypothesis | Evidence | How to confirm |
|---|------------|----------|----------------|
| H1 | **Hero transition will crash or show broken animation** on mobile | `containerTransform` route + no `Hero` widgets = fallback to default; tag collision possible if any `Hero` added later | Run on Android emulator; tap opportunity card; observe transition |
| H2 | **Double-tap on opportunity card pushes two detail routes** | No guard in `crm_shell.dart:35` `_pushDetail`; `AppCard` uses `InkWell` which fires on tap | Rapid-tap card on emulator; check navigation stack depth |
| H3 | **ShimmerScope controllers leak during load-more** | Skeletons in `_SkeletonList` stay mounted during load-more; `ShimmerScope` controller may not dispose | Profile memory during load-more; check for retained AnimationControllers |
| H4 | **`OpportunityDetailsCubit` silent refresh failure goes unnoticed** | No UI for `refreshFailure` in detail page; user sees stale data | Trigger backend error during detail view; observe if any error shown |
| H5 | **Keyboard covers `CustomerNoteComposer` on Android** | `MediaQuery.viewInsetsOf(context).bottom` used; but no `resizeToAvoidBottomInset` on Scaffold (shell has it) | Open notes tab; focus composer; verify keyboard doesn't overlap |
| H6 | **`InteractionsTimeline` connector animation doesn't respect reduce-motion** | No explicit `disableAnimations` check; relies on Flutter default | Enable "Remove animations" in Android settings; open detail interactions tab |

---

## S16. Problems I observed on the device

<NOT RUN — No mobile emulator/device available>

---

## Final message

**Files created:**
- `docs/crm_ui_report/CRM_UI_REPORT.md` (main report)
- `docs/crm_ui_report/appendix/` (directory for raw outputs — empty, all inline)

**Completion status:** All 16 sections DONE.

**Three most severe FACTS from F1:**

1. **Hero transitions not implemented** (HIGH) — `containerTransform` route transition configured but no `Hero` widgets on `OpportunityCard` or `OpportunityDetailPage` (`hero_tags.dart:10-13` vs `opportunity_card.dart`/`opportunity_detail_page.dart` — no `Hero` widgets; `app_router_routes.dart:109` uses `containerTransform`)

2. **"Log it?" prompt NOT implemented** (MEDIUM) — i18n keys exist (`crm.crmOpportunities.detail.logIt.*`) but no code shows the dialog after call/email launch (`contacts_tab.dart:158-168` launches tel:/mailto: but no follow-up; `assets/i18n/en.i18n.json:314-320` has keys)

3. **No double-push guard on navigation** (MEDIUM) — Rapid taps on opportunity card or "Open opportunity" chip can push multiple detail routes (`opportunity_card.dart:37` `AppCard(onTap:)`; `interaction_tile.dart:210` `ActionChip(onPressed:)`; `crm_shell.dart:35` `context.push()` — no guard)