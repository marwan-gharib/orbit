# Opportunities UI Plan (Task 3 of 4)

## 1. Load-More Diagnosis (State Layer)

### Current Behavior Evidence
From `OpportunitiesListBloc._onLoadMoreRequested` (lines 113-146) and `_loadPage` (lines 148-229):
- Uses `droppable()` transformer → ignores duplicate LoadMore while in flight
- Emits `isLoadingMore: true` immediately with existing items
- On failure: keeps items, sets `loadMoreFailure`, emits `isLoadingMore: false`
- No automatic retry loop (correct per Q2)

### Root Cause Analysis
The infinite loader **IS NOT in the state layer**. The Bloc correctly:
1. Shows loading state in footer
2. Keeps items on failure
3. Surfaces `loadMoreFailure` for UI retry
4. Resets `isLoadingMore` to false

### Verdict
**No state-layer fix needed**. The root cause of any infinite loader would be in UI (not showing the error row, or not clearing `isLoadingMore` on retry). The Bloc contract is correct per Q2.

---

## 2. State-to-UI Mapping Tables

### OpportunitiesListBloc States → UI

| State Class | User Sees | Key Fields |
|-------------|-----------|------------|
| `OpportunitiesListInitial` | Skeleton list (3 cards) | — |
| `OpportunitiesListLoading` | Full-screen skeleton (first load) | `criteria` |
| `OpportunitiesListSuccess` | List + header + load-more footer | `items`, `hasMore`, `nextPage`, `totalCount`, `isRefreshing`, `isLoadingMore`, `loadMoreFailure`, `refreshFailure` |
| `OpportunitiesListEmpty` | Empty state ("No opportunities" or "No opportunities match your filters") | `totalCount`, `isRefreshing`, `refreshFailure` |
| `OpportunitiesListError` | Full-screen error with retry | `failure` |

### OpportunityDetailsCubit States → UI

| State Class | User Sees | Key Fields |
|-------------|-----------|------------|
| `OpportunityDetailsInitial` | Skeleton page (header block, progress card, tab bar, overview cards) | — |
| `OpportunityDetailsLoading` | Same skeleton (first load) | — |
| `OpportunityDetailsSuccess` | Full detail page | `opportunity`, `isRefreshing`, `refreshFailure` |
| `OpportunityDetailsError` | Full-screen error with retry + not-found distinction | `failure` |

### Displayed Fields → Source

| UI Field | Source (Entity Path) | Formatter |
|----------|---------------------|-----------|
| Opportunity title | `opportunity.title` | — |
| Status badge | `opportunity.status` (enum label via slang) | — |
| Stage chip | `opportunity.stage` (enum label via slang) | — |
| Customer name | `opportunity.customer.firstName + ' ' + lastName` | — |
| Company | `opportunity.customer.companyName` | — |
| Estimated value | `opportunity.estimatedValue`, `currency` | `Formatters.money()` |
| Probability % | `opportunity.probability` (server value) | `"${probability}%"` |
| Probability ring sweep | `probability / 100` clamped 0..1 | — |
| Expected close date | `opportunity.expectedCloseDate` | `Formatters.crmDate()` |
| Closed date | `opportunity.closedAt` | `Formatters.crmDate()` |
| Created date | `opportunity.createdAt` | `Formatters.crmDate()` |
| Owner | `opportunity.employee.employeeName` | — |
| Lead source | `opportunity.customer.leadSource` (nullable) | — |
| Lost reason | `opportunity.lostReason` (fallback: slang `lostReasonEmpty`) | — |
| Overdue tag | Local: `status == open && expectedCloseDate < today` | — |
| Customer code | `opportunity.customer.customerCode` | — |
| Address | `opportunity.customer.address` | — |
| Phone | `opportunity.customer.phone` | `UrlLauncherService` (tel:) |
| Email | `opportunity.customer.email` | `UrlLauncherService` (mailto:) |
| Contacts | `opportunity.customer.contacts` (map to `InteractionContactOption`) | — |
| Embedded interactions | `opportunity.customer.interactions` → `InteractionTileData` | `sortInteractionsForTimeline` |
| Embedded notes | `opportunity.customer.notes` (count badge only) | — |

