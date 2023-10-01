import 'package:example/model/request/api_request_model.dart';
import 'package:example/model/request/login_request_model.dart';
import 'package:example/model/response/api_response_model.dart';
import 'package:example/model/response/login_response_model.dart';
import 'package:http/http.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

part 'api_service.g.dart';

@NimbusApi() 
abstract class ApiService {
  factory ApiService({
    required String baseUrl,
    ApiServerHttpRequestBuilder? requestBuilder,
    ApiServerHttpResponseParser? responseParser,
  }) = _ApiService;

  @POST('/web/login.bf')
  Future<LoginResponseModel> login(LoginRequestModel request);

  @POST('/web/logout.bf')
  Future<ApiResponseModel> logout(ApiRequestModel request);
}
