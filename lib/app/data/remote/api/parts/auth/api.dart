import 'package:dharak_flutter/app/data/remote/api/base/api_request.dart';
import 'package:dharak_flutter/app/data/remote/api/base/api_response.dart';
import 'package:dharak_flutter/app/data/remote/api/base/dto/error_dto.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/auth/dto/auth_login_req_dto.dart';
import 'package:dharak_flutter/app/types/auth/login.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api.g.dart';

@RestApi()
abstract class AuthApiPoint {
  factory AuthApiPoint(Dio dio, {String baseUrl}) = _AuthApiPoint;

  @POST('/api/glogin/')
  Future<AuthLoginRM> login(@Body() AuthLoginReqDto request);
}

class AuthApiRepo extends ApiRequest<ErrorDto> {
  final AuthApiPoint apiPoint;
  final Dio dio; // Direct Dio access for token refresh

  AuthApiRepo({required this.apiPoint, required this.dio});

  Future<ApiResponse<AuthLoginRM, ErrorDto>> login(AuthLoginReqDto request) async {
    var result = await sendRequest(
      () => apiPoint.login(request),
      (data) => Future.value(ErrorDto.fromJson(data)),
    );

    return result;
  }
  
  /// Refresh access token using refresh token
  /// Uses Dio directly to avoid Retrofit code generation issues
  Future<RefreshTokenResponse> refreshToken(Map<String, dynamic> request) async {
    try {
      final response = await dio.post(
        '/api/token/refresh/',
        data: request,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return RefreshTokenResponse(
          accessToken: data['access'] as String?,
          success: true,
        );
      }
      
      return RefreshTokenResponse(
        accessToken: null,
        success: false,
      );
    } catch (e) {
      print('AuthApiRepo: Token refresh failed - $e');
      return RefreshTokenResponse(
        accessToken: null,
        success: false,
      );
    }
  }
}

/// Simple response model for token refresh
class RefreshTokenResponse {
  final String? accessToken;
  final bool success;
  
  RefreshTokenResponse({
    required this.accessToken,
    required this.success,
  });
}