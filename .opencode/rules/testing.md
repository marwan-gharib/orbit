# Testing

- TEST-1  No feature or behavior change is done without tests:
          - domain: usecase tests;
          - data: repository impl, datasource, and model tests (`fromJson`, `toJson`, `toEntity()`);
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
- TEST-7  Test code uses the same constants as production for JSON keys, endpoint paths, and
          storage keys (`ApiKeys`, `Endpoints`, ...). Literals are allowed only for test VALUES
          (names, ids, amounts).
- TEST-8  UI tests: every widget or screen test pumps through the project's shared test app helper
          (search `test/` first; create one helper only if none exists) so `ResponsiveScope`, the
          theme with its extensions, and the slang provider are present (RESP-5). Screen tests
          cover loading, success, empty, and error at a small-phone size and a tablet size and at
          a large text scale (RESP-6, UI-6). Animated widgets are tested with animations disabled or
          settled (`pumpAndSettle`), never with real delays.
