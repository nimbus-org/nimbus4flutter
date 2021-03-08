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

import 'dart:io' as io;

import 'package:nimbus4flutter/nimbus4flutter.dart';

typedef ApiServerIOClientBuilder = void Function(io.HttpClient client);

typedef ApiServerIORequestBuilder = void Function(io.HttpClientRequest request, HttpMethod method, Object input);

typedef ApiServerIOResponseParser = Future<void> Function(io.HttpClientResponse response, HttpMethod method, Object output);

/// It contains information about the server with the API and its processing.
/// 
/// For example
/// ```dart
/// import 'dart:io';
/// import 'dart:convert';
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// ApiServerIO(
///   name: "local server",
///   host: "localhost",
///   requestBuilder: (request, method, input) {
///     switch(method){
///       case HttpMethod.POST:
///       DataSet ds = input as DataSet;
///       request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
///       request.write(
///         JsonEncoder().convert(ds.toMap(toJsonType: true))
///       );
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
///       ds.fromMap(JsonDecoder().convert(await response.transform(Utf8Decoder()).join()));
///     }
///   },
/// );
/// ```
@immutable
class ApiServerIO extends ApiServer{
  final ApiServerIORequestBuilder _requestBuilder;
  final ApiServerIOResponseParser _responseParser;

  final io.HttpClient _client = io.HttpClient();

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
  ApiServerIO(
    {
      @required String name,
      @required String host,
      int port,
      String scheme = "http",
      ApiServerIOClientBuilder builder,
      ApiServerUriBuilder uriBuilder,
      ApiServerIORequestBuilder requestBuilder,
      ApiServerIOResponseParser responseParser
    }
  ): _requestBuilder = requestBuilder,
     _responseParser = responseParser,
      super(name:name, host:host, port:port, scheme:scheme, uriBuilder:uriBuilder)
  {
    if(builder != null)builder(_client);
  }

  /// HttpClient to communicate with the server.
  io.HttpClient get client => _client;

  /// The process of building HttpClientRequest, an HTTP request to the server.
  ApiServerIORequestBuilder get requestBuilder => _requestBuilder;

  /// the parsing process from HttpClientResponse, an HTTP response from the server, to the output DTO.
  ApiServerIOResponseParser get responseParser => _responseParser;

  /// Close server.
  @override
  void close({bool force: false}) => _client.close(force:force);

}
