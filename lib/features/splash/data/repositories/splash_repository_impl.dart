import 'package:orbit/core/utils/api_result.dart';

import '../../domain/repositories/splash_repository.dart';
import '../../domain/entities/splash_state_entity.dart';
import '../datasources/local/splash_local_data_source.dart';

/// Implementation of [SplashRepository] using local data source.
class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl(this._localDataSource);

  final SplashLocalDataSource _localDataSource;

  @override
  Future<ApiResult<SplashStateEntity>> checkStartupStatus() async {
    final result = await _localDataSource.getStartupStatus();
    return result.fold(
      (failure) => ResultFailure(failure),
      (model) => Success(model.toEntity()),
    );
  }
}
