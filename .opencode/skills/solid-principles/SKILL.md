---
name: solid-principles
description: Apply and check the SOLID principles in Flutter/Dart class design - single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion - mapped to this project's Clean Architecture. Use when designing a new class, when a class grows large or hard to test, or when reviewing design quality.
---

# SOLID Principles (applied to this architecture)

Goal: solve a present design problem, not to add abstractions "just in case" (YAGNI).
If a class has one implementation and is not at a layer boundary, it needs no interface.

## When to use
Designing a new Cubit, usecase, repository, widget, or core service; a class passing
about 200 lines; a class that is hard to unit test; design review.

## Principle map

| Principle | Meaning | Where it shows up here |
|---|---|---|
| **S**ingle Responsibility | One reason to change | Usecase = one business operation (a plain class with `call()`, no base class). Cubit = state orchestration only. `toEntity()` or a view-model mapper = one conversion. `RepositoryImpl` = orchestration, caching, mapping, error mapping. Widget = layout. |
| **O**pen/Closed | Add behavior by adding code, not editing stable code | New payment method or filter = new strategy class registered in one place, not another branch in 6 switches. |
| **L**iskov Substitution | Any implementation honors the contract | A `RepositoryImpl` returns `ApiResult` per the contract and never throws. A fake in tests behaves like the real one. |
| **I**nterface Segregation | Small, focused contracts | One repository contract per aggregate. Widgets take a view model or primitives, not a whole state or entity. |
| **D**ependency Inversion | Depend on abstractions at boundaries | Cubit -> usecases. Usecase -> repository contract. `core/` -> `BaseApiClient` and storage abstractions. Everything constructor-injected (DI-4). |

## Violation signals and fixes

**SRP**
- Signals: class name contains `And` / `Manager` / `Helper`; imports span 3 or more layers;
  a Cubit that formats strings, validates forms, or builds requests.
- Fix: move formatting to a presentation mapper or an extension, validation to a usecase or validator, request building to the datasource.

**OCP**
- Signals: the same `switch` on a type or enum repeated in several files; every new variant edits many files.
- Fix: the Strategy pattern (one strategy interface plus implementations) or a `sealed` hierarchy with the behavior on the variants.
- Note: a `sealed` class with exhaustive `switch` is closed on purpose (STATE-3). The compiler tells you every place to update. That is fine for UI states.

**LSP**
- Signals: `throw UnimplementedError()`, an override that ignores a parameter, callers doing `is` checks on the implementation.
- Fix: narrow the contract or split it so every implementer can honor all of it.

**ISP**
- Signals: implementers with empty methods; a contract with 10+ unrelated methods.
- Fix: split by use case or aggregate.

**DIP**
- Signals: a Cubit constructing its own repository; `getIt<T>()` inside a class (DI-4); a domain class importing `data/` or a package.
- Fix: accept the abstraction through the constructor.
- Project exception: datasources have no interface on purpose (ARCH-6). The abstraction boundary is the repository contract. Do not add interfaces to datasources.

## Over-engineering guard
Before adding an abstraction ask: (1) Is there a second implementation or a test seam
that needs it? (2) Is it at a layer boundary? If both answers are no, do not add it.

## Process
1. List each new or changed class and state its single responsibility in one sentence. If you need "and", split it.
2. Check its constructor: every dependency is an abstraction at a boundary or a concrete in-layer class.
3. Check every override for contract fidelity.
4. Record notable design decisions in the feature's `FEATURE.md` (State section or Business rules).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
