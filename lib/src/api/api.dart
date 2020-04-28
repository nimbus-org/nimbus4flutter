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


class RequestContext{
  Map<String,Object> inputs = Map();
  Map<String,Object> outputs = Map();
  Map<String,Object> attributes = Map();

  RequestContext();

  I getInput<I>(String api){
    return inputs[api] as I;
  }
  void setInput(String api, Object input){
    inputs[api] = input;  
  }

  O getOutput<O>(String api){
    return outputs[api] as O;
  }
  void setOutput(String api, Object output){
    outputs[api] = output;  
  }

  T getAttribute<T>(String name){
    return attributes[name];
  }
  void setAttribute(String name, Object output){
    attributes[name] = output;  
  }
}

abstract class Api<I,O>{
  final String _name;
  Api(
    String name
  ) : _name = name;

  get name => _name;

  I getInput(RequestContext context);
  Future<O> request(I input, RequestContext context);
}



typedef ApiInOutCreator<T> = T Function(RequestContext context);
typedef HttpClientRequestBuilder<I> = void Function(HttpClientRequest request, I input, Function(HttpClientRequest request, I input) serverBuilder);
typedef HttpClientResponseParser<O> = Future<void> Function(HttpClientResponse response, O output, Function(HttpClientResponse response, O output) serverParser);

enum HttpMethod{
  GET,
  POST,
  PUT,
  HEAD,
  PATCH,
  DELETE
}

@immutable
class SingleApi<I,O> extends Api<I,O>{
  final String _serverName;
  final HttpMethod _method;
  final String _path;
  final ApiInOutCreator<I> _inputCreator;
  final ApiInOutCreator<O> _outputCreator;
  final HttpClientRequestBuilder<I> _requestBuilder;
  final HttpClientResponseParser<O> _responseParser;

  SingleApi(
    {
      @required String name,
      @required String  serverName,
      @required HttpMethod method,
      @required String path,
      ApiInOutCreator<I> inputCreator,
      ApiInOutCreator<O> outputCreator,
      HttpClientRequestBuilder<I> requestBuilder,
      HttpClientResponseParser<O> responseParser
    }
  ) : _serverName = serverName,
    _method = method,
    _path = path,
    _inputCreator = inputCreator,
    _outputCreator = outputCreator,
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
    switch(_method){
    case HttpMethod.GET:
      req = server.client.get(server.host, server.port, _path);
      break;
    case HttpMethod.POST:
      req = server.client.post(server.host, server.port, _path);
      break;
    case HttpMethod.PUT:
      server.client.put(server.host, server.port, _path);
      break;
    case HttpMethod.PATCH:
      server.client.patch(server.host, server.port, _path);
      break;
    case HttpMethod.HEAD:
      server.client.head(server.host, server.port, _path);
      break;
    case HttpMethod.DELETE:
      server.client.delete(server.host, server.port, _path);
      break;
    }
    Future<HttpClientResponse> resp = req.then((HttpClientRequest request){
      if(_requestBuilder != null){
        _requestBuilder(request, input, (request, input) => server.requestBuilder ?? server.requestBuilder(request, _method, input));
      }else if(server.requestBuilder != null){
        server.requestBuilder(request, _method, input);
      }
      return request.close();
    });
    O output = _outputCreator == null ? null : _outputCreator(context);
    return await resp.then((HttpClientResponse response) async{
      if(_responseParser != null){
        await _responseParser(response, output, (response, output) async => server.responseParser ?? await server.responseParser(response, _method, output));
      }else if(server.responseParser != null){
        await server.responseParser(response, _method, output);
      }
      context?.setOutput(name, output);
      return output;
    });
  }
}

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