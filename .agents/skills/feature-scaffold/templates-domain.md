# Skeletons: constants and domain

Structure only. Replace `Product` with the real name. Anything marked `// ADAPT` must be copied
from the reference feature or `core/` (CORE-7): the exact API of `ApiResult`, `BaseApiClient`,
`Failure`, and the core widgets differs per project. Equality follows ARCH-9. Every key, path,
route, and asset is a constant (ARCH-10). Every file stays under 300 lines (FILE-1).

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

## core/router/route_names.dart and route_paths.dart (the only places route literals may live, ARCH-10)
```dart
// ADAPT: follow the classes and naming already used in these two files.
abstract final class RouteNames {
  static const String productDetails = 'product-details';
}

abstract final class RoutePaths {
  static const String productDetails = '/products/:id';
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

