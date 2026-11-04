# Opportunities UI - Phase 1 & 2 Complete

## O1 Foundations (Done)

### Created Files:
1. **HeroTags** - Added opportunity flight tags in `core/constants/hero_tags.dart`
2. **OpportunityLayoutConstants** - Shared geometry for card, skeleton, detail sections in `presentation/constants/opportunity_layout_constants.dart`
3. **Pure Mappers**:
   - `embedded_interaction_to_tile_data.dart` - Maps EmbeddedCustomerInteraction → InteractionTileData
   - `contact_to_interaction_option.dart` - Maps CustomerContact → InteractionContactOption
4. **Test Helpers**:
   - `UrlLauncherServiceFake` in `test/core/services/url_launcher_service_fake.dart`
   - Unit tests for both mappers (4 tests passing)

### Core Additions:
- **ProgressRing** widget in `core/widgets/progress_ring.dart` (sweep ring driven by external progress)
- Updated `core/widgets/widgets.dart` barrel export
- Updated `docs/CORE_MAP.md` with ProgressRing entry

### Platform Entries (Already Present):
- Android: `<queries>` for `tel:` and `mailto:` schemes
- iOS: `LSApplicationQueriesSchemes` for `tel` and `mailto`

### Load-More Diagnosis:
- **Root cause NOT in state layer** - Bloc correctly handles load-more failure (keeps items, surfaces `loadMoreFailure`, resets `isLoadingMore`). No state-layer fix needed.

---

## O2 Opportunities Tab (Done)

### Created Widgets:
1. **OpportunityCard** - Whole-surface tap target (Q1), status badge, customer name+company, value with probability ring (28dp), stage chip, expected close date with overdue tag
2. **OpportunityCardSkeleton** - Twin of card using ShimmerScope/ShimmerBox
3. **OpportunitiesTabView** - Main list tab with:
   - Pinned header: search field (AppTextField) + filter button with badge count
   - Stage chips (AnimatedChipSelector) - All, Lead, Qualified, Proposal, Negotiation, Closed
   - Summary row: AnimatedCounter for total count + active filters chip + "Clear filters" action
   - List with pull-to-refresh, load-more footer with inline error row + Retry button
   - States: skeleton, success, empty (with "Clear filters"), error
4. **OpportunityFilterSheet** - Bottom sheet for status filter (Open/Won/Lost) using AnimatedChipSelector

### Reused Core Pieces:
- `AppCard`, `StatusBadge`, `ProgressRing`, `AnimatedChipSelector`, `AppTextField`, `AppButton`, `EmptyState`, `ErrorState`, `AnimatedCounter`, `AppAnimatedSwitcher`, `AnimatedProgressBar`, `ShimmerScope`/`ShimmerBox`, `Formatters.money/crmDate`

### Tests (54 passing):
- **Pure mappers**: 4 tests (embedded interaction → tile data, contact → option)
- **Widget**: 5 tests (OpportunityCard - renders fields, whole-surface tap at 5 points, double-tap guard, overdue tag logic)
- **Existing**: All 45 existing domain/data/presentation tests still pass

---

## Next: O3 Detail Page Structure

Ready to implement:
- OpportunityDetailPage (Scaffold + CustomScrollView + SliverAppBar)
- StatusBanner (won/lost only)
- ProgressCard with StageStepper (5 nodes) + ProbabilityRing (72dp)
- OpportunityTabBar (sticky, 4 tabs with count badges)
- OverviewTab (CustomerCard + DetailsCard)
- OpportunityDetailSkeleton (twin of full page)
- Not-found and error states