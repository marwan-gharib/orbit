# Skeletons (structure only)

Replace `Product` with the real name. Anything marked `// ADAPT` must be copied from the
reference feature or `core/`; the exact API of `ApiResult`, `BaseApiClient`, `Failure` and the
shared widgets differs per project. Equality follows ARCH-9 (use `Equatable` only if it is
already in `pubspec.yaml`, otherwise implement `==` / `hashCode`).

Every key, path, route, and asset is a constant from `core/constants/` (ARCH-10). A string
literal may be written only inside those constants files.

## core/constants/api_keys.dart
```dart
abstract final class ApiKeys {
  static const String productId = 'id';
  static const String productName = 'name';
  static const String productPriceCents = 'price_cents';
}
```

## core/constants/endpoints.dart
```dart
abstract final class Endpoints {
  static const String products = '/products';
  static String product(String id) => '$products/$id';
}
```

## core/constants/app_routes.dart
```dart
abstract final class AppRoutes {
  static const String productDetailsName = 'product-details';
  static const String productDetailsPath = '/products/:id';
  static const String productIdParam = 'id';
}
```

## domain/entities/product_entity.dart
```dart
class ProductEntity {
  const ProductEntity({required this.id, required this.name, required this.priceCents});

  final String id;
  final String name;
  final int priceCents;

  @override
  bool operator ==(Object other) =>
      other is ProductEntity &&
      other.id == id &&
      other.name == name &&
      other.priceCents == priceCents;

  @override
  int get hashCode => Object.hash(id, name, priceCents);
}
```

## domain/repositories/product_repository.dart
```dart
abstract class ProductRepository {
  Future<ApiResult<PagedResult<ProductEntity>>> getProducts({required int page, required int pageSize});
  Future<ApiResult<ProductEntity>> getProduct(String id);
}
```

## domain/usecases (plain classes: one `call`, no base class, DOM-1)
```dart
// domain/usecases/get_product_usecase.dart  (one primitive input, passed directly)
class GetProductUseCase {
  const GetProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ApiResult<ProductEntity>> call(String id) => _repository.getProduct(id);
}

// domain/usecases/get_products_usecase.dart  (several inputs: one Params object)
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<ApiResult<PagedResult<ProductEntity>>> call(GetProductsParams params) =>
      _repository.getProducts(page: params.page, pageSize: params.pageSize);
}

// domain/usecases/get_session_usecase.dart  (no input: call() takes nothing)
class GetSessionUseCase {
  const GetSessionUseCase(this._repository);
  final SessionRepository _repository;

  Future<ApiResult<UserEntity>> call() => _repository.getSession();
}
```

## domain/params/get_products_params.dart (more than one input)
```dart
class GetProductsParams {
  const GetProductsParams({required this.page, required this.pageSize});
  final int page;
  final int pageSize;
}
```

## data/models/product_model.dart
```dart
class ProductModel {
  const ProductModel({required this.id, required this.name, required this.priceCents});

  final String id;
  final String name;
  final int priceCents;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing (DATA-3): a wrong shape becomes a Failure upstream, not a late crash.
    final id = json[ApiKeys.productId];
    final name = json[ApiKeys.productName];
    final priceCents = json[ApiKeys.productPriceCents];
    if (id is! String || name is! String || priceCents is! int) {
      throw const FormatException();
    }
    return ProductModel(id: id, name: name, priceCents: priceCents);
  }

  Map<String, dynamic> toJson() => {
        ApiKeys.productId: id,
        ApiKeys.productName: name,
        ApiKeys.productPriceCents: priceCents,
      };

  ProductEntity toEntity() => ProductEntity(id: id, name: name, priceCents: priceCents);
}
```

## data/datasources/remote/product_remote_data_source.dart
```dart
class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client); // BaseApiClient, never Dio
  final BaseApiClient _client;

  Future<ProductModel> getProduct(String id) async {
    // ADAPT: call the client exactly as the reference feature does
    // (method names, response handling). The path always comes from `Endpoints`.
    final json = await _client.get(Endpoints.product(id));
    return ProductModel.fromJson(json as Map<String, dynamic>);
  }
}
```

## data/repositories/product_repository_impl.dart
```dart
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);
  final ProductRemoteDataSource _remote;

  @override
  Future<ApiResult<ProductEntity>> getProduct(String id) async {
    try {
      final model = await _remote.getProduct(id);
      return ApiResult.success(model.toEntity()); // ADAPT constructor
    } on Object catch (e, st) {
      return ApiResult.failure(mapToFailure(e, st)); // ADAPT: use the existing error mapper
    }
  }
}
```

## presentation/view_models/product_view_model.dart and presentation/mappers/product_view_mapper.dart
```dart
class ProductViewModel {
  const ProductViewModel({required this.id, required this.name, required this.priceLabel});

  final String id;
  final String name;
  final String priceLabel;

  @override
  bool operator ==(Object other) =>
      other is ProductViewModel &&
      other.id == id &&
      other.name == name &&
      other.priceLabel == priceLabel;

  @override
  int get hashCode => Object.hash(id, name, priceLabel);
}

abstract final class ProductViewMapper {
  static ProductViewModel fromEntity(ProductEntity entity) => ProductViewModel(
        id: entity.id,
        name: entity.name,
        priceLabel: formatPrice(entity.priceCents), // ADAPT: the project's formatter in core/helpers
      );
}
```

## presentation/cubits/product_details/product_details_state.dart
Detail screens need Loading, Success, Error. A LIST screen also needs an `Empty` state
(STATE-5). States that carry data need value equality (STATE-8, ARCH-9).
```dart
sealed class ProductDetailsState {
  const ProductDetailsState();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsSuccess extends ProductDetailsState {
  const ProductDetailsSuccess(this.product);
  final ProductViewModel product;

  @override
  bool operator ==(Object other) => other is ProductDetailsSuccess && other.product == product;

  @override
  int get hashCode => product.hashCode;
}

final class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) => other is ProductDetailsError && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
```

## presentation/cubits/product_details/product_details_cubit.dart
```dart
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._getProduct) : super(const ProductDetailsLoading());
  final GetProductUseCase _getProduct;

  Future<void> load(String id) async {
    emit(const ProductDetailsLoading());
    final result = await _getProduct(id);
    if (isClosed) return; // STATE-6
    // ADAPT: use ApiResult.fold with your project's signature.
    result.fold(
      onSuccess: (entity) => emit(ProductDetailsSuccess(ProductViewMapper.fromEntity(entity))),
      onFailure: (failure) => emit(ProductDetailsError(failure)),
    );
  }
}
```

## presentation/screens/product_details_screen.dart
```dart
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ADAPT: use the shared widgets from core/widgets/ and the Failure -> text extension (ERR-4).
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) => switch (state) {
        ProductDetailsLoading() => const AppLoader(),
        ProductDetailsSuccess(:final product) => ProductDetailsView(product: product),
        ProductDetailsError(:final failure) => ErrorView(message: failure.localized(context)),
      },
    );
  }
}
```

## core/router: the route provides the Cubit (the only place besides core/di that calls getIt, DI-4)
```dart
GoRoute(
  name: AppRoutes.productDetailsName,
  path: AppRoutes.productDetailsPath,
  builder: (context, state) {
    // ADAPT: handle a missing id the way the project does (redirect or error page).
    final id = state.pathParameters[AppRoutes.productIdParam] ?? '';
    return BlocProvider(
      create: (_) => getIt<ProductDetailsCubit>()..load(id),
      child: const ProductDetailsScreen(),
    );
  },
),
```

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