---

## 3. Core Reuse & New Shared Pieces

### Exact Reuse from Core & Earlier Features

| Piece | Location | Use In |
|-------|----------|--------|
| `AppCard` | `core/widgets/app_card.dart` | Opportunity card, Overview cards, Progress card, Status banner |
| `StatusBadge` | `core/widgets/status_badge.dart` | Status badge (row A), status banner |
| `ProgressRing` | `core/widgets/progress_ring.dart` | Probability ring (28dp card, 72dp detail) |
| `AnimatedChipSelector<T>` | `core/animations/selection/selection.dart` | Stage chips (tab header), Status filter sheet |
| `ExpandableSearchField` | `core/widgets/expandable_search_field.dart` | Search field with progress line |
| `ShimmerScope` + `ShimmerBox` | `core/animations/loading/...` | All skeletons (card twin, page twin) |
| `AppAnimatedSwitcher` | `core/animations/state/app_animated_switcher.dart` | State transitions (list, detail) |
| `AnimatedProgressBar` | `core/animations/loading/animated_progress_bar.dart` | Load-more footer, silent refresh |
| `AppBottomSheet` | `core/animations/overlays/app_bottom_sheet.dart` | Filter sheet, Add/Edit interaction sheets |
| `showAppDialog` / `AppDialog` | `core/animations/overlays/...` | Delete confirmation, error dialogs |
| `AppSnackbar` | `core/animations/overlays/...` | Launch failures, mutation results |
| `UrlLauncherService` | `core/services/url_launcher_service.dart` | Phone/email actions |
| `Formatters.money` / `crmDate` / `relativeParts` | `core/utils/formatters.dart` | All value/date formatting |
| `AppSpacing`, `AppRadius`, `AppDurations`, `AppCurves` | `core/theme/...` | All layout/motion tokens |
| `CrmDataChangeService` | `core/services/crm_data_change_service.dart` | Silent reload signal |
| `diffList` | `core/utils/list_diff.dart` | ID-diffed lists (if needed) |
| `InteractionType` | `core/domain/enums/interaction_type.dart` | Embedded interactions type |
| `InteractionTileData`, `InteractionContactOption`, `InteractionEditData` | `features/interactions/presentation/view_models/...` | Interactions tab mapping |
| `showAddInteractionSheet`, `showEditInteractionSheet`, `showDeleteInteractionDialog` | `features/interactions/presentation/widgets/helpers.dart` | Interactions tab actions |
| `InteractionsTimeline` | `features/interactions/presentation/widgets/interactions_timeline.dart` | Interactions tab content |
| `CustomerNotesThread` | `features/customer_notes/presentation/widgets/customer_notes_thread.dart` | Notes tab content |
| `CustomerNoteComposer` | `features/customer_notes/presentation/widgets/customer_note_composer.dart` | Notes tab bottom bar |
| `sortInteractionsForTimeline` | `features/interactions/presentation/pure/timeline_ordering.dart` | Embedded interactions ordering |

### New Shared Pieces (Core Additions)

| Piece | Location | Justification |
|-------|----------|---------------|
| `OpportunityLayoutConstants` | `features/opportunities/presentation/constants/opportunity_layout_constants.dart` | Shared geometry for card, its skeleton twin, detail page sections |
| `OpportunityCardSkeleton` | `features/opportunities/presentation/widgets/opportunity_card_skeleton.dart` | Twin of `OpportunityCard` (Q3) |
| `OpportunityDetailSkeleton` | `features/opportunities/presentation/widgets/opportunity_detail_skeleton.dart` | Twin of full detail page (Q3) |
| `StageStepper` | `features/opportunities/presentation/widgets/stage_stepper.dart` | 5-node stepper with connector lines, animated fill/pop/pulse |
| `ProbabilityRing` (wrapper) | `features/opportunities/presentation/widgets/probability_ring.dart` | Configures `ProgressRing` for 28dp/72dp, semantic colors |
| `OpportunityTabBar` | `features/opportunities/presentation/widgets/opportunity_tab_bar.dart` | Sticky tab bar with sliding indicator, count badges, horizontal scroll |
| `LogItPrompt` | `features/opportunities/presentation/widgets/log_it_prompt.dart` | Bottom prompt with lifecycle observer, one-shot per successful launch |
| `UrlLauncherServiceFake` | `test/core/services/url_launcher_service_fake.dart` | Test double for `UrlLauncherService` (records launches, controllable results) |
| Platform entries | `android/app/src/main/AndroidManifest.xml` (`<queries>` for `tel:`, `mailto:`), `ios/Runner/Info.plist` (`LSApplicationQueriesSchemes`) | Required for `url_launcher` to work on Android 11+/iOS |

