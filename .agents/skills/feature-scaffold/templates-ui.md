# Skeletons: UI from core

Structure only. Replace `Product` with the real name. Anything marked `// ADAPT` must be copied
from the reference feature or `core/` (CORE-7): the exact API of `ApiResult`, `BaseApiClient`,
`Failure`, and the core widgets differs per project. Equality follows ARCH-9. Every key, path,
route, and asset is a constant (ARCH-10). Every file stays under 300 lines (FILE-1).

Read `ui-from-core`, `ui-foundation.md`, `widgets.md`, `responsive.md`, `animations.md` first.
Every name below that is not in `docs/CORE_MAP.md` is a placeholder: verify it in the core file
before using it (CORE-7). No bare numbers (RESP-2), no raw animation (ANIM-2), no hardcoded text (UI-4).

## presentation/screens/product_details_screen.dart
```dart
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.product.details.title)), // ADAPT: slang accessor
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) => AppAnimatedSwitcher(
          // ADAPT: constructor from core/animations; one key per state type (ANIM-4).
          child: switch (state) {
            ProductDetailsLoading() => const ProductDetailsSkeleton(key: ValueKey('loading')),
            ProductDetailsSuccess(:final product) =>
              ProductDetailsView(key: const ValueKey('content'), product: product),
            ProductDetailsError(:final failure) => ErrorState(
                key: const ValueKey('error'),
                message: context.failureText(failure), // ERR-4
                // ADAPT: ErrorState retry parameter name
                onRetry: () => context.read<ProductDetailsCubit>().retry(),
              ),
          },
        ),
      ),
    );
  }
}
```
The `ValueKey`s are widget identity keys for the switcher (one per state type), not data keys.
A LIST screen adds an `Empty` state rendered with `EmptyState` (STATE-5).

## presentation/widgets/product_details_view.dart (built from core pieces)
```dart
class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({super.key, required this.product});
  final ProductViewModel product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md), // ADAPT: token name and how it is read
      children: [
        AppCard(
          // ADAPT: AppCard parameters
          child: Text(product.name, style: context.textStyles.titleLarge),
        ).fadeSlideIn(), // facade from core/animations (ANIM-1)
        SizedBox(height: AppSpacing.sm),
        StatusBadge(label: product.priceLabel), // ADAPT: StatusBadge parameters
      ],
    );
  }
}
```

## presentation/widgets/product_details_skeleton.dart (loading placeholder)
```dart
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // ADAPT: ShimmerScope and the skeleton pieces from core/animations (ANIM-4).
    return const ShimmerScope(child: SizedBox.shrink());
  }
}
```

## A feature-only widget (only when core has none, WIDGET-2)
One public widget per file in `presentation/widgets/`. Data in through the constructor, events out
through callbacks, no Cubit, no `getIt`. Add its name and one line to `FEATURE.md` section 3. When a
second feature needs it, promote it with `/promote-widget` (WIDGET-3).
