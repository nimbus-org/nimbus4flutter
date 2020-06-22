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

/// Processing context of a request to the server.
class RequestContext{
  Map<String,Object> inputs = Map();
  Map<String,Object> outputs = Map();
  Map<String,Object> attributes = Map();

  RequestContext();

  /// Get the input DTO of a specified API name.
  I getInput<I>(String api){
    return inputs[api] as I;
  }

  /// Set the input DTO of a specified API name.
  void setInput(String api, Object input){
    inputs[api] = input;  
  }

  /// Get the output DTO of a specified API name.
  O getOutput<O>(String api){
    return outputs[api] as O;
  }

  /// Set the output DTO of a specified API name.
  void setOutput(String api, Object output){
    outputs[api] = output;  
  }

  /// Get attribute of a specified name.
  T getAttribute<T>(String name){
    return attributes[name];
  }

  /// Set attribute of a specified name.
  void setAttribute(String name, Object output){
    attributes[name] = output;  
  }
}

/// A class that abstracts the server API.
abstract class Api<I,O>{
  final String _name;

  Api(
    String name
  ) : _name = name;

  /// A logical name of API.
  get name => _name;

  /// Get the input DTO that is the source of the request to the server.
  I getInput(RequestContext context);

  /// Request to the server.
  Future<O> request(I input, RequestContext context);
}

/// Function to create a DTO for input and output to an API.
typedef ApiInOutCreator<T> = T Function(RequestContext context);

/// Function to create a DTO for input and output to an API.
typedef UriBuilder<I> = Uri Function(String scheme, String host, int port, String path, I input, RequestContext context, Function(String scheme, String host, int port, String path, I input) serverBuilder);

/// Function to process of building HttpClientRequest, an HTTP request to the server.
typedef HttpClientRequestBuilder<I> = void Function(HttpClientRequest request, I input, Function(HttpClientRequest request, I input) serverBuilder);

/// Function to process of parsing from HttpClientResponse, an HTTP response from the server, to the output DTO.
typedef HttpClientResponseParser<O> = Future<void> Function(HttpClientResponse response, O output, Function(HttpClientResponse response, O output) serverParser);

/// HTTP Methods enumeration.
enum HttpMethod{
  GET,
  POST,
  PUT,
  HEAD,
  PATCH,
  DELETE
}

/// A single API.
/// 
/// For example
/// ```dart
/// Api api = SingleApi<DataSet,DataSet>(
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
class SingleApi<I,O> extends Api<I,O>{
  final String _serverName;
  final HttpMethod _method;
  final String _path;
  final ApiInOutCreator<I> _inputCreator;
  final ApiInOutCreator<O> _outputCreator;
  final UriBuilder<I> _uriBuilder;
  final HttpClientRequestBuilder<I> _requestBuilder;
  final HttpClientResponseParser<O> _responseParser;