### Core Gaps (To Create in O1)
- `UrlLauncherService` implementation exists; fake and platform entries needed
- Value formatter (`Formatters.money`) exists; works for "52,000 USD"
- No core stepper widget → create `StageStepper` in feature
- No core tab bar with badges → create `OpportunityTabBar` in feature

---

## 4. File Tree & Pure Mapping Functions

### New File Structure
```
lib/features/opportunities/
├── presentation/
│   ├── constants/
│   │   └── opportunity_layout_constants.dart
│   ├── widgets/
│   │   ├── opportunity_card.dart
│   │   ├── opportunity_card_skeleton.dart
│   │   ├── opportunity_tab_bar.dart
│   │   ├── stage_stepper.dart
│   │   ├── probability_ring.dart
│   │   ├── opportunity_detail_skeleton.dart
│   │   ├── log_it_prompt.dart
│   │   ├── opportunities_tab_view.dart
│   │   ├── opportunity_detail_page.dart
│   │   ├── opportunity_header.dart
│   │   ├── status_banner.dart
│   │   ├── progress_card.dart
│   │   ├── overview_tab.dart
│   │   ├── contacts_tab.dart
│   │   ├── interactions_tab.dart
│   │   └── notes_tab.dart
│   ├── pure/
│   │   ├── embedded_interaction_to_tile_data.dart
│   │   └── contact_to_interaction_option.dart
│   └── mappers/
│       └── opportunity_detail_mappers.dart
```

### Pure Mapping Functions (with Unit Tests)

#### `embedded_interaction_to_tile_data.dart`
```dart
/// Maps EmbeddedCustomerInteraction → InteractionTileData for the timeline.
InteractionTileData embeddedInteractionToTileData(
  EmbeddedCustomerInteraction e, {
  required int customerId,
  required int opportunityId,
}) => InteractionTileData(
  id: e.interactionId,
  type: e.type,
  subject: e.subject,
  description: e.description,
  date: e.interactionDate,
  authorName: e.employeeName,
  customerId: customerId,
  contactId: e.contactId,
  opportunityId: e.opportunityId ?? opportunityId,
);
```

#### `contact_to_interaction_option.dart`
```dart
/// Maps CustomerContact → InteractionContactOption for the add sheet.
InteractionContactOption contactToInteractionOption(CustomerContact c) =>
    InteractionContactOption(id: c.contactId, label: c.name);
```

### Hero Tag Scheme
```dart
// HeroTags.opportunityTitle(opportunityId) → 'opportunity_title_$id'
// HeroTags.opportunityStatus(opportunityId) → 'opportunity_status_$id'
// Used on: card title + status badge → detail header title + status badge
// Flight: NOT VERIFIED (needs real device for Hero transition visual)
```

### Detail Page: Composer & Keyboard Handling
- `CustomerNoteComposer` sits in a `PersistentFooterButton`-style slot using `BottomSheet`-like padding: `MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom`
- Page body is a `CustomScrollView` with `slivers`; composer is NOT in the scroll view
- `NotesTab` returns a `Column` with `Expanded` thread + `CustomerNoteComposer` as bottom bar
- Tab switching animates composer show/hide via `AnimatedSwitcher` + `AnimatedSize`

---

## 5. Widget Trees & Skeleton Twins (Shared Layout Constants)

