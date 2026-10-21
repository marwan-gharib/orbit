---
name: add-endpoint
description: Add a new API endpoint or remote call to an existing feature through every layer - constants, datasource, model with toEntity, repository contract and impl, usecase, Cubit hook, tests, and docs - without breaking layer rules. Use when a feature needs a new request such as fetch, create, update, delete, search, or pagination.
---

# Add Endpoint to an Existing Feature

Read first: `docs/FEATURES_INDEX.md`, the feature's `FEATURE.md`, then only the datasource
and repository files you will edit. Load `data-layer`, `domain-and-errors`, `architecture`
(ARCH-10), `testing`, `feature-docs` rule files.

## When to use
A feature needs one more API call. For a whole new feature use `feature-scaffold`.

## Steps (in order)

1. **Contract the call.** Write down: method, path, query/body/header names, JSON field names of
   the request and the response, success payload, error cases (4xx and 5xx that matter), auth
   needed, pagination style.
2. **Constants first (ARCH-10).** Add the endpoint path and every key from step 1 to
   `core/constants/` BEFORE writing any other code. Reuse existing constants; create a new file
   there only if no existing file fits. A string literal as a key or path is never allowed
   anywhere else.
3. **Domain.**
   - Add entity fields or a new entity if the business concept changed.
   - Add a method to the repository contract returning `ApiResult<...>` (DOM-5).
   - Add a usecase: a plain class with a `call(...)` method and no base class (DOM-1). More than
     one input means a `Params` class (DOM-3). No input means `call()` takes no parameters.
4. **Data.**
   - Add or extend the model: hand-written `fromJson` / `toJson` / `toEntity()`, defensive
     parsing, keys from `ApiKeys` (DATA-3, DATA-4).
   - Add the datasource method. It uses `BaseApiClient` only (DATA-1) and the path from `Endpoints`.
   - Implement the repository method: call the datasource, convert with `model.toEntity()`
     (DATA-5), catch exceptions and map to a `Failure` with the existing mechanism (ERR-2).
     Apply caching policy here only if needed (DATA-8).
   - Pagination: stateless repository method taking `page`/`cursor`, returning `PagedResult` (DATA-7).
5. **Presentation.** Add a Cubit method that calls the usecase and emits a state
   (STATE-2, STATE-5). Add a state only when the UI needs one. Check `isClosed` after `await` (STATE-6).
6. **DI.** Register the new usecase in `core/di/<feature>_injection.dart` (DI-3). Read
   `lib/core/di/feature_module_registry.md` first (DI-1).
7. **Tests.** Model parsing (valid, missing key, wrong type) and `toEntity()`, datasource if it has
   logic, repository (success plus every mapped failure), usecase, Cubit transitions. Use the
   `write-tests` skill.
8. **Docs and note.** Update `testers_release_note.txt` if a tester can see the effect (`tester-release-notes` skill).
   **Docs.** Update `FEATURE.md` sections 4, 5, 6, 7, 11 and the changelog (use the `feature-doc`
   skill). Add new constants to `docs/CORE_MAP.md` if a new constants file was created.
9. **Verify.** Definition of Done (CORE-24..33).

## Pitfalls checklist
- [ ] No string literal for a path, key, header, or query name anywhere outside `core/constants/` (ARCH-10).
- [ ] Datasource does not import `dio` or catch exceptions it cannot handle.
- [ ] Model is not exposed beyond the data layer.
- [ ] Failure types distinguish: no connection, timeout, unauthorized, not found, server, malformed response.
- [ ] No endpoint URL, header, or token handling duplicated outside `core/network`.
- [ ] Sensitive data is not logged (see `security-review`).
- [ ] The Cubit handles the new failure cases with a localized message (ERR-4).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
