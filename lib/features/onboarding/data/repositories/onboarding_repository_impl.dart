import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/onboarding_page.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/local/onboarding_local_data_source.dart';
import '../models/onboarding_page_model.dart';

/// Implementation of [OnboardingRepository] using local data source.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  // Static list of onboarding pages — defined here to avoid JSON parsing overhead
  // for content that never changes at runtime.
  static const List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      id: 0,
      illustrationType: OnboardingIllustrationType.projects,
    ),
    OnboardingPageModel(
      id: 1,
      illustrationType: OnboardingIllustrationType.people,
    ),
    OnboardingPageModel(
      id: 2,
      illustrationType: OnboardingIllustrationType.finance,
    ),
    OnboardingPageModel(
      id: 3,
      illustrationType: OnboardingIllustrationType.insights,
    ),
  ];

  @override
  Future<ApiResult<List<OnboardingPage>>> getPages() async {
    // Synchronous data, wrapped in ApiResult for consistent interface
    return Success(_pages.map((m) => m.toEntity()).toList());
  }

  @override
  Future<ApiResult<void>> completeOnboarding() =>
      _localDataSource.setOnboardingSeen();
}
