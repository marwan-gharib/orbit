# Skeletons: presentation state

Structure only. Replace `Product` with the real name. Anything marked `// ADAPT` must be copied
from the reference feature or `core/` (CORE-7): the exact API of `ApiResult`, `BaseApiClient`,
`Failure`, and the core widgets differs per project. Equality follows ARCH-9. Every key, path,
route, and asset is a constant (ARCH-10). Every file stays under 300 lines (FILE-1).

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

