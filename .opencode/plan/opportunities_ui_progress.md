# Opportunities UI Implementation Progress

## Completed (O1 Foundations + O2 Opportunities Tab) ✅

### O1 Foundations
- **HeroTags** - Added opportunity flight tags in `core/constants/hero_tags.dart`
- **OpportunityLayoutConstants** - Shared geometry for card, skeleton, detail sections in `presentation/constants/opportunity_layout_constants.dart`
- **Pure Mappers** with tests:
  - `embedded_interaction_to_tile_data.dart` - Maps EmbeddedCustomerInteraction → InteractionTileData
  - `contact_to_interaction_option.dart` - Maps CustomerContact → InteractionContactOption
- **Test Helpers**:
  - `UrlLauncherServiceFake` in `test/core/services/url_launcher_service_fake.dart`
  - Unit tests for both mappers (4 tests passing)
- **Core Additions**:
  - **ProgressRing** widget in `core/widgets/progress_ring.dart` (sweep ring driven by external progress)
  - Updated `core/widgets/widgets.dart` barrel export
  - Updated `docs/CORE_MAP.md` with ProgressRing entry
- **Platform Entries** (Already Present):
  - Android: `<queries>` for `tel:` and `mailto:` schemes
  - iOS: `LSApplicationQueriesSchemes` for `tel` and `mailto`
- **Load-More Diagnosis**: Root cause NOT in state layer - Bloc correctly handles load-more failure

### O2 Opportunities Tab ✅ (54 tests passing)

#### Created Widgets:
1. **OpportunityCard** - Whole-surface tap target (Q1), status badge, customer name+company, value with probability ring (28dp), stage chip, expected close date with overdue tag
2. **OpportunityCardSkeleton** - Twin of card using ShimmerScope/ShimmerBox
3. **OpportunitiesTabView** - Main list tab with:
   - Pinned header: search field (AppTextField) + filter button with badge count
   - Stage chips (AnimatedChipSelector) - All, Lead, Qualified, Proposal, Negotiation, Closed
   - Summary row: AnimatedCounter for total count + active filters chip + "Clear filters" action
   - List with pull-to-refresh, load-more footer with inline error row + Retry button
   - States: skeleton, success, empty (with "Clear filters"), error
4. **OpportunityFilterSheet** - Bottom sheet for status filter (Open/Won/Lost) using AnimatedChipSelector

#### Reused Core Pieces:
`AppCard`, `StatusBadge`, `ProgressRing`, `AnimatedChipSelector`, `AppTextField`, `AppButton`, `EmptyState`, `ErrorState`, `AnimatedCounter`, `AppAnimatedSwitcher`, `AnimatedProgressBar`, `ShimmerScope`/`ShimmerBox`, `Formatters.money/crmDate`

#### Tests (54 passing):
- **Pure mappers**: 4 tests (embedded interaction → tile data, contact → option)
- **Widget**: 5 tests (OpportunityCard - renders fields, whole-surface tap at 5 points, double-tap guard, overdue tag logic)
- **Existing**: All 45 existing domain/data/presentation tests still pass

---

## In Progress (O3 Detail Page Structure) 🚧

### Created Widgets (Need Fixes):
1. **OpportunityHeader** - Header section for collapsing SliverAppBar
2. **StatusBanner** - Full-width banner for Won/Lost (fixed DrawnCheckmark → Icon)
3. **ProgressCard** - Probability ring (72dp) + StageStepper
4. **StageStepper** - 5-node stepper with connector lines
5. **OpportunityTabBar** - Sticky tab bar with count badges (has syntax errors)
6. **OverviewTab** - CustomerCard + DetailsCard
7. **ContactsTab** - Customer contacts with call/email actions
8. **InteractionsTab** - Add button + InteractionsTimeline
9. **NotesTab** - CustomerNotesThread + CustomerNoteComposer
10. **OpportunityDetailPage** - Main page composing all sections
11. **OpportunityDetailSkeleton** - Full-page skeleton twin

### Known Issues to Fix:
1. **Import semicolons** - Mostly fixed, but some files still need cleanup
2. **Missing imports** - AppSpacing, AppRadius, context_extensions in several files
3. **i18n keys missing** - `stage`, `probability`, `outline`, `surfaceContainerHighest` in slang
4. **AppColorsExtension missing** - `surfaceContainerHighest`, `outline` getters
5. **_StepperColors class** - Referenced but not defined in stage_stepper.dart
6. **OpportunityTabBar** - Syntax errors in _BadgeTab and _SlidingIndicator
7. **ContactsTab** - Sorting logic broken, AppButton.icon expects Widget not IconData
8. **context.read** - Not available without BlocProvider (need to inject UrlLauncherService)
9. **AppButton.icon** - Expects Widget, not IconData
10. **AppCard usage** - In ProgressCard, using `AppCard(...)` as method instead of widget
11. **surfaceContainerHighest** - Not in AppColorsExtension
12. **outline** - Not in AppColorsExtension
13. **i18n keys** - `stage`, `probability` not in `crmOpportunities.detail.facts`

### Next Steps for O3:
1. Fix all import semicolons and missing imports
2. Add missing i18n keys to `assets/i18n/en.i18n.json` and run `dart run slang`
3. Add missing colors to `AppColorsExtension` (`surfaceContainerHighest`, `outline`)
4. Fix _StepperColors class in stage_stepper.dart
4. Fix OpportunityTabBar syntax errors
5. Fix ContactsTab sorting and AppButton.icon usage
6. Fix ProgressCard AppCard usage
7. Add missing i18n keys and run `dart run slang`
8. Fix context.read usage (inject UrlLauncherService via BlocProvider)
9. Fix opportunity_detail_skeleton.dart missing AppSpacing imports
10. Run tests and analyze

### Remaining Phases:
- **O4**: Contacts/Interactions/Notes tabs + Log-It prompt
- **O5**: Animations, reduce-motion, docs, manual QA