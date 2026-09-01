class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

class GameEngineException extends AppException {
  const GameEngineException(super.message, [super.code]);
}

class ContentNotFoundException extends AppException {
  const ContentNotFoundException(super.message, [super.code]);
}
