import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:leudaar_app/data/network/baes_api_service.dart';

class NetworkApiService extends BaseApiService {
  late Dio _dio;

  NetworkApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );

    /// Interceptor for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("➡️ REQUEST [${options.method}] => ${options.uri}");
          debugPrint("Headers: ${options.headers}");
          debugPrint("Data: ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint("✅ RESPONSE [${response.statusCode}] => ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint("❌ ERROR [${e.response?.statusCode}] => ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  /// 🔑 Set Authorization Token
  void setToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
    debugPrint("🔐 Token Set: Bearer $token");
  }

  /// ❌ Remove Token (Logout)
  void clearToken() {
    _dio.options.headers.remove("Authorization");
    debugPrint("🔓 Token Cleared");
  }

  @override
  Future<dynamic> getApi(String url) async {
    try {
      debugPrint("GET API CALL => $url");
      final response = await _dio.get(url);
      return response.data;
    } on DioException catch (e) {
      debugPrint("GET API ERROR => ${e.message}");
      if (e.response != null) {
        // 👇 IMPORTANT: return backend response even on 400
        return e.response!.data;
      }
      throw Exception("No Internet");
    }
  }

  @override
  Future<dynamic> postApi(String url, dynamic data) async {
    try {
      debugPrint("POST API CALL => $url");
      debugPrint("POST DATA => $data");

      final response = await _dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("POST API ERROR => ${e.message}");
      if (e.response != null) {
        // 👇 IMPORTANT: return backend response even on 400
        return e.response!.data;
      }
      throw Exception("No Internet");
    }
  }

  @override
  Future<dynamic> pacthApi(String url, dynamic data) async {
    try {
      debugPrint("POST API CALL => $url");
      debugPrint("POST DATA => $data");

      final response = await _dio.patch(url, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("POST API ERROR => ${e.message}");
      if (e.response != null) {
        // 👇 IMPORTANT: return backend response even on 400
        return e.response!.data;
      }
      throw Exception("No Internet");
    }
  }

  @override
  Future<dynamic> putApi(String url, dynamic data) async {
    try {
      debugPrint("PUT API CALL => $url");
      debugPrint("PUT DATA => $data");

      final response = await _dio.put(url, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("PUT API ERROR => ${e.message}");
      if (e.response != null) {
        // 👇 IMPORTANT: return backend response even on 400
        return e.response!.data;
      }
      throw Exception("No Internet");
    }
  }

  @override
  Future<dynamic> deleteApi(String url, dynamic data) async {
    try {
      debugPrint("DELETE API CALL => $url");

      final response = await _dio.delete(url, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("DELETE API ERROR => ${e.message}");
      if (e.response != null) {
        // 👇 IMPORTANT: return backend response even on 400
        return e.response!.data;
      }
      throw Exception("No Internet");
    }
  }

  // AppException _handleDioError(DioException error) {
  //   debugPrint("HANDLE ERROR => ${error.response?.data}");

  //   switch (error.type) {
  //     case DioExceptionType.connectionTimeout:
  //     case DioExceptionType.sendTimeout:
  //     case DioExceptionType.receiveTimeout:
  //       return FetchDataException("Connection timeout");

  //     case DioExceptionType.badResponse:
  //       final statusCode = error.response?.statusCode ?? 0;
  //       final message = error.response?.data.toString() ?? "Unknown error";

  //       if (statusCode == 400) {
  //         return BadRequestException(message);
  //       } else if (statusCode == 401 || statusCode == 403) {
  //         return UnauthorizedException(message);
  //       } else if (statusCode == 500) {
  //         return FetchDataException("Server Error");
  //       } else {
  //         return FetchDataException(
  //           "Error occurred with status code : $statusCode",
  //         );
  //       }

  //     case DioExceptionType.cancel:
  //       return FetchDataException("Request cancelled");

  //     case DioExceptionType.unknown:
  //     default:
  //       return FetchDataException("No Internet Connection");
  //   }
  // }
}
