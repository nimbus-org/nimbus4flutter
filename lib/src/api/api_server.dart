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

import 'package:nimbus4flutter/nimbus4flutter.dart';

typedef ApiServerUriBuilder = Uri Function(String scheme, String host, int port, String path, HttpMethod method, Object input);

/// It contains information about the server with the API and its processing.
@immutable
abstract class ApiServer{
  final String _name;
  final String _host;
  final String _scheme;
  final int _port;
  final ApiServerUriBuilder _uriBuilder;

  /// Construct ApiServer
  /// 
  /// In [name], specify a logical name of the server.
  /// In [host], specify the hostname of the server.
  /// In [port], specify the port of the server.
  /// In [scheme], specify the scheme of the uri.
  /// In [uriBuilder], specify the process of building uri to request to the server.
  ApiServer(
    {
      @required String name,
      @required String host,
      int port,
      String scheme = "http",
      ApiServerUriBuilder uriBuilder
    }
  ):_name= name,
    _host = host,
    _port = port,
    _scheme = scheme,
    _uriBuilder = uriBuilder;

  /// A logical name of the server.
  String get name => _name;

  /// The hostname of the server.
  String get host => _host;
  
  /// The port of the server.
  int get port => _port;

  /// The scheme of the uri.
  String get scheme => _scheme;

  /// The process of building path, an HTTP request to the server.
  ApiServerUriBuilder get uriBuilder => _uriBuilder;

  /// Close server.
  void close({bool force: false}){}

}
