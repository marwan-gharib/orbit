---
name: add-endpoint
description: Add a new API endpoint or remote call to an existing feature through every layer - datasource, model, mapper, repository contract and impl, usecase, Cubit hook, tests, and docs - without breaking layer rules. Use when a feature needs a new request such as fetch, create, update, delete, search, or pagination.
---

# Add Endpoint to an Existing Feature

Read first: `docs/FEATURES_INDEX.md`, the feature's `FEATURE.md`, then only the datasource
and repository files you will edit. Load `data-layer`, `domain-and-errors`, `testing`,
`feature-docs` rule files.

## When to use
A feature needs one more API call. For a whole new feature use `feature-scaffold`.

## Steps (in order)

1. **Contract the call.** Write down: method, path, query/body, success payload, error cases
   (4xx and 5xx that matter), auth needed, pagination style.
2. **Domain.**
   - Add entity fields or a new entity if the business concept changed.
   - Add a method to the repository contract returning `ApiResult<...>` (DOM-5).
   - Add a usecase. More than one input means a `Params` class (DOM-3). No input means
     `UseCaseWithoutParams`.
3. **Data.**
   - Add or extend the model with hand-written `fromJson` / `toJson` and defensive parsing (DATA-3, DATA-4).
   - Add or extend the mapper (DATA-5).
   - Add the datasource method. It uses `BaseApiClient` only (DATA-1). Endpoint paths come
     from the existing constants file.
   - Implement the repository method. Catch exceptions and map to a `Failure` with the existing mechanism (ERR-2).
     Apply caching policy here only if needed (DATA-8).
   - Pagination: stateless repository method taking `page`/`cursor`, returning `PagedResult` (DATA-7).
4. **Presentation.** Add a Cubit method that calls the usecase and emits a state
   (STATE-2, STATE-5). Add a state only when the UI needs one. Check `isClosed` after `await` (STATE-6).
5. **DI.** Register the new usecase in `core/di/<feature>_injection.dart` (DI-2).
6. **Tests.** Model parsing (valid, missing key, wrong type), mapper, datasource if it has logic,
   repository (success plus every mapped failure), usecase, Cubit transitions. Use the `write-tests` skill.
7. **Docs.** Update `FEATURE.md` sections 4, 5, 6, 7, 11 and the changelog (use the `feature-doc` skill).
8. **Verify.** Definition of Done (CORE-24..31).

## Pitfalls checklist
- [ ] Datasource does not import `dio` or catch exceptions it cannot handle.
- [ ] Model is not exposed beyond the data layer.
- [ ] Failure types distinguish: no connection, timeout, unauthorized, not found, server, malformed response.
- [ ] No endpoint URL, header, or token handling duplicated outside `core/network`.
- [ ] Sensitive data is not logged (see `security-review`).
- [ ] The Cubit handles the new failure cases with a localized message (ERR-4).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
