# Feature Module Registry

When you create a new feature (e.g. `lib/features/auth/`), register its DI module here in
`lib/core/di/injection_container.dart` following the `core_module.dart` pattern:

```dart
Future<void> initDependencies() async {
  await initCoreModule(getIt);
  await initAuthModule(getIt);   // <-- add your feature module here
}
```

Each feature module follows the same pattern: accept `GetIt`, register usecases as
`registerLazySingleton`, Cubits as `registerFactory`, repositories as `registerLazySingleton`.

Delete this note file once at least one feature module is registered and the pattern
is self-evident from the code.