### OpportunityCard (List Item)
```
AppCard (tappable, InkWell, ripple clipped to radius)
  Padding(AppSpacing.md)
  Column(crossAxisAlignment: start)
    Row A: Expanded(Title, maxLines=2) + StatusBadge(dot+label, semantic color)
    Row B: Row(Icon(person), CustomerName · Company, ellipsis)
    Divider()
    Row C: Formatters.money(value, currency) [emphasized] + ProbabilityRing(28dp, %)
    Row D: StageChip(neutral tonal) + Row(Icon(calendar), ExpectedCloseDate) [+ OverdueTag if open & past]
```

### OpportunityCardSkeleton (Twin - same constants)
```
ShimmerScope
  AppCard (same padding/radius)
    Column
      Row: ShimmerBox(width: 0.6) + ShimmerBox(circle: 24dp)  // title + status
      Row: ShimmerBox(circle: 32dp) + ShimmerBox(width: 0.7)   // avatar + name
      Divider
      Row: ShimmerBox(width: 0.4) + ShimmerBox(circle: 28dp)   // value + ring
      Row: ShimmerBox(width: 0.35) + ShimmerBox(width: 0.3)    // stage + date
```

### OpportunityDetailPage (Success State)
```
Scaffold
  CustomScrollView
    SliverAppBar(pinned, surface color, back only)
      FlexibleSpaceBar(collapseMode: parallax)
        Header block: Title(large, 2 lines) + Row(StatusBadge, StageChip) + Value(prominent) + Dates
    SliverToBoxAdapter
      StatusBanner (won/lost only) [full-width card]
    SliverToBoxAdapter
      ProgressCard: Row(StageLabel, StageName) + ProbabilityRing(72dp) + StageStepper(5 nodes)
    SliverPersistentHeader(pinned) → OpportunityTabBar(count badges)
    SliverFillRemaining → TabBarView(fade-through)
      Overview: CustomerCard + DetailsCard
      Contacts: ListView(ContactCards with Call/Email buttons)
      Interactions: AddButton + InteractionsTimeline
      Notes: CustomerNotesThread + CustomerNoteComposer(bottom bar)
```

### OpportunityDetailSkeleton (Twin - same constants)
```
Scaffold
  CustomScrollView
    SliverAppBar(pinned, surface color, back only)  // NO title text
    SliverToBoxAdapter
      Header block: ShimmerBox(large title) + ShimmerBox(row: badge+chip) + ShimmerBox(value) + ShimmerBox(dates)
    SliverToBoxAdapter
      ShimmerBox(card: status banner area)
    SliverToBoxAdapter
      ProgressCard skeleton: Row(ShimmerBox, ShimmerBox) + ShimmerBox(circle: 72dp) + Row(5x ShimmerBox(circle: node))
    SliverPersistentHeader(pinned) → ShimmerBox(pills: 4 tabs)
    SliverFillRemaining → ShimmerBox(Overview cards)
```

### Shared Layout Constants (`OpportunityLayoutConstants`)
```dart
abstract final class OpportunityLayoutConstants {
  // Card
  static double get cardPadding => AppSpacing.md;
  static double get cardRadius => AppRadius.borderLg;
  static double get cardRowGap => AppSpacing.sm;
  static double get cardDividerGap => AppSpacing.sm;
  static double get cardRingSizeSmall => Responsive.adapt(28);
  static double get cardRingStrokeWidth => Responsive.adapt(3);
  
  // Detail Header
  static double get headerPadding => AppSpacing.lg;
  static double get headerTitleGap => AppSpacing.xs;
  static double get headerRowGap => AppSpacing.sm;
  static double get headerValueStyle => context.textStyles.headlineSmall; // via context
  
  // Progress Card
  static double get progressCardPadding => AppSpacing.lg;
  static double get progressRingSizeLarge => Responsive.adapt(72);
  static double get progressRingStrokeWidth => Responsive.adapt(6);
  static double get stepperNodeSize => Responsive.adapt(20);
  static double get stepperNodeSizeCurrent => Responsive.adapt(28);
  static double get stepperConnectorHeight => Responsive.adapt(2);
  static double get stepperLabelMaxWidth => Responsive.width(0.16); // 1/5 minus gaps
  
  // Tab Bar
  static double get tabBarHeight => Responsive.adapt(48);
  static double get tabIndicatorHeight => Responsive.adapt(3);
  static double get tabBadgeSize => Responsive.adapt(16);
  
  // Overview Cards
  static double get overviewCardPadding => AppSpacing.md;
  static double get overviewRowGap => AppSpacing.xs;
  static double get overviewIconSize => Responsive.adapt(20);
  
  // Contact Card
  static double get contactCardPadding => AppSpacing.md;
  static double get contactAvatarSize => Responsive.adapt(44);
  static double get contactButtonSize => kMinInteractiveDimension;
  
  // Skeleton rows
  static const int cardSkeletonRows = 1; // single card
  static const int detailSkeletonSections = 5; // header, banner, progress, tabs, overview
}
```

