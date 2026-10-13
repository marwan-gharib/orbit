import 'package:orbit/core/errors/failures.dart';

/// Either a [Success] or a [ResultFailure] — a sealed result type returned
/// instead of throwing, so callers must handle both outcomes exhaustively.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is ResultFailure<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) => switch (this) {
    Success<T>(:final data) => onSuccess(data),
    ResultFailure<T>(:final failure) => onFailure(failure),
  };

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    ResultFailure<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultFailure<T>(:final failure) => failure,
  };
}

/// Successful branch of an [ApiResult].
final class Success<T> extends ApiResult<T> {
  const Success(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failed branch of an [ApiResult], carrying a domain [failure].
final class ResultFailure<T> extends ApiResult<T> {
  const ResultFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'ResultFailure($failure)';
}
