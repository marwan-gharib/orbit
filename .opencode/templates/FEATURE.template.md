# <Feature Name>

> Last verified: YYYY-MM-DD
> Path: `lib/features/<feature>/`

## 1. Purpose
<2–3 lines: what the feature does for the user and why it exists.>

## 2. Screens & routes
| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|

## 3. File map
| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | screens/…, cubits/…/…, view_models/…, mappers/… | |
| presentation widgets | widgets/<name>.dart: one line each (feature-only widgets core lacks; promote when a 2nd feature needs one, WIDGET-3) | |
| domain | entities/…, repositories/…, usecases/…, params/… | |
| data | datasources/remote/…, datasources/local/…, models/…, repositories/… | |

## 4. Entities & models
| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|

## 5. Use cases
| UseCase | Input | Output | Business rule (if any) |
|---------|-------|--------|------------------------|

## 6. API & storage
| Endpoint / key (constant name, e.g. `Endpoints.product`) | Method | Used by (datasource method) | Cache policy |
|----------------------------------------------------------|--------|-----------------------------|--------------|

## 7. State
- Cubit/Bloc: `<Name>` — Cubit | Bloc (reason: <one line>)
- States: `Initial`, `Loading`, `Success(<data>)`, `Empty`, `Error(<Failure>)`, <one-off effects>
- Transitions: <method/event> → <states>
- Pagination: <page/cursor model, page size, or "none">

## 8. Dependencies
- Depends on (core): <items from docs/CORE_MAP.md>
- Depends on (features): <feature → what is used>
- Used by (features): <feature → how>
- DI file: `core/di/<feature>_injection.dart`

## 9. Localization
- Namespace: `context.t.<feature>.*`
- Keys: <list or "see assets/i18n/*.json under <feature>">

## 10. Business rules & edge cases
- <non-obvious rule and why>

## 11. Tests
| Area | Test files | Covered behaviors |
|------|------------|-------------------|

## 12. Known issues / TODO
- <item or "none">

## 13. Changelog
- YYYY-MM-DD — <what changed and why>
