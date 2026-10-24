# State Management (Cubit / Bloc)

- STATE-1  Default to **Cubit** for "call a usecase → emit a state" flows.
           Use **Bloc** only when the flow needs event transformation:
           - debounce/throttle on user input (search-as-you-type, live filters);
           - `restartable` / `sequential` / `droppable` / `concurrent` processing
             (via `bloc_concurrency`, only if already in `pubspec.yaml`);
           - merging/transforming several event streams before emitting state;
           - explicit event-sourcing, replay, or audit requirements.
           State which one you chose and the one-line reason in the `FEATURE.md` State section.
- STATE-2  A Cubit/Bloc depends ONLY on usecases (constructor-injected). Never on a
           repository, datasource, or `getIt`.
- STATE-3  States are `sealed class`. Widgets consume them with an exhaustive `switch`
           (expression or statement), never `is` checks or `else` fallbacks.
- STATE-4  No `FutureBuilder` / `StreamBuilder` around a Cubit. The Cubit owns the async state.
           Widgets use `BlocBuilder`, `BlocSelector`, `BlocListener`, or `BlocConsumer`.
- STATE-5  Every list/detail screen has explicit states: loading, success, empty, error
           (error carries a `Failure`, mapped to text per ERR-4). Naming:
           `XInitial`, `XLoading`, `XSuccess`, `XEmpty`, `XError`. How the screen shows the
           change: ANIM-4.
- STATE-6  Async safety:
           - After every `await` in a Cubit, `if (isClosed) return;` before `emit`.
           - Cancel subscriptions and timers in `close()`.
           - Never emit from a callback that can outlive the Cubit.
- STATE-7  A Cubit never holds `BuildContext`, `ScaffoldMessenger`, `Navigator`, or any
           Flutter UI type. One-off effects (snackbar, navigation) are emitted as a state
           that a `BlocListener` consumes (see NAV-3).
- STATE-8  States are immutable with value equality (ARCH-9) so identical states do not
           rebuild. Use `buildWhen` / `BlocSelector` when only part of a state matters.
- Lifecycle: a Cubit is created at route level with `BlocProvider(create: ...)`, which also
  closes it. Do not share one Cubit instance across unrelated routes.
