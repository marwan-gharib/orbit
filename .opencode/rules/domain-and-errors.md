# Domain & Error Handling

## Domain rules

- DOM-1  A usecase is a plain concrete class with ONE public method, `call(...)`, that returns
         `Future<ApiResult<T>>`. There is NO base class and NO abstract usecase interface: no
         `UseCase<Output, Input>`, no `UseCaseWithoutParams`, no `NoParams`. A usecase
         `extends` / `implements` nothing. The Cubit calls it like a function: `await _getProduct(id)`.
- DOM-2  Every usecase file/class ends in `UseCase` (`login_usecase.dart` → `LoginUseCase`).
         Never a variant spelling.
- DOM-3  Input rules:
         - More than one primitive input → ONE `*Params` class in `domain/params/`.
         - Exactly one primitive/id input → may be passed directly.
         - No input → `call()` takes no parameters; never force a dummy Params object such as `NoParams()`.
- DOM-4  Usecases return `ApiResult<T>` only. No nullable returns, no raw exceptions,
         no `void` that hides failure.
- DOM-5  Repository contracts live in `domain/repositories/`, are `abstract` and
         return `ApiResult<Entity>` (or `ApiResult<List<Entity>>`, `ApiResult<PagedResult<Entity>>`).
- DOM-6  Entities are pure Dart: no JSON methods, no Flutter imports, no framework types.
         A usecase holds business rules; it does not format strings for the UI.

## Error handling rules

- ERR-1  `ApiResult<T>` is the only result type crossing layer boundaries.
- ERR-2  Exceptions are caught in the data layer and mapped to a `Failure` subtype.
         Follow the existing mechanism (API client implementation + an existing
         `RepositoryImpl`). Do not invent a second error-mapping approach.
         New `Failure` subtypes are added only in `core/errors/`.
- ERR-3  Consume results with `fold()`, never by unwrapping. The domain layer propagates
         `ApiResult` unchanged. The Cubit maps it to a state; widgets never see raw exceptions.
- ERR-4  A `Failure` becomes user text through ONE shared mapping: `context.failureText(failure)`
         (extension in `core/extensions/`, localized via slang). Never show `failure.toString()`
         or `exception.message` to the user, never build error strings inline in a Cubit.
- ERR-5  Global concerns (401 → refresh/logout, offline detection, retry, logging) live in
         core interceptors/services. A feature never re-implements them.
