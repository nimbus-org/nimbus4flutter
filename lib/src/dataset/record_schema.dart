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


/// Define the schema for [Record].
@immutable
class RecordSchema{
  
  final List<FieldSchema> _fields;
  final Map<String,FieldSchema> _fieldMap;
  final List<FieldSchema> _primaryFields;
  final Map<String,FieldSchema> _primaryFieldMap;

  RecordSchema(List<FieldSchema> fields)
    : _fields = fields,
      _fieldMap = Map.fromIterable(fields, key: (e) => e.name),
      _primaryFields = List.from(fields.where((e) => e.isPrimary)),
      _primaryFieldMap = Map.fromIterable(fields.where((e) => e.isPrimary), key: (e) => e.name);

  /// List of all [FieldSchema].
  List<FieldSchema> get fields => _fields;

  /// List of [FieldSchema] to configure the primary key.
  List<FieldSchema> get primaryFields => _primaryFields;
  
  /// Map of all [FieldSchema].
  Map<String,FieldSchema> get fieldMap => _fieldMap;
  
  /// Map of [FieldSchema] to configure the primary key.
  Map<String,FieldSchema> get primaryFieldMap => _primaryFieldMap;
  
  /// Number of fields.
  int get length => _fields.length;
  
  /// Iterable of field names;
  Iterable<String> get names => _fields.map((e)=>e.name);

  /// Flag as having a primary key.
  bool get hasPrimary => _primaryFields.isNotEmpty;
  
  @override
  String toString() => "${super.toString()}{fields=$_fields}";

  /// Output the schema to Map
  Map<String,Object> toMap(){
    Map<String,Object> map = Map();
    for(int i = 0 ;i < _fields.length; i++){
      FieldSchema field = fields[i];
      String type = "value";
      if(field.type == Record){
        type = "nestedRecord";
      }else if(field.type == RecordList){
        type = "nestedRecordList";
      }

      map[field.name] = {
        "index" : i,
        "type"  : type
      };
      if(type != "value"){
        (map[field.name]! as Map<String,Object?>)["schema"] = field.schema;
      }
    }
    return map;
  }
}