---

## 6. Test Plan Table

| Test File | Test Name | Fixture | Proves | Fails If |
|-----------|-----------|---------|--------|----------|
| `opportunity_card_test.dart` | `taps corners/gaps/badge/date/ring all call callback once` | `tOpportunity()` | Q1: whole-card tap target | Callback not called, called >1, or wrong id |
| `opportunity_card_test.dart` | `double-tap guard prevents double push` | `tOpportunity()` | Q1: double-tap guard | Second tap calls callback |
| `opportunities_tab_view_test.dart` | `search dispatches debounced event` | Mock Bloc | Search field wiring | Event not dispatched or wrong text |
| `opportunities_tab_view_test.dart` | `filter chip changes dispatch immediately` | Mock Bloc | Stage/status filter wiring | Event not dispatched |
| `opportunities_tab_view_test.dart` | `load-more failure shows error row with Retry` | Mock Bloc (fail page 2) | Q2: inline error row | Error row missing, no Retry, or auto-retry loop |
| `opportunities_tab_view_test.dart` | `Retry requests same page once, shows in-button progress` | Mock Bloc | Q2: retry behavior | Wrong page requested, no progress, or multiple requests |
| `opportunities_tab_view_test.dart` | `empty filter shows 'Clear filters' action` | Mock Bloc (Empty state) | Clear filters UX | Action missing or wrong text |
| `opportunities_tab_view_test.dart` | `skeleton twin matches card geometry` | Golden | Q3: skeleton twin | Visual diff |
| `opportunity_detail_page_test.dart` | `exactly one SliverAppBar with back button, no title during load` | Mock Cubit (Loading) | Q3: single AppBar, no title | Multiple AppBars, title present in load |
| `opportunity_detail_page_test.dart` | `probability text = response value, ring sweep = value/100` | `tOpportunity(probability: 35)` | Q5: no stage→probability mapping | Text ≠ "35%" or sweep ≠ 0.35 |
| `opportunity_detail_page_test.dart` | `owner = employee.employeeName` | `tOpportunity(employee: Omar Mohammed)` | Q5: correct owner | Wrong name shown |
| `opportunity_detail_page_test.dart` | `lost reason fallback when empty` | `tOpportunity(status: lost, lostReason: '')` | Q5: conditional fields + fallback | Shows empty or wrong text |
| `opportunity_detail_page_test.dart` | `stage stepper: 5 nodes, completed=check, current=ring, lost=error+X` | `tOpportunity(stage: proposal, status: open)` | Stepper visual logic | Wrong node states |
| `opportunity_detail_page_test.dart` | `tab bar counts from embedded data` | `tOpportunity(customer: contacts=3, interactions=5, notes=2)` | Tab badges | Counts missing or wrong |
| `opportunity_detail_page_test.dart` | `Contacts tab: primary marker, hidden buttons when value missing` | `tCustomer(contacts: [primary+phone, no-email])` | Q6: no dead buttons | Buttons shown for missing values |
| `contacts_tab_test.dart` | `launch tel:/mailto: via UrlLauncherService` | Fake launcher | Launcher abstraction | Direct `url_launcher` import or no call |
| `contacts_tab_test.dart` | `launch failure shows localized snackbar` | Fake launcher (returns false) | Q6: error handling | No snackbar or wrong text |
| `contacts_tab_test.dart` | `Log it? only after successful launch + resume, once` | Fake launcher + lifecycle | Log-it lifecycle | Prompt shows without launch, or twice |
| `interactions_tab_test.dart` | `add/edit/delete call helpers with real ids` | Mock helpers | Real ids passed | Placeholder ids or missing context |
| `interactions_tab_test.dart` | `embedded interactions mapped newest-first` | `tOpportunity(interactions: [old, new])` | Pure mapping + sort | Wrong order or missing fields |
| `notes_tab_test.dart` | `thread + composer only on Notes tab` | Mock Cubit | Tab-scoped composer | Composer visible on other tabs |
| `opportunity_detail_page_test.dart` | `silent refresh keeps content, thin progress, dismissible notice on fail` | Mock Cubit (refreshFailure) | Silent refresh UX | Content replaced, no progress, notice not dismissible |
| `layout_test.dart` | `360x640 textScale 1.0: no overflow` | Golden | Q7: responsive | Overflow or clipped |
| `layout_test.dart` | `360x640 textScale 1.5: no overflow` | Golden | Q7: accessibility | Overflow or clipped |
| `layout_test.dart` | `412x917 textScale 1.0: no overflow` | Golden | Q7: tablet | Overflow or clipped |

