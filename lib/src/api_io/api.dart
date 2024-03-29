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
import 'dart:async';
import 'package:nimbus4flutter/nimbus4flutter.dart';

/// Function to process of building HttpClientRequest, an HTTP request to the server.
typedef ApiIORequestBuilder<I> = void Function(HttpClientRequest request, I? input, Function(HttpClientRequest request, I? input) serverBuilder);

/// Function to process of parsing from HttpClientResponse, an HTTP response from the server, to the output DTO.
typedef ApiIOResponseParser<O> = Future<void> Function(HttpClientResponse response, O? output, Function(HttpClientResponse response, O? output) serverParser);

/// A single API.
/// 
/// For example
/// ```dart
/// Api api = ApiIO<DataSet,DataSet>(
///   name: "get user",
///   serverName: "local server",
///   method:HttpMethod.POST
///   path:"/users",
///   inputCreator: (context){
///     DataSet ds = DataSet("Condition");
///     ds.setHeaderSchema(
///       RecordSchema([FieldSchema<String>("id")])
///     );
///     return ds;
///   },
///   outputCreator: (context){
///     DataSet ds = DataSet("User");
///     ds.setHeaderSchema(
///       RecordSchema(
///         [
///           FieldSchema<String>("name"),
///           FieldSchema<int>("age"),
///           FieldSchema<String>("tel")
///         ]
///       )
///     );
///     return ds;
///   }
/// );
/// 
/// RequestContext context = RequestContext();
/// DataSet requestDs = api.getInput(context);
/// requestDs.getHeader()["id"] = "0000001";
/// 
/// DataSet responseDs = await api.request(requestDs, context);
/// 
/// Record userRecord = responseDs.getHeader();
/// ```
@immutable
class ApiIO<I,O> extends Api<I,O>{
  final String _serverName;
  final HttpMethod _method;
  final String _path;
  final ApiInOutCreator<I>? _inputCreator;
  final ApiInOutCreator<O>? _outputCreator;
  final UriBuilder<I>? _uriBuilder;
  final ApiIORequestBuilder<I>? _requestBuilder;
  final ApiIOResponseParser<O>? _responseParser;

  /// Construct API.
  ///
  /// In [name], specify a logical name of API.
  /// In [serverName], specify a logical name of [ApiServer].
  /// In [method], specify method of http.
  /// In [path], specify the path that is part of the API URI.
  /// In [inputCreator], specify the process to create a DTO for input to an API
  /// In [outputCreator], specify the process to create a DTO for output to an API
  /// In [uriBuilder], specify the process of building uri to request to the server.
  /// In [requestBuilder], specify the process of building HttpClientRequest, an HTTP request to the server.
  /// In [responseParser], specify the process of parsing from HttpClientResponse, an HTTP response from the server, to the output DTO.
  ApiIO(
    {
      required String name,
      required String  serverName,
      required HttpMethod method,
      required String path,
      ApiInOutCreator<I>? inputCreator,
      ApiInOutCreator<O>? outputCreator,
      UriBuilder<I>? uriBuilder,
      ApiIORequestBuilder<I>? requestBuilder,
      ApiIOResponseParser<O>? responseParser
    }
  ) : _serverName = serverName,
    _method = method,
    _path = path,
    _inputCreator = inputCreator,
    _outputCreator = outputCreator,
    _uriBuilder = uriBuilder,
    _requestBuilder = requestBuilder,
    _responseParser = responseParser,
    super(name);
  
  @override
  I? getInput(RequestContext context) => _inputCreator == null ? null : _inputCreator!(context);

  @override
  Future<O?> request(I? input, RequestContext context){
    context.setInput(name, context);
    Future<HttpClientRequest> req;
    ApiServerIO server = ApiRegistory.getApiServer(_serverName) as ApiServerIO;
    Uri uri;
    if(_uriBuilder != null){
      uri = _uriBuilder!(server.scheme, server.host, server.port, _path, input, context, (scheme, host, port, path, input) => server.uriBuilder?.call(server.scheme, server.host, server.port, _path, _method, input));
    }else if(server.uriBuilder != null){
      uri = server.uriBuilder!(server.scheme, server.host, server.port, _path, _method, input);
    }else{
      uri = Uri(
        host: server.host,
        port: server.port,
        scheme: server.scheme,
        path: _path
      );
    }
    switch(_method){
    case HttpMethod.GET:
      req = server.client.getUrl(uri);
      break;
    case HttpMethod.POST:
      req = server.client.postUrl(uri);
      break;
    case HttpMethod.PUT:
      req = server.client.putUrl(uri);
      break;
    case HttpMethod.PATCH:
      req = server.client.patchUrl(uri);
      break;
    case HttpMethod.HEAD:
      req = server.client.headUrl(uri);
      break;
    case HttpMethod.DELETE:
      req = server.client.deleteUrl(uri);
      break;
    }
    Future<HttpClientResponse> resp = req.then((HttpClientRequest request){
      if(_requestBuilder != null){
        _requestBuilder!(request, input, (request, input) => server.requestBuilder?.call(request, _method, input));
      }else if(server.requestBuilder != null){
        server.requestBuilder!(request, _method, input);
      }
      return request.close();
    }).catchError(
      (e) => context.exception = e
    ).whenComplete(() {if(context.exception != null) throw context.exception;});
    
    O? output = _outputCreator == null ? null : _outputCreator!(context);
    return resp.then((HttpClientResponse response) async{
      try{
        if(_responseParser != null){
          await _responseParser!(
            response,
            output,
            (response, output) {
              return server.responseParser?.call(response, _method, output)
                .catchError((e) => (e) => context.exception = e);
            }
          );
          
        }else if(server.responseParser != null){
          await server.responseParser!(response, _method, output);
        }
      }catch(e){
        context.exception = e;
      }
      if(output != null){
        context.setOutput(name, output);
      }
      return output;
    }).catchError(
      (e) => context.exception = e
    ).whenComplete(() {if(context.exception != null) throw context.exception;});
  }
}
