# Skeletons (structure only)

Replace `Product` with the real name. Anything marked `// ADAPT` must be copied from the
reference feature or `core/`; the exact API of `ApiResult`, `UseCase`, `BaseApiClient`
and `Failure` differs per project. Equality follows ARCH-9 (use `Equatable` only if it is
already in `pubspec.yaml`, otherwise implement `==` / `hashCode`).

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

## domain/usecases/get_product_usecase.dart
```dart
class GetProductUseCase {
  const GetProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ApiResult<ProductEntity>> call(String id) => _repository.getProduct(id);
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
  const ProductModel({
    required this.id,
    required this.name,
    required this.priceCents,
  });

  final String id;
  final String name;
  final int priceCents;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id']).toString(),
      name: (json['name']).toString(),
      priceCents: int.parse((json['price_cents']).toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price_cents': priceCents,
  };

  toEntity() => ProductEntity(id: id, name: name, priceCents: priceCents);
}
```

## data/datasources/remote/product_remote_data_source.dart
```dart
class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client); // BaseApiClient, never Dio
  final BaseApiClient _client;

  Future<ProductModel> getProduct(String id) async {
    // ADAPT: call the client exactly as the reference feature does
    // (method names, endpoint constants, response handling).
    final json = await _client.get('endpoint from endpoints class in core/constants');
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
      return ApiResult.success(ProductMapper.toEntity(model)); // ADAPT constructor
    } on Object catch (e, st) {
      return ApiResult.failure(mapToFailure(e, st)); // ADAPT: use the existing error mapper
    }
  }
}
```

## presentation/cubits/product_details/product_details_state.dart
Detail screens need Loading, Success, Error. A LIST screen also needs an `Empty` state
(STATE-5). States that carry data (`Success`, `Error`) need value equality (STATE-8, ARCH-9):
implement `==` / `hashCode` like the entity above, or use `Equatable` if already in `pubspec.yaml`.
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
}

final class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.failure);
  final Failure failure;
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
The Cubit is provided at route level: `BlocProvider(create: (_) => getIt<ProductDetailsCubit>()..load(id), child: ...)`
inside `core/router/` only (DI-3).

## core/di/product_injection.dart
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