### Layout Goldens (Paths)
- `test/goldens/opportunities_tab_loading.png`
- `test/goldens/opportunities_tab_success.png`
- `test/goldens/opportunities_tab_empty.png`
- `test/goldens/opportunities_tab_error.png`
- `test/goldens/opportunities_tab_load_more_failure.png`
- `test/goldens/opportunities_tab_filter_sheet.png`
- `test/goldens/opportunity_detail_loading.png`
- `test/goldens/opportunity_detail_success_open.png`
- `test/goldens/opportunity_detail_success_won.png`
- `test/goldens/opportunity_detail_success_lost.png`
- `test/goldens/opportunity_detail_not_found.png`
- `test/goldens/opportunity_detail_error.png`
- `test/goldens/opportunity_detail_contacts_tab.png`
- `test/goldens/opportunity_detail_interactions_tab.png`
- `test/goldens/opportunity_detail_notes_tab.png`

---

## 7. Animation Mapping (Phase O5)

| Animation | Widget | Trigger | Core Piece |
|-----------|--------|---------|------------|
| Staggered entrance (list cards) | `OpportunitiesTabView` → `OpportunityCard` | First load only | `StaggeredListItem` (index × stagger, capped) |
| Count-up (summary row) | `OpportunitiesTabView` summary | Success state with `totalCount` | `AnimatedCounter` |
| Filter badge pop | Filter button badge | Filters changed | `TapScale` + `PulseWidget` |
| Search progress line | `ExpandableSearchField` | In-flight search | Built-in progress slot |
| Stage chip slide indicator | `AnimatedChipSelector` | Stage selection | Built-in |
| Status banner reveal (won) | `StatusBanner` | First display of won | `DrawnCheckmark` + `CustomPainter` burst (clipped) |
| Status banner reveal (lost) | `StatusBanner` | First display of lost | `ShakeWidget` → reveal |
| Status badge breathing dot (open) | `StatusBadge` (open) | Mounted | `IdleLoop` (pulse) |
| Probability ring sweep | `ProbabilityRing` | Mounted / value change | `ProgressDriver` + `ProgressRing` |
| Ring number count-up | `ProbabilityRing` | Mounted | `AnimatedCounter` |
| Stepper node fill/pop/pulse | `StageStepper` | Mounted / stage change | `StaggeredColumn` (nodes) + `PulseWidget` (current) |
| Stepper connector draw | `StageStepper` | Mounted | `ProgressDriver` + `CustomPainter` |
| Collapsing parallax header | `OpportunityDetailPage` | Scroll | `CollapsingHeader` (SliverAppBar + FlexibleSpaceBar) |
| Tab indicator slide | `OpportunityTabBar` | Tab change | `AnimatedChipSelector` sliding indicator |
| Badge count pop | `OpportunityTabBar` badges | Data load | `TapScale` |
| Tab content fade-through | `TabBarView` | Tab change | `AppAnimatedSwitcher` (fadeThrough) |
| Hero flight (card → detail) | `OpportunityCard` title+badge → `Detail` title+badge | Navigation | `AppHero` / `AppHeroTag` (NOT VERIFIED) |
| Skeleton cross-fade | All states | State change | `AppAnimatedSwitcher` |
| Press feedback | All buttons, cards, chips | Tap | `TapScale` |
| Load-more footer animate-in | `OpportunitiesTabView` footer | `isLoadingMore` true | `AnimatedVisibility` + `FadeIn` |
| Refresh notice slide | `OpportunityDetailPage` / `OpportunitiesTabView` | `refreshFailure` set | `AnimatedVisibility` + `SlideIn` |
| Log-it prompt slide | `LogItPrompt` | App resume + flag | `AppBottomSheet` motion |

