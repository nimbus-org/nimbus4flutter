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

import 'dart:io';

import 'package:nimbus4flutter/nimbus4flutter.dart';

typedef HttpClientBuilder = void Function(HttpClient client);

typedef ApiServerHttpClientRequestBuilder = void Function(HttpClientRequest request, HttpMethod method, Object input);

typedef ApiServerHttpClientResponseParser = Future<void> Function(HttpClientResponse response, HttpMethod method, Object output);

@immutable
class ApiServer{
  final String _name;
  final String _host;
  final int _port;
  final ApiServerHttpClientRequestBuilder _requestBuilder;
  final ApiServerHttpClientResponseParser _responseParser;

  final HttpClient _client = new HttpClient();

  ApiServer(
    {
      @required String name,
      @required String host,
      int port,
      HttpClientBuilder builder,
      ApiServerHttpClientRequestBuilder requestBuilder,
      ApiServerHttpClientResponseParser responseParser
    }
  ):_name= name,
    _host = host,
    _port = port,
    _requestBuilder = requestBuilder,
    _responseParser = responseParser
  {
    if(builder != null)builder(_client);
  }

  String get name => _name;

  String get host => _host;
  
  int get port => _port;

  HttpClient get client => _client;

  ApiServerHttpClientRequestBuilder get requestBuilder => _requestBuilder;

  ApiServerHttpClientResponseParser get responseParser => _responseParser;

  void close({bool force: false}) => _client.close(force:force);

}
