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

/// Register and manage [ApiServer] and [Api].
/// 
/// For example
/// ```dart
/// import 'dart:io';
/// import 'dart:convert';
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// ApiRegistory.registApiServer(
///   ApiServer(
///     name: "local server",
///     host: "localhost",
///     requestBuilder: (request, method, input) {
///       switch(method){
///         case HttpMethod.POST:
///         DataSet ds = input as DataSet;
///         request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
///         request.write(
///           JsonEncoder().convert(ds.toMap(toJsonType: true))
///         );
///         break;
///       default:
///         break;
///       }
///     },
///     responseParser: (response, method, output) async{
///       if(response.statusCode != 200){
///         throw new Exception("error status = ${response.statusCode}");
///       }
///       if(output != null){
///         DataSet ds = output as DataSet;
///         ds.fromMap(JsonDecoder().convert(await response.transform(Utf8Decoder()).join()));
///       }
///     },
///   )
/// );
/// 
/// ApiRegistory.registApi(
///   SingleApi<DataSet,DataSet>(
///     name: "get user",
///     serverName: "local server",
///     method:HttpMethod.POST
///     path:"/users",
///     inputCreator: (context){
///       DataSet ds = DataSet("Condition");
///       ds.setHeaderSchema(
///         RecordSchema([FieldSchema<String>("name")])
///       );
///       return ds;
///     },
///     outputCreator: (context){
///       DataSet ds = DataSet("User");
///       ds.setHeaderSchema(
///         RecordSchema(
///           [
///             FieldSchema<String>("name"),
///             FieldSchema<int>("age"),
///             FieldSchema<String>("tel"),
///             FieldSchema<String>("address1"),
///             FieldSchema<String>("address2")
///           ]
///         )
///       );
///       return ds;
///     }
///   )
/// );
/// 
/// Api api = ApiRegistory.getApi("get user");
/// RequestContext context = RequestContext();
/// DataSet request = api.getInput(context);
/// request.getHeader()["name"] = "hoge";
/// DataSet response = await api.request(request, context);
/// ```
class ApiRegistory{

  static final Map<String,ApiServer> apiServerRegistory = new Map();
  static final Map<String,Api> apiRegistory = new Map();

  /// Register [ApiServer].
  static registApiServer(ApiServer server){
    apiServerRegistory[server.name] = server;
  }
  
  /// Get [ApiServer] with the specified name
  static ApiServer? getApiServer(String name){
    return apiServerRegistory[name];
  }
  
  /// Register [Api].
  static registApi(Api api){
    apiRegistory[api.name] = api;
  }
  
  /// Get [Api] with the specified name
  static Api<I,O>? getApi<I, O>(String name){
    Api<dynamic?,dynamic?>? api = apiRegistory[name]; 
    return api == null ? null : api as Api<I,O>;
  }

  /// Close repository.
  static void close({bool force: false}){
    apiServerRegistory.values.forEach((server) {server.close(force:force);});
    apiRegistory.clear();
    apiServerRegistory.clear();
  } 
}