**Reduce-Motion**: All honor `MediaQuery.disableAnimations` → static end state, no controllers.

---

## 8. Manual QA Script

### Device Setup
- Android: Pixel 6a (360×740, 3.0 density) + iPhone 14 Pro (393×852, 3.0 density)
- Text scale: 1.0 and 1.5 (Settings → Accessibility → Display size & text)
- Reduce motion: ON/OFF

### Test Cases

#### Tab View
1. **First load**: Open CRM → Opportunities tab → see skeleton → see cards
2. **Pull-to-refresh**: Pull down → spinner → data refreshes
3. **Search**: Type "ERP" → progress line appears → results filter
4. **Clear search**: Tap ✕ → results reset
5. **Stage filter**: Tap filter button → select "Qualified" → chip selected, list filters
6. **Status filter**: Tap filter button → select "Won" → badge count updates
7. **Clear filters**: Tap "Clear filters" → all chips reset, list unfiltered
8. **Load more**: Scroll to bottom → footer loads → more items append
9. **Load-more failure**: (Simulate timeout) → error row appears → tap Retry → loads
10. **Tap card**: Tap various points (corners, gaps, badge, date, ring) → navigates to detail
11. **Double-tap**: Rapid double-tap → single navigation
12. **Hero flight**: Card → detail → verify title+badge transition (NOT VERIFIED)
13. **Empty state**: Filter to no results → "No opportunities match your filters" + Clear filters
14. **Text scale 1.5**: Verify no overflow at 360dp width

#### Detail Page (Open Status)
1. **Load**: Tap card → skeleton → full page
2. **AppBar**: Back only, no actions, surface color, title appears on collapse
3. **Header**: Title (2 lines max), status badge (open=info, breathing dot), stage chip (neutral), value (prominent), expected close, no closed date
4. **Status banner**: None (open)
5. **Progress card**: Stage label + name, ring (72dp, primary, 35%), stepper (5 nodes, lead→qualified completed with checks, proposal current with ring, negotiation/closed outlined)
6. **Tab bar**: 4 tabs, sticky, counts from embedded data, horizontal scroll if needed
7. **Overview tab**: Customer card (avatar, name, company, code tag, phone/email/address/lead source rows with icons + tap actions), Details card (key-value: expected close, created, owner)
8. **Contacts tab**: Primary first with "Primary" badge, each card has Call/Email (hidden if missing), tap → launcher
9. **Interactions tab**: Add button → sheet, timeline with embedded interactions (newest first), edit/delete → helpers
10. **Notes tab**: Thread + composer (animated show/hide on tab switch)
11. **Phone tap**: Opens dialer → returns to app → "Log this call?" prompt → accept → add sheet with contact/type/date prefilled
12. **Email tap**: Opens mailto → returns → "Log this email?" prompt
13. **Launcher failure**: Airplane mode → tap phone → snackbar "Couldn't launch Phone. Try again later."
14. **Log-it once**: Launch → resume → prompt → dismiss → resume again → no prompt
15. **Silent refresh**: Trigger CRM change signal → thin progress bar → content stays → if fails, dismissible notice
16. **Reduce motion**: All animations static, no controllers
17. **Text scale 1.5**: No overflow

#### Detail Page (Won Status)
- Status banner: success tint, check icon, "Won" + "Closed on [date]"
- Stepper: all 5 completed (checks), closed node success tone
- Ring: success color, 100% (or server value)

#### Detail Page (Lost Status)
- Status banner: error tint, "Lost" + lost reason (or "No reason recorded")
- Stepper: closed node error tone with X
- Ring: error color, server probability

