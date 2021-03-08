/*
 * This software is distributed under following license based on modified BSD
 * style license.
 * ----------------------------------------------------------------------
 * 
 * Copyright 2003 The Nimbus Project. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE NIMBUS PROJECT ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
 * NO EVENT SHALL THE NIMBUS PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are
 * those of the authors and should not be interpreted as representing official
 * policies, either expressed or implied, of the Nimbus Project.
 */

import 'package:http/http.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:nimbus4flutter/nimbus4flutter.dart';

typedef ApiServerHttpClientBuilder = void Function(Client client);

typedef ApiServerHttpRequestBuilder = Future<void> Function(BaseRequest request, HttpMethod method, Object input);

typedef ApiServerHttpResponseParser = Future<void> Function(BaseResponse response, HttpMethod method, Object output);

/// It contains information about the server with the API and its processing.
/// 
/// For example
/// ```dart
/// import 'dart:convert';
/// import 'package:http/http.dart';
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// ApiServerHttp(
///   name: "local server",
///   host: "localhost",
///   requestBuilder: (request, method, input) {
///     switch(method){
///     case HttpMethod.POST:
///       DataSet ds = input as DataSet;
///       request.headers["Content-Type"] = "application/json;charset=utf-8";
///       (request as Request).body = JsonEncoder().convert(ds.toMap(toJsonType: true));
///       break;
///     default:
///       break;
///     }
///   },
///   responseParser: (response, method, output) async{
///     if(response.statusCode != 200){
///       throw new Exception("error status = ${response.statusCode}");
///     }
///     if(output != null){
///       DataSet ds = output as DataSet;
///       ds.fromMap(JsonDecoder().convert(await (response as StreamedResponse).stream.transform(Utf8Decoder()).join()));
///     }
///   },
/// );
/// ```
@immutable
class ApiServerHttp extends ApiServer{
  final ApiServerHttpRequestBuilder _requestBuilder;
  final ApiServerHttpResponseParser _responseParser;

  final HttpClient _client = HttpClient();

  /// Construct ApiServer
  /// 
  /// In [name], specify a logical name of the server.
  /// In [host], specify the hostname of the server.
  /// In [port], specify the port of the server.
  /// In [scheme], specify the scheme of the uri.
  /// In [builder], specify the process of building HttpClient to communicate with the server.
  /// In [uriBuilder], specify the process of building uri to request to the server.
  /// In [requestBuilder], specify the process of building HttpClientRequest, an HTTP request to the server.
  /// In [responseParser], specify the parsing process from HttpClientResponse, an HTTP response from the server, to the output DTO.
  ApiServerHttp(
    {
      @required String name,
      @required String host,
      int port,
      String scheme = "http",
      ApiServerHttpClientBuilder builder,
      ApiServerUriBuilder uriBuilder,
      ApiServerHttpRequestBuilder requestBuilder,
      ApiServerHttpResponseParser responseParser
    }
  ): _requestBuilder = requestBuilder,
     _responseParser = responseParser,
      super(name:name, host:host, port:port, scheme:scheme, uriBuilder:uriBuilder)
  {
    if(builder != null)builder(_client);
  }

  /// HttpClient to communicate with the server.
  HttpClient get client => _client;

  /// The process of building HttpClientRequest, an HTTP request to the server.
  ApiServerHttpRequestBuilder get requestBuilder => _requestBuilder;

  /// the parsing process from HttpClientResponse, an HTTP response from the server, to the output DTO.
  ApiServerHttpResponseParser get responseParser => _responseParser;

  /// Close server.
  @override
  void close({bool force: false}) => _client.close();

}

class HttpClient extends BaseClient {

  final Client _inner = Client();
  final CookieJar cookieJar = CookieJar();
  Duration requestTimeout;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {

    final cookies = cookieJar.loadForRequest(request.url);
    _removeExpiredCookies(cookies);

    String cookie = _getCookies(cookies);
    if (cookie.isNotEmpty) {
      request.headers[HttpHeaders.cookieHeader] = cookie;
    }

    final response = await (requestTimeout == null ? _inner.send(request) : _inner.send(request).timeout(requestTimeout));

    if (response != null && response.headers != null) {
      final cookieHeader = response.headers[HttpHeaders.setCookieHeader];
      _saveCookies(response.request.url, cookieHeader);
    }

    return response;
  }

  void _removeExpiredCookies(List<Cookie> cookies) {
    cookies.removeWhere((cookie) {
      if (cookie.expires != null) {
        return cookie.expires.isBefore(DateTime.now());
      }
      return false;
    });
  }

  String _getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => "${cookie.name}=${cookie.value}").join('; ');
  }

  void _saveCookies(Uri uri, String cookieHeader) {
    if (cookieHeader == null || cookieHeader.isEmpty) {
      return;
    }
    final cookies = cookieHeader.split(",");
    if (cookies.isEmpty) {
      return;
    }
    cookieJar.saveFromResponse(
      uri,
      cookies.map((cookie) => Cookie.fromSetCookieValue(cookie)).toList(),
    );
  }
}