  /// Construct API.
  ///
  /// In [name], specify a logical name of API.
  /// In [serverName], specify a logical name of [ApiServer].
  /// In [method], specify method of http.
  /// In [path], specify the path that is part of the API URI.
  /// In [inputCreator], specify the process to create a DTO for input to an API
  /// In [outputCreator], specify the process to create a DTO for output to an API
  /// In [requestBuilder], specify the process of building HttpClientRequest, an HTTP request to the server.
  /// In [responseParser], specify the process of parsing from HttpClientResponse, an HTTP response from the server, to the output DTO.
  SingleApi(
    {
      @required String name,
      @required String  serverName,
      @required HttpMethod method,
      @required String path,
      ApiInOutCreator<I> inputCreator,
      ApiInOutCreator<O> outputCreator,
      UriBuilder<I> uriBuilder,
      HttpClientRequestBuilder<I> requestBuilder,
      HttpClientResponseParser<O> responseParser
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
  I getInput(RequestContext context) => _inputCreator == null ? null : _inputCreator(context);

  @override
  Future<O> request(I input, RequestContext context) async{
    context?.setInput(name, context);
    Future<HttpClientRequest> req;
    ApiServer server = ApiRegistory.getApiServer(_serverName);
    Uri uri;
    if(_uriBuilder != null){
      uri = _uriBuilder(server.scheme, server.host, server.port, _path, input, context, (scheme, host, port, path, input) => server.uriBuilder ?? server.uriBuilder(server.scheme, server.host, server.port, _path, _method, input));
    }else if(server.uriBuilder != null){
      uri = server.uriBuilder(server.scheme, server.host, server.port, _path, _method, input);
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
      server.client.putUrl(uri);
      break;
    case HttpMethod.PATCH:
      server.client.patchUrl(uri);
      break;
    case HttpMethod.HEAD:
      server.client.headUrl(uri);
      break;
    case HttpMethod.DELETE:
      server.client.deleteUrl(uri);
      break;
    }
    Future<HttpClientResponse> resp = req.then((HttpClientRequest request){
      if(_requestBuilder != null){
        _requestBuilder(request, input, (request, input) => server.requestBuilder ?? server.requestBuilder(request, _method, input));
      }else if(server.requestBuilder != null){
        server.requestBuilder(request, _method, input);
      }
      return request.close();
    }).catchError(
      (e) => throw e
    );
    O output = _outputCreator == null ? null : _outputCreator(context);
    return await resp.then((HttpClientResponse response) async{
      try{
        if(_responseParser != null){
          await _responseParser(
            response,
            output,
            (response, output) async {
              try{
                return server.responseParser ?? await server.responseParser(response, _method, output);
              }catch(e){
                throw e;
              }
            }
          );
        }else if(server.responseParser != null){
          await server.responseParser(response, _method, output);
        }
      }catch(e){
        throw e;
      }
      context?.setOutput(name, output);
      return output;
    }).catchError(
      (e) => throw e
    );
  }
}

/// An aggregated API that calls multiple APIs in series.
///
/// For example
/// ```dart
/// Api api = SequencialApi<DataSet,List<Object>>(
///   name:"user search and get attribute",
///   apis:[
///     SingleApi<DataSet,DataSet>(
///       name:"user search",
///       serverName:"local server",
///       method:HttpMethod.POST,
///       path:"/users/search",
///       inputCreator: (context){
///         DataSet ds = DataSet("UserSearchRequest");
///         ds.setHeaderSchema(
///           RecordSchema(
///             [FieldSchema<String>("name")]
///           )
///         );
///         return ds;
///       },
///       outputCreator: (context){
///         DataSet ds = DataSet("UserSearchResponse");
///         ds.setRecorListSchema(
///           RecordSchema(
///             [FieldSchema<String>("id")]
///           )
///         );
///         return ds;
///       }
///     ),
///     SingleApi<DataSet,DataSet>(
///       name:"get attribute of users",
///       serverName:"local server",
///       method:HttpMethod.POST,
///       path:"/users",
///       inputCreator: (context){
///         DataSet ds = DataSet("UserAttributeRequest");
///         ds.setRecordListSchema(
///           RecordSchema(
///             [FieldSchema<String>("id")]
///           )
///         );
///         ds.getRecordList().fromRecordList(
///           ((context.getOutput("user search") as DataSet).getRecordList()
///         );
///         return ds;
///       }
///       outputCreator: (context){
///         DataSet ds = DataSet("UserAttributeResponse");
///         ds.setRecordListSchema(
///           RecordSchema(
///             [
///               FieldSchema<String>("id"),
///               FieldSchema<String>("name"),
///               FieldSchema<int>("age"),
///               FieldSchema<String>("tel")
///             ]
///           )
///         );
///         return ds;
///       }
///     )
///   ],
///   outputCreator : (context) => context.getOutput("get attribute of users")
/// );
/// 
/// RequestContext context = RequestContext();
/// DataSet requestDs = api.getInput(context);
/// requestDs.getHeader()["name"] = "hoge";
/// 
/// DataSet responseDs = await api.request(requestDs, context);
/// 
/// RecordList userList = responseDs.getRecordList();
/// ```
@immutable
class SequencialApi<I,O> extends Api<I,O>{
  final List<Api> _apis;
  final ApiInOutCreator<I> _inputCreator;
  final ApiInOutCreator<O> _outputCreator;

  SequencialApi(
    {
      @required String name,
      @required List<Api> apis,
      ApiInOutCreator<I> inputCreator,
      ApiInOutCreator<O> outputCreator
    }
  ): _apis = apis,
    _inputCreator = inputCreator,
    _outputCreator = outputCreator,
    super(name);
  
  @override
  I getInput(RequestContext context) => _inputCreator == null ? _apis[0].getInput(context) : _inputCreator(context);

  @override
  Future<O> request(I input, RequestContext context) async{
    context.setInput(name, input);
    Object inp = input;
    List<Object> outputs = List();
    for(int i = 0; i < _apis.length; i++){
      if(i != 0 || _inputCreator != null){
        inp = _apis[i].getInput(context);
      }
      outputs.add(await _apis[i].request(inp, context));
    }
    O output = _outputCreator == null ? outputs : _outputCreator(context);
    context.setOutput(name, output);
    return output;
 }
}

/// An aggregated API that calls multiple APIs in parallel.
///
/// For example
/// ```dart
/// Api templateApi = SingleApi<DataSet,DataSet>(
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
/// Api api = ParallelApi<List<Object>>(
///   name: "get users",
///   apis: [templateApi, templateApi]
/// );
/// 
/// RequestContext context = RequestContext();
/// List<DataSet> requests = api.getInput(context).cast();
/// requests[0].getHeader()["id"] = "0000001";
/// requests[1].getHeader()["id"] = "0000002";
/// 
/// List<DataSet> responses = (await api.request(requests, context)).cast();
/// 
/// Record userRecord1 = responses[0].getHeader();
/// Record userRecord2 = responses[1].getHeader();
/// ```
@immutable
class ParallelApi<O> extends Api<List<Object>,O>{
  final List<Api> _apis;
  final ApiInOutCreator<O> _outputCreator;
  ParallelApi(
    {
      @required String name,
      @required List<Api> apis,
      ApiInOutCreator<O> outputCreator
    }
  ): _apis = apis,
    _outputCreator = outputCreator,
    super(name);
  
  @override
  List<Object> getInput(RequestContext context){
    List<Object> inputs = List();
    for(Api api in _apis){
      inputs.add(api.getInput(context));
    }
    return inputs;
  }

  @override
  Future<O> request(List<Object> input, RequestContext context) async{
    context.setInput(name, input);
    List<Future<Object>> outputFutures = List();
    for(int i = 0; i < _apis.length; i++){
      outputFutures.add(_apis[i].request(input[i], context));
    }
    List<Object> outputs = List();
    for(Future outputFuture in outputFutures){
      Object output = await outputFuture;
      outputs.add(output);
    }
    context.setOutput(name, outputs);
    O output = _outputCreator == null ? outputs : _outputCreator(context);
    context.setOutput(name, output);
    return output;
 }
}