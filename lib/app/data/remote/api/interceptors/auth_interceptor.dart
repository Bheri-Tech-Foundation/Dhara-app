import 'package:dharak_flutter/app/data/local/secure/secure_local_data.dart';
import 'package:dharak_flutter/app/data/remote/api/constants.dart';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/app/types/auth/access_token.dart';
import 'package:dharak_flutter/flavors.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final Dio dio;

  final SecureLocalData storage;

  // = new FlutterSecureStorage();

  AuthInterceptor(this.dio, this.storage);

  // when accessToken is expired & having multiple requests call
  // this variable to lock others request to make sure only trigger call refresh token 01 times
  // to prevent duplicate refresh call
  bool _isRefreshing = false;

  // when having multiple requests call at the same time, you need to store them in a list
  // then loop this list to retry every request later, after call refresh token success
  final _requestsNeedRetry =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  final PublishSubject<bool> _mEventLoginNeeded = PublishSubject<bool>();
  PublishSubject<bool> get eventLoginNeeded => _mEventLoginNeeded;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final accessToken = getAccessTokenFromLocalStorage();
    // options.headers['authorization'] = 'Bearer $accessToken';

    var isStrictToken = false;

    if (options.headers.containsKey(ApiConstants.HEADER_REQUIRE_TOKEN)) {
      //remove the auxiliary header
      var requireToken = options.headers[ApiConstants.HEADER_REQUIRE_TOKEN];
      // print("onRequest 1: $requireToken ${requireToken is bool}"); // Temporarily disabled

      if (requireToken is bool && requireToken) {
        isStrictToken = true;
      }

      options.headers.remove(ApiConstants.HEADER_REQUIRE_TOKEN);

      //ToDo exception occured on first start
      String? accessToken;
      try {
        accessToken = await storage.getAccessToken();
      } catch (e) {
        // Silent exception handling
      }
      // var header = prefs.get("Header");

      // print("onRequest 2: get Token: ${accessToken?.length}"); // Temporarily disabled

      if (accessToken != null) {
        options.headers.addAll({"Authorization": "Bearer $accessToken"});
      } else if (isStrictToken) {
        // final isRefreshSuccess = await _refreshToken();
        // accessToken = await storage.getAccessToken();
        //    options.headers.addAll({"Authorization": "bearer $accessToken"});
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401),
          ),
          true,
        );
      }

      // return options;
    }
    // print("onRequest 3: request: "); // Temporarily disabled

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response?.requestOptions != null &&
        // status code for unauthorized usually 401
        (response?.statusCode == 403 || response?.statusCode == 401) &&
        // refresh token call maybe fail by it self
        // eg: when refreshToken also is expired -> can't get new accessToken
        // usually server also return 401 unauthorized for this case
        // need to exlude it to prevent loop infinite call
        // response.requestOptions.path != "path/your/endpoint/refresh"
        !(response!.requestOptions.path.contains("/auth") ||
            response.requestOptions.path.contains("/google_login") ||
            response.requestOptions.path.contains("/token"))) {
      
      // if hasn't not refreshing yet, let's start it
      if (!_isRefreshing) {
        _isRefreshing = true;

        // add request (requestOptions and handler) to queue and wait to retry later
        _requestsNeedRetry.add((
          options: response.requestOptions,
          handler: handler,
        ));

        // call api refresh token
        final isRefreshSuccess = await _refreshToken();

        if (isRefreshSuccess) {
          // refresh success, loop requests need retry
          for (var requestNeedRetry in _requestsNeedRetry) {
            // don't need set new accessToken to header here, because these retry
            // will go through onRequest callback above (where new accessToken will be set to header)

            // won't use await because this loop will take longer -> maybe throw: Unhandled Exception: Concurrent modification during iteration
            // because method _requestsNeedRetry.add() is called at the same time
            // final response = await dio.fetch(requestNeedRetry.options);
            // requestNeedRetry.handler.resolve(response);

            // TODO may be await needed

            String? accessToken;

            try {
              accessToken = await storage.getAccessToken();
            } catch (e) {
              // Silent exception handling
            }
            // var header = prefs.get("Header");

            var options = requestNeedRetry.options;

            if (accessToken != null) {
              options.headers.addAll({"Authorization": "Bearer $accessToken"});
            }
            dio
                .fetch(options)
                .then((response) {
                  requestNeedRetry.handler.resolve(response);
                })
                .catchError((_) {});
          }

          _requestsNeedRetry.clear();
          _isRefreshing = false;
        } else {
          _requestsNeedRetry.clear();

          _mEventLoginNeeded.sink.add(true);

          _isRefreshing = false;
          return handler.next(err);
          // if refresh fail, force logout user here
        }
      } else {
        // if refresh flow is processing, add this request to queue and wait to retry later
        _requestsNeedRetry.add((
          options: response.requestOptions,
          handler: handler,
        ));
      }
    } else {
      // ignore other error is not unauthorized
      return handler.next(err);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearAuthData();
        return false;
      }

      final Response res;
      
      // Use developer mode URL if enabled, otherwise use production URL
      final baseUrl = DeveloperModeService.instance.getEffectiveApiUrl();

      res = await dio.post(
        '$baseUrl/api/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (res.statusCode == 200) {
        // Handle the actual response format from the server
        final responseData = res.data as Map<String, dynamic>;
        final newAccessToken = responseData['access'] as String?;
        
        if (newAccessToken != null) {
          await storage.saveAccessToken(newAccessToken);
          return true;
        } else {
          return false;
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // Only clear auth data for 401/403 (expired/invalid refresh token)
        await _clearAuthData();
        return false;
      } else {
        // Other error codes (500, 503, etc.) - don't clear auth data
        return false;
      }
    } catch (error) {
      // Only clear auth data for 401/403 (refresh token expired/invalid)
      if (error is DioException && 
          (error.response?.statusCode == 401 || error.response?.statusCode == 403)) {
        await _clearAuthData();
      }
      return false;
    }
  }
  
  /// Clear all auth data when refresh token expires
  Future<void> _clearAuthData() async {
    try {
      await storage.saveAccessToken(null);
      await storage.saveRefreshToken(null);
    } catch (e) {
      // Error clearing auth data
    }
  }
}
