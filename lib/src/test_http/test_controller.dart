import 'dart:convert';

import 'package:http/http.dart';

import '../../nimbus4flutter.dart';

class TestControllerHttp extends TestController{
  final ApiServerHttpClientBuilder? _builder;

  TestControllerHttp(
    {
      String apiServerName = "TestController",
      String host = "localhost",
      int port = 8080,
      String scheme = "http",
      ApiServerHttpClientBuilder? builder,
    }
  ) : _builder = builder,
  super(apiServerName: apiServerName, host: host, port: port, scheme: scheme);

  @override
  ApiServer buildApiServer() {
    return ApiServerHttp(
      name: apiServerName,
      host : host,
      port : port,
      scheme: scheme,
      builder: _builder,
      uriBuilder: (scheme, host, port, path, method, input) {
        if(method == HttpMethod.GET
          && input != null
          && (input is Map)
        ){
          Map<String,dynamic> query = input as Map<String, dynamic>;
          return Uri(scheme: scheme, host:host, port:port, path: path, queryParameters: query);
        }else{
          return Uri(scheme: scheme, host:host, port:port, path: path);
        }
      },
      requestBuilder: (request, method, input) async {
        request.headers['Accept-Encoding'] = 'gzip';
        request.headers['Accept'] = 'application/json';
      },
      responseParser: (response, method, output) async {
        if(response.statusCode != 200){
          throw new Exception("error status = ${response.statusCode}");
        }
        if(output is Map && response is StreamedResponse){
          String str = await response.stream.transform(Utf8Decoder()).join();
          if(str.isNotEmpty){
            Map json = JsonDecoder().convert(str);
            if(json.containsKey("exception")){
              throw new Exception("server side error = ${json['exception']}");
            }
            output.addAll(json);
          }
        }
      },
    );
  }

  @override
  Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfCancelScenario(String serverName, String apiName) {
    return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
      name: apiName,
      serverName: serverName,
      method: HttpMethod.GET,
      path: apiName,
      inputCreator: (_) => Map<String, dynamic>(),
      outputCreator: (_) => Map<String, dynamic>(),
    );
  }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfCancelTestCase(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfEndScenario(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<void, Map<String, dynamic>> createApiOfEndScenarioGroup(String serverName, String apiName) {
      return ApiHttp<void, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfEndTestCase(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<void, Map<String, dynamic>> createApiOfGetCurrentScenario(String serverName, String apiName) {
      return ApiHttp<void, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<void, Map<String, dynamic>> createApiOfGetCurrentScenarioGroup(String serverName, String apiName) {
      return ApiHttp<void, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<void, Map<String, dynamic>> createApiOfGetCurrentTestCase(String serverName, String apiName) {
      return ApiHttp<void, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfGetTestCaseStatus(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<void, Map<String, dynamic>> createApiOfGetTestPhase(String serverName, String apiName) {
      return ApiHttp<void, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfGetTestScenarioGroupStatus(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfGetTestScenarioStatus(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfStartScenario(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfStartScenarioGroup(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
    }
  
    @override
    Api<Map<String, dynamic>, Map<String, dynamic>> createApiOfStartTestCase(String serverName, String apiName) {
      return ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, StreamedResponse>(
        name: apiName,
        serverName: serverName,
        method: HttpMethod.GET,
        path: apiName,
        inputCreator: (_) => Map<String, dynamic>(),
        outputCreator: (_) => Map<String, dynamic>(),
      );
  }
}
