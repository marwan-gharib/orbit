---
name: write-tests
description: Write unit, repository, Cubit/Bloc, and widget tests for this Flutter project using its existing test tooling (typically mocktail and bloc_test), with correct mocking boundaries, regression-test-first bug fixing, and test naming. Use when adding or changing behavior, fixing a bug, or when asked for tests or coverage.
---

# Write Tests

Rules: `.opencode/rules/testing.md` (TEST-1..7). This skill gives patterns.
Check `pubspec.yaml` `dev_dependencies` first and use only what is there (TEST-6).
Run only affected tests: `flutter test test/features/<feature>`.

## When to use
New behavior, changed behavior, bug fix (regression test first), "add tests", missing coverage on a touched file.

## Rules of thumb
- One behavior per test. Name: `should <expected> when <condition>`.
- Arrange / Act / Assert. No loops or branches inside a test.
- Mock only the boundary directly below the unit (TEST-4). `test/` mirrors `lib/` (TEST-5).
- No real network, storage, time, or randomness. Inject fakes and clocks.
- Cover: success, failure, empty, edge values (null, zero, max, malformed payload).
- Assert behavior and state, not implementation details.

## Bug fix flow (TEST-2)
1. Write a test that reproduces the bug. Run it. Confirm it FAILS for the right reason.
2. Apply the smallest fix.
3. Run it again. It passes. Run the rest of the feature's tests.

## Usecase test
A usecase is a plain class (DOM-1): mock the repository contract and call the usecase like a function.
```dart
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late GetProductUseCase useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProductUseCase(repository);
  });

  test('should return the product when the repository succeeds', () async {
    when(() => repository.getProduct('1'))
        .thenAnswer((_) async => ApiResult.success(tProduct)); // ADAPT constructor

    final result = await useCase('1');

    expect(result, ApiResult.success(tProduct)); // or inspect via fold
    verify(() => repository.getProduct('1')).called(1);
  });
}
```

## Repository impl test
Mock the datasource (and cache abstraction). Assert: success maps model to entity, each
exception type maps to the right `Failure`, cache hit or miss behavior, pagination
(`hasMore`, next page).

## Model and view-mapper tests
Model: `fromJson` with a valid payload, a missing key, a wrong type (must fail as designed),
`toJson` round trip, and `toEntity()` field by field. Build payloads with the production
constants (`ApiKeys.*`, TEST-7); literals only for values. View mapper
(`presentation/mappers/`): field-by-field mapping.

## Cubit test (bloc_test)
```dart
class MockGetProductUseCase extends Mock implements GetProductUseCase {}

void main() {
  late MockGetProductUseCase getProduct;

  setUp(() => getProduct = MockGetProductUseCase());

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'should emit [loading, success] when the usecase succeeds',
    build: () {
      when(() => getProduct(any())).thenAnswer((_) async => ApiResult.success(tProduct));
      return ProductDetailsCubit(getProduct);
    },
    act: (cubit) => cubit.load('1'),
    expect: () => [isA<ProductDetailsLoading>(), isA<ProductDetailsSuccess>()],
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'should emit [loading, error] when the usecase fails',
    build: () {
      when(() => getProduct(any())).thenAnswer((_) async => ApiResult.failure(tFailure));
      return ProductDetailsCubit(getProduct);
    },
    act: (cubit) => cubit.load('1'),
    expect: () => [isA<ProductDetailsLoading>(), isA<ProductDetailsError>()],
  );
}
```
When a usecase takes a `Params` object or a custom type, call `registerFallbackValue(...)`
once in `setUpAll` so `any()` works.

## Widget test
```dart
class MockProductDetailsCubit extends MockCubit<ProductDetailsState>
    implements ProductDetailsCubit {}

testWidgets('should show the product name when state is success', (tester) async {
  final cubit = MockProductDetailsCubit();
  when(() => cubit.state).thenReturn(ProductDetailsSuccess(tProductViewModel));

  await tester.pumpWidget(
    // ADAPT: wrap with the project's test app (theme extension + slang TranslationProvider).
    pumpApp(BlocProvider<ProductDetailsCubit>.value(value: cubit, child: const ProductDetailsScreen())),
  );

  expect(find.text(tProductViewModel.name), findsOneWidget);
});
```
Wrap every UI test in `ResponsiveScope` (inside the project's test app), pump at least two
surface sizes (small phone, tablet) and one large text scale, and assert no overflow exception
(TEST-8, RESP-6). Test each screen in loading, success, empty, error. Also test one interaction per important
control (tap, submit) and verify the Cubit method was called.

## Coverage check
List the new or changed behaviors, then map each to a test name. Anything unmapped is missing a test.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
