# Skeletons: data layer

Structure only. Replace `Product` with the real name. Anything marked `// ADAPT` must be copied
from the reference feature or `core/` (CORE-7): the exact API of `ApiResult`, `BaseApiClient`,
`Failure`, and the core widgets differs per project. Equality follows ARCH-9. Every key, path,
route, and asset is a constant (ARCH-10). Every file stays under 300 lines (FILE-1).

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

