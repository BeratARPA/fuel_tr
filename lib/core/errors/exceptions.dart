class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message';
}

class ParseException implements Exception {
  final String message;
  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
