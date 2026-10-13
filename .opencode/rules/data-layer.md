# Data Layer

## Networking

- DATA-1  HTTP goes only through `BaseApiClient` (abstract, in `core/network/`).
          `dio` may be imported only inside `core/network/` (the implementation and its
          interceptors) and by the `Dio` error classifier in `core/errors/`. A datasource,
          repository, usecase or widget never imports `dio` and never builds a `Dio`
          instance.
- DATA-2  Interceptors own auth-token attachment, logging, error mapping, refresh.
          Never duplicate that logic in a datasource or repository.
- DATA-3  Validate the request/response shape at the data-layer boundary (models parse
          defensively: required keys, expected types). A malformed response becomes a
          `Failure`, never a crash later in the UI.

## Models, mapping, repositories

- DATA-4  Models live in `data/models/`, hand-written `fromJson` / `toJson`, immutable.
          A model is never exposed outside the data layer.
- DATA-5  Model ↔ Entity conversion happens only in a `Mapper` class (`data/mappers/`).
          Entity → view model happens only in `presentation/mappers/`.
          Never convert inline inside a Cubit, a repository method, or a widget.
- DATA-6  `RepositoryImpl` implements the domain contract, calls datasources directly,
          and does only: orchestration, caching policy, mapping, error mapping. No UI types,
          no business rules.

## Pagination and caching

- DATA-7  Pagination: the repository method is stateless. It receives `page`/`cursor` and
          `pageSize` and returns a `PagedResult<T>` (items, `hasMore`, next page/cursor).
          The Cubit keeps the accumulated list and the next page/cursor, renders `hasMore`,
          and never computes offsets or builds query params itself.
- DATA-8  Caching policy (TTL, stale-while-revalidate, invalidation) lives only in the
          repository implementation, using the cache abstraction from `core/local/cache/`.
          The UI never caches data.
- DATA-9  Storage: tokens and sensitive values go through the secure-storage abstraction;
          everything else through the cache abstraction. Never use a storage package directly.
