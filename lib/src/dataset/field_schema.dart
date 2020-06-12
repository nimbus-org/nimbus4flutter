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

import 'dart:core';

import 'package:nimbus4flutter/nimbus4flutter.dart';

/// This function is used for input conversion and output conversion of a field.
typedef FieldConverter<I,O> = O Function(I input);

/// This function is used for the view of a field.
typedef FieldViewer<O> = O Function(DataSet ds, Record rec, O defaultValue);

/// Define the schema for the fields in [Record] and [RecordList].
/// 
/// There are four different schemas, and there are different constructors for them.
/// 1. normal field
/// For example
/// ```dart
/// FieldSchema<String>("field1")
/// ```
/// 
/// 2. nested [Record] field
/// For example
/// ```dart
/// FieldSchema.record("field2", "NestedRecord1")
/// ```
/// 
/// 3. nested [RecordList] field.
/// For example
/// ```dart
/// FieldSchema.list("field3", "NestedRecordList1")
/// ```
/// 
/// 4. view field that has no entity
/// For example
/// Example for 4
/// ```dart
/// FieldSchema.view(
///   "field4",
///   (ds, rec, dv)=> ds == null || rec == null ? dv : (rec["field1"] as String) + ds.getHeader()["field2"]
/// )
/// ```
@immutable
class FieldSchema<T>{
  final String _name;
  final Type _type;
  final Object _defaultValue;
  final FieldConverter<dynamic,T> _inputConverter;
  final FieldConverter<T,dynamic> _outputConverter;
  final FieldViewer<T> _fieldViewer;
  final bool _isPrimary;
  final bool _isOutput;
  final String _schema;
  final bool _isRecord;
  final bool _isRecordList;

