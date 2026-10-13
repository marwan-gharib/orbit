# Testing

- TEST-1  No feature or behavior change is done without tests:
          - domain: usecase tests;
          - data: repository impl, datasource, mapper, and model parsing tests;
          - presentation: Cubit/Bloc tests (every state transition, including error and empty)
            and widget tests for each screen (loading, success, empty, error);
          - core: tests for any new shared util/widget.
- TEST-2  A bug fix ships with a regression test that fails before the fix and passes after.
          Write the failing test first.
- TEST-3  One behavior per test. Name tests `should <expected> when <condition>`.
          Arrange / Act / Assert, no logic (loops, branches) inside tests.
- TEST-4  Mock only at the boundary directly below the unit under test:
          - usecase test → mock the repository contract;
          - repository impl test → mock datasources and the cache abstraction;
          - Cubit test → mock usecases;
          - widget test → provide a mock Cubit through `BlocProvider.value`.
- TEST-5  `test/` mirrors `lib/` exactly (`lib/features/x/domain/usecases/a_usecase.dart` →
          `test/features/x/domain/usecases/a_usecase_test.dart`). Tests never hit the network,
          real storage, or real time; inject fakes/clocks.
- TEST-6  Use the test tooling already in `dev_dependencies` (check `pubspec.yaml`; typically
          `mocktail` and `bloc_test`). Never add a test package. Run only the affected tests:
          `flutter test test/features/<feature>`.
