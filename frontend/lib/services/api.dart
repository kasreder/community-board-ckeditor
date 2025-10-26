import 'package:dio/dio.dart';

class ApiService {
  ApiService({Dio? client}) : _dio = client ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final options = BaseOptions(
      baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json'},
    );
    return Dio(options)
      ..interceptors.add(
        QueuedInterceptorsWrapper(
          onError: (error, handler) {
            if (error.type == DioExceptionType.badResponse && error.response?.statusCode == 401) {
              // 인증 만료 등은 상위에서 처리할 수 있도록 전달.
            }
            handler.next(error);
          },
        ),
      );
  }

  final Dio _dio;

  Dio get client => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