  /// Define a normal field.
  /// 
  /// In [name], define the name of the field.
  /// In [defaultValue], define the initial value of the field. If not specified, the default value is null.
  /// In [inputConverter], define the input conversion to the field.If the type of the field defined by the nominal type does not match the type of the field to be set, it will be converted to match the type of the field.Also, even if [inputConverter] is not specified, some types will be converted automatically. For more information, see the implementation of [parseValue()].
  /// In [outputConverter], define the output conversion to the field.If the type of the field defined by the nominal type does not match the type to be retrieved from the field, it will be converted to match the type to be retrieved.Also, some types will be converted automatically even if [outputConverter] is not specified. For more information, see the implementation of [formatValue()].
  /// In [isPrimary], define that this field constitutes the primary key. This argument is only valid for field definitions in RecordList.
  /// In [isOutput], define that this field should be output to a Map or List.
  FieldSchema(
    String name,
    {
      T defaultValue,
      FieldConverter<dynamic,T> inputConverter,
      FieldConverter<T,dynamic> outputConverter,
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _name = name,
      _type = T,
      _defaultValue = defaultValue,
      _inputConverter = inputConverter,
      _outputConverter = outputConverter,
      _fieldViewer = null,
      _isPrimary = isPrimary,
      _isOutput = isOutput,
      _isRecord = false,
      _isRecordList = false,
      _schema = null;

  /// Define the nested [Record] field.
  /// 
  /// In [name], define the name of the field.
  /// In [schema], define the name of the schema.
  /// In [isPrimary], define that this field constitutes the primary key. This argument is only valid for field definitions in RecordList.
  /// In [isOutput], define that this field should be output to a Map or List.
  FieldSchema.record(
    String name,
    String schema,
    {
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _name = name,
      _schema = schema,
      _type = Record,
      _defaultValue = null,
      _inputConverter = null,
      _outputConverter = null,
      _fieldViewer = null,
      _isOutput = isOutput,
      _isRecord = true,
      _isRecordList = false,
      _isPrimary = isPrimary;
  
  /// Define the nested [RecordList] field.
  /// 
  /// In [name], define the name of the field.
  /// In [schema], define the name of the schema.
  /// In [isPrimary], define that this field constitutes the primary key. This argument is only valid for field definitions in RecordList.
  /// In [isOutput], define that this field should be output to a Map or List.
  FieldSchema.list(
    String name,
    String schema,
    {
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _name = name,
      _schema = schema,
      _type = RecordList,
      _defaultValue = null,
      _inputConverter = null,
      _outputConverter = null,
      _fieldViewer = null,
      _isOutput = isOutput,
      _isRecord = false,
      _isRecordList = true,
      _isPrimary = isPrimary;
  
  /// Define the view field that has no entity.
  /// 
  /// This type of field can be edited or combined with other fields in the same DataSet and Record to represent a value. This field does not have a value that is an entity of its own, so it cannot be set to a value.
  /// 
  /// In [name], define the name of the field.
  /// In fieldViewer, define how to get the value of this field.
  /// In [defaultValue], define the initial value of the field. If not specified, the default value is null.
  /// In [outputConverter], define the output conversion to the field.If the type of the field defined by the nominal type does not match the type to be retrieved from the field, it will be converted to match the type to be retrieved.Also, some types will be converted automatically even if [outputConverter] is not specified. For more information, see the implementation of [formatValue()].
  /// In [isOutput], define that this field should be output to a Map or List.
  FieldSchema.view(
    String name,
    FieldViewer<T> fieldViewer,
    {
      T defaultValue,
      FieldConverter<T,dynamic> outputConverter,
      bool isOutput = true
    }
  ) : _name = name,
      _fieldViewer = fieldViewer,
      _type = T,
      _defaultValue = defaultValue,
      _inputConverter = null,
      _outputConverter = outputConverter,
      _isOutput = isOutput,
      _isRecord = false,
      _isRecordList = false,
      _isPrimary = false,
      _schema = null;

  /// The name of the field.
  String get name => _name;

  /// The type of the field.
  Type get type => _type;

  /// The default value for the field.
  Object get defaultValue => _defaultValue;

  /// The flag whether the field is a component of the primary key or not.
  bool get isPrimary => _isPrimary;

  /// The flag whether the field is output or not.
  bool get isOutput => _isOutput;

  /// The flag whether the field is a view or not
  bool get isView => _fieldViewer != null;

  /// The flag whether the field is a [Record] or not
  bool get isRecord => _isRecord;

  /// The flag whether the field is a [RecordList] or not
  bool get isRecordList => _isRecordList;

  /// The schema name when the field is a nested [Record] or [RecordList].
  String get schema => _schema;

  /// The flag whether or not an input conversion is present in the field.
  bool get hasInputConverter => _inputConverter != null; 

  /// The flag whether or not an output conversion is present in the field.
  bool get hasOutputConverter => _outputConverter != null; 
  
  /// Determines if the specified object is assignable to the type of this field.
  bool instanceof(Object value) => value == null ? true : value is T;

  /// Input conversion of the specified object to match the type of this field.
  Object parseValue(Object inputValue){
    if(_inputConverter == null){
      if(inputValue == null || instanceof(inputValue)){
        return inputValue;
      }else{
        if(_type == String){
          return inputValue.toString();
        }else if(inputValue is String){
          if(_type == int){
            return int.parse(inputValue);
          }else if(_type == double){
            return double.parse(inputValue);
          }else if(_type == bool){
            return (inputValue.toLowerCase() == 'true'
              || inputValue.toLowerCase() == 'on'
              || inputValue == '1');
          }
        }
        return inputValue;
      }
    }else{
      return _inputConverter(inputValue);
    }
  }


  /// Converts the specified object suitable for the type of this field to an output that matches the specified generic type.
  F formatValue<F>(T value){
     if(_outputConverter == null){
       if(value == null || value is F){
        return value as F;
      }else{
        if(F == String){
          return value.toString() as F;
        }else if(value is String){
          if(F == int){
            return int.parse(value) as F;
          }else if(F == double){
            return double.parse(value) as F;
          }else if(F == bool){
            return (value.toLowerCase() == 'true'
              || value.toLowerCase() == 'on'
              || value == '1') as F;
          }
        }
        return value as F;
      }
    }else{
       return _outputConverter(value);
     }
  }
  
  /// If this field is a view, it will return a value using the specified [DataSet] and [Record].
  T viewValue(DataSet ds, Record record){
    return _fieldViewer == null ? defaultValue : _fieldViewer(ds, record, defaultValue);
  }
  
  @override
  String toString() => "${super.toString()}{name=$_name,type=$_type,isPrimary=$_isPrimary,isOutput=$_isOutput,isView=$isView,inputConverter=$_inputConverter,outputConverter=$_outputConverter,schema=$_schema}";
}