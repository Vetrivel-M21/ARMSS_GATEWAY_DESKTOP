import 'app_exception.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(value: final v) => v,
        Failure<T>() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(error: final e) => e,
      };

  R fold<R>(R Function(T value) onSuccess, R Function(AppException error) onFailure) {
    return switch (this) {
      Success<T>(value: final v) => onSuccess(v),
      Failure<T>(error: final e) => onFailure(e),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}
