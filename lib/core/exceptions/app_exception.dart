/// 앱 공통 예외 클래스
sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// 네트워크 연결 오류
class NetworkException extends AppException {
  const NetworkException([super.message = '인터넷 연결을 확인해주세요'])
    : super(code: 'NETWORK_ERROR');
}

/// API 서버 오류
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({String message = '서버에 문제가 발생했습니다', this.statusCode})
    : super(message, code: 'SERVER_ERROR');
}

/// API 요청 오류 (잘못된 요청 등)
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({String message = '요청을 처리할 수 없습니다', this.statusCode})
    : super(message, code: 'API_ERROR');
}

/// 데이터 파싱 오류
class ParseException extends AppException {
  const ParseException([super.message = '데이터를 불러올 수 없습니다'])
    : super(code: 'PARSE_ERROR');
}

/// 타임아웃 오류
class TimeoutException extends AppException {
  const TimeoutException([super.message = '요청 시간이 초과되었습니다'])
    : super(code: 'TIMEOUT_ERROR');
}
