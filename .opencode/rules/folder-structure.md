# Folder Structure (reference)

Read it when creating files, placing code, or changing `core/`. The real inventory of `core/`
is `docs/CORE_MAP.md`; when the two disagree, the code wins and the docs are fixed (DOC-1).

```text
lib/
  main.dart                          # ResponsiveScope wraps MaterialApp (RESP-5)
  dev/                               # dev-only pages, e.g. animations_showcase_page.dart
  core/
    animations/                      # ALL motion (ANIM-1): tokens, entrance, staggered, feedback,
                                     #   state, loading, lottie, overlays, scroll, navigation;
                                     #   barrel animations.dart + README.md cheat sheet
    constants/                       # ARCH-10: ApiKeys, Endpoints, Assets, AppLottieAssets,
                                     #   AppConsts, HeroTags, Fonts... one file per purpose
    di/                              # injection_container.dart + one *_injection.dart per feature
    errors/                          # Failure hierarchy + the Dio error classifier
    extensions/                      # BuildContext extensions (colors, textStyles, responsive,
                                     #   navigation, failureText)
    helpers/                         # small generic helpers
    i18n/                            # slang generated output (never edit by hand)
    local/
      secure/                        # abstraction + impl for tokens / sensitive data
      cache/                         # abstraction + impl for non-sensitive data
    network/                         # BaseApiClient (abstract) + implementation + interceptors/
    responsive/                      # Responsive facade, ResponsiveScope, scalers
    router/                          # go_router config, route_names.dart, route_paths.dart,
                                     #   route_guards.dart
    services/
    theme/                           # AppTheme, AppColors, AppTextStyles, AppSpacing, AppRadius,
                                     #   extensions/ (context.colors, context.textStyles)
    utils/                           # ApiResult (with fold only), PagedResult, Logger, Validators
    widgets/                         # shared components + barrel widgets.dart
  features/<feature_name>/
    FEATURE.md                       # see feature-docs.md
    presentation/
      screens/
      widgets/                       # feature-only widgets (WIDGET-2), one public widget per file
      cubits/<cubit_or_bloc_name>/   # cubit/bloc + sealed state
      view_models/                   # created with the first view model
      mappers/                       # entity -> view model (created with the first mapper)
    domain/
      entities/
      repositories/                  # abstract contracts only
      usecases/                      # plain classes with call(), no base class (DOM-1)
      params/                        # one *Params class per usecase with >1 input
    data/
      datasources/
        remote/                      # concrete classes, no interface
        local/                       # concrete classes, no interface
      models/                        # fromJson / toJson / toEntity()
      repositories/                  # *RepositoryImpl
docs/
  FEATURES_INDEX.md
  CORE_MAP.md
test/                                # mirrors lib/ exactly (TEST-5)
testers_release_note.txt             # NOTES rules; project root
```

File names are `snake_case.dart` with the suffixes `_entity`, `_params`, `_repository`,
`_repository_impl`, `_usecase`, `_model`, `_mapper` (presentation only), `_remote_data_source`,
`_local_data_source`, `_cubit`, `_state`, `_screen`, `_view_model`, `_injection`.
