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

import 'dart:async';
import 'package:nimbus4flutter/nimbus4flutter.dart';

/// Processing context of a request to the server.
class RequestContext{
  Map<String,Object> _inputs = Map();
  Map<String,Object> _outputs = Map();
  Map<String,Object> _attributes = Map();
  dynamic exception;

  RequestContext();

  /// Get the input DTO of a specified API name.
  I? getInput<I>(String api){
    return _inputs[api] as I;
  }

  /// Set the input DTO of a specified API name.
  void setInput(String api, Object? input){
    _inputs[api] = input!;  
  }

  /// Get the output DTO of a specified API name.
  O getOutput<O>(String api){
    return _outputs[api] as O;
  }

  /// Set the output DTO of a specified API name.
  void setOutput(String api, Object? output){
    _outputs[api] = output!;  
  }

  /// Get attribute of a specified name.
  T? getAttribute<T>(String name){
    return _attributes[name] as T;
  }

  /// Set attribute of a specified name.
  void setAttribute(String name, Object output){
    _attributes[name] = output;  
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
  I? getInput(RequestContext context);

  /// Request to the server.
  Future<O?> request(I? input, RequestContext context);
}

/// Function to create a DTO for input and output to an API.
typedef ApiInOutCreator<T> = T? Function(RequestContext context);

/// Function to create a DTO for input and output to an API.
typedef UriBuilder<I> = Uri Function(String scheme, String host, int? port, String path, I? input, RequestContext context, Function(String scheme, String host, int port, String path, I? input)? serverBuilder);

/// HTTP Methods enumeration.
enum HttpMethod{
  GET,
  POST,
  PUT,
  HEAD,
  PATCH,
  DELETE
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
  final ApiInOutCreator<I>? _inputCreator;
  final ApiInOutCreator<O>? _outputCreator;

  SequencialApi(
    {
      required String name,
      required List<Api> apis,
      ApiInOutCreator<I>? inputCreator,
      ApiInOutCreator<O>? outputCreator
    }
  ): _apis = apis,
    _inputCreator = inputCreator,
    _outputCreator = outputCreator,
    super(name);
  
  @override
  I? getInput(RequestContext context) => _inputCreator == null ? _apis[0].getInput(context) : _inputCreator!(context);

  @override
  Future<O?> request(I? input, RequestContext context) async{
    context.setInput(name, input);
    Object? inp = input;
    List<Object> outputs = [];
    for(int i = 0; i < _apis.length; i++){
      if(i != 0 || _inputCreator != null){
        inp = _apis[i].getInput(context);
      }
      outputs.add(await _apis[i].request(inp, context));
    }
    Object? output = _outputCreator == null ? outputs : _outputCreator!(context);
    context.setOutput(name, output);
    return output == null ? null : output as O;
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
  final ApiInOutCreator<O>? _outputCreator;
  ParallelApi(
    {
      required String name,
      required List<Api> apis,
      ApiInOutCreator<O>? outputCreator
    }
  ): _apis = apis,
    _outputCreator = outputCreator,
    super(name);
  
  @override
  List<Object> getInput(RequestContext context){
    List<Object> inputs = [];
    for(Api api in _apis){
      inputs.add(api.getInput(context));
    }
    return inputs;
  }

  @override
  Future<O?> request(List<Object>? input, RequestContext context) async{
    context.setInput(name, input);
    List<Future<dynamic>> outputFutures = [];
    for(int i = 0; i < _apis.length; i++){
      outputFutures.add(_apis[i].request(input == null ? null : input[i], context));
    }
    List<Object> outputs = [];
    for(Future outputFuture in outputFutures){
      Object output = await outputFuture;
      outputs.add(output);
    }
    context.setOutput(name, outputs);
    Object? output = _outputCreator == null ? outputs : _outputCreator!(context);
    context.setOutput(name, output);
    return output == null ? null : output as O;
 }
}