#### Not Found / Error
- Navigate to `/crm/opportunities/999999` → not-found state with back action
- Network error → full-screen error with retry

---

## 9. Risks & Unresolved Questions

### Risks
1. **Hero transition NOT VERIFIED** — needs real device; may have text style glitches during flight
2. **Platform URL launcher entries** — must add `<queries>` to AndroidManifest.xml and `LSApplicationQueriesSchemes` to Info.plist; easy to miss
3. **Log-it lifecycle** — depends on `WidgetsBindingObserver` + `UrlLauncherService` result; race conditions possible if app killed/restarted
4. **Embedded interaction mapping** — relies on `employeeName` from embedded data; verify backend includes it
5. **Stage stepper visual** — 5 equal slots at 360dp width may need `FittedBox` for labels; test at 1.5 text scale
5. **Count badges on tabs** — come from embedded `notes/interactions/contacts` arrays; verify backend includes counts or arrays

### Unresolved Questions
1. **Filter sheet "Clear all" action** — should it also clear search text? (Spec says status options only)
2. **Stage chips** — "All" default; does selecting "All" dispatch `FiltersChanged(stage: null)` or omit?
3. **Customer code tag** — in Overview card, show as chip or plain text? (Spec says "tag")
4. **Lead source** — nullable; show row only if non-null (spec says "only if applicable")
5. **Interaction contact options for add sheet** — from `customer.contacts`; what if empty? (Sheet should handle empty list)
6. **Probability ring at 100%** — server may send 100 for won; ring sweep = 1.0, color = success
7. **Overdue tag computation** — local only; uses `DateTime.now()` in widget (testable via clock override)

---

## 10. Phases & Gates (Recap)

### O1 Foundations
- [ ] `OpportunityLayoutConstants`
- [ ] `UrlLauncherServiceFake` + platform entries
- [ ] Pure mappers (`embedded_interaction_to_tile_data`, `contact_to_interaction_option`) + tests
- [ ] Load-more diagnosis confirmation (no state fix needed)
- **Gate**: All O1 tests pass, fake launcher works, platform entries added

### O2 Opportunities Tab
- [ ] `OpportunityCard`, `OpportunityCardSkeleton`
- [ ] `OpportunitiesTabView` (header: search, filter chips, summary, list)
- [ ] Filter bottom sheet (status single-select)
- [ ] Load-more footer with error row + Retry
- [ ] Skeletons, empty states, error states
- **Gate**: Layout goldens pass at 3 sizes × 2 text scales; whole-card tap test passes; load-more failure flow works

### O3 Detail Page Structure
- [ ] `OpportunityDetailPage` (Scaffold, SliverAppBar, header, status banner, progress card, tab bar)
- [ ] `StageStepper`, `ProbabilityRing` (72dp), `OpportunityTabBar`
- [ ] `OverviewTab` (CustomerCard, DetailsCard)
- [ ] `OpportunityDetailSkeleton`
- [ ] Not-found, error states
- **Gate**: Exactly one AppBar/back in all states; no title during load; probability/ring from fixture; owner name; conditional fields; tab switching + counts; layout goldens

### O4 Contacts/Interactions/Notes + Log-It
- [ ] `ContactsTab` (ContactCard, launcher abstraction, LogItPrompt)
- [ ] `InteractionsTab` (Add button, InteractionsTimeline, helpers)
- [ ] `NotesTab` (CustomerNotesThread + CustomerNoteComposer animated)
- [ ] Silent refresh + dismissible notice
- [ ] Log-it: successful launch + resume → prompt once → opens add sheet with context
- **Gate**: Launcher tests (success/failure/hidden buttons); log-it lifecycle test; mapping order; notes tab-scoped; silent refresh keeps content; layout goldens

### O5 Animations + Docs
- [ ] All animations from mapping table
- [ ] Reduce-motion test (disableAnimations = true)
- [ ] Disposal verification (controllers, subscriptions, observers)
- [ ] `FEATURE.md` updated, slang keys added, `docs/FEATURES_INDEX.md` row, `docs/CORE_MAP.md` if core changed
- [ ] Manual QA script executed
- **Gate**: Final widget tests, reduce-motion test, docs updated, QA script complete