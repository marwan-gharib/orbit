# Skeletons: route and DI

Structure only. Replace `Product` with the real name. Anything marked `// ADAPT` must be copied
from the reference feature or `core/` (CORE-7): the exact API of `ApiResult`, `BaseApiClient`,
`Failure`, and the core widgets differs per project. Equality follows ARCH-9. Every key, path,
route, and asset is a constant (ARCH-10). Every file stays under 300 lines (FILE-1).

## core/router: the route provides the Cubit (the only place besides core/di that calls getIt, DI-4)
```dart
// ADAPT: follow how the existing routes call `AppRoute.create` (ANIM-7, NAV-2).
AppRoute.create(
  name: RouteNames.productDetails,
  path: RoutePaths.productDetails,
  builder: (context, state) {
    // ADAPT: handle a missing id the way the project does (redirect or error page).
    final id = state.pathParameters[RoutePaths.productIdParam] ?? '';
    return BlocProvider(
      create: (_) => getIt<ProductDetailsCubit>()..load(id),
      child: const ProductDetailsScreen(),
    );
  },
),
```
Guards belong in `route_guards.dart` (NAV-5). Navigate with `context.goNamed(RouteNames.productDetails, ...)`.

## core/di/product_injection.dart
Read `lib/core/di/feature_module_registry.md` first (DI-1).
```dart
void registerProductDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => ProductRemoteDataSource(getIt()))
    ..registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetProductUseCase(getIt()))
    ..registerFactory(() => ProductDetailsCubit(getIt()));
}
```

Tests: see the `write-tests` skill for usecase, repository, cubit, and widget test skeletons.
