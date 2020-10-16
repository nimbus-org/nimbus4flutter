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

/// This is a library for developing Flutter applications that communicate with a web server built using [Project Nimbus](https://github.com/nimbus-org/nimbus).
/// 
/// It consists of the following two main functionalities
///  * [DataSet], which is a dynamic generic DTO.
///  * Abstraction of the server's API [Api]
library nimbus4flutter;

export 'package:meta/meta.dart' show
  immutable,
  required;

export 'src/dataset/field_schema.dart';
export 'src/dataset/record_schema.dart';
export 'src/dataset/record.dart';
export 'src/dataset/record_list.dart';
export 'src/dataset/dataset.dart';
export 'src/api/api_registory.dart';
export 'src/api/api.dart';
export 'src/api/api_server.dart';
export 'src/api_io/api.dart';
export 'src/api_io/api_server.dart';
export 'src/api_http/api.dart';
export 'src/api_http/api_server.dart';
export 'src/settings/settings.dart';
export 'src/test/test_controller.dart';
export 'src/test/test_scenario_group.dart';
export 'src/test/test_scenario.dart';
export 'src/test/test_case.dart';
