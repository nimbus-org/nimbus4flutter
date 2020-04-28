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

typedef FieldConverter<I,O> = O Function(I input);
typedef FieldViewer<O> = O Function(DataSet ds, Record rec);

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

  FieldSchema(
    this._name,
    {
      T defaultValue,
      FieldConverter<dynamic,T> inputConverter,
      FieldConverter<T,dynamic> outputConverter,
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _type = T,
      _defaultValue = defaultValue,
      _inputConverter = inputConverter,
      _outputConverter = outputConverter,
      _fieldViewer = null,
      _isPrimary = isPrimary,
      _isOutput = isOutput,
      _schema = null;

  FieldSchema.record(
    this._name,
    this._schema,
    {
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _type = Record,
      _defaultValue = null,
      _inputConverter = null,
      _outputConverter = null,
      _fieldViewer = null,
      _isOutput = isOutput,
      _isPrimary = isPrimary;
  
  FieldSchema.list(
    this._name,
    this._schema,
    {
      bool isPrimary = false,
      bool isOutput = true
    }
  ) : _type = RecordList,
      _defaultValue = null,
      _inputConverter = null,
      _outputConverter = null,
      _fieldViewer = null,
      _isOutput = isOutput,
      _isPrimary = isPrimary;
  
  FieldSchema.view(
    this._name,
    this._fieldViewer,
    {
      T defaultValue,
      FieldConverter<T,dynamic> outputConverter,
      bool isOutput = true
    }
  ) : _type = T,
      _defaultValue = defaultValue,
      _inputConverter = null,
      _outputConverter = outputConverter,
      _isOutput = isOutput,
      _isPrimary = false,
      _schema = null;

  get name => _name;
  get type => _type;
  get defaultValue => _defaultValue;
  get isPrimary => _isPrimary;
  get isOutput => _isOutput;
  get isView => _fieldViewer != null;
  get schema => _schema;
  bool get hasInputConverter => _inputConverter != null; 
  bool get hasOutputConverter => _outputConverter != null; 
  
  bool instanceof(Object value) => value == null ? true : value is T;

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
  
  T viewValue(DataSet ds, Record record){
    return _fieldViewer == null ? defaultValue : _fieldViewer(ds, record);
  }
  
  @override
  String toString() => "${super.toString()}{name=$_name,type=$_type,isPrimary=$_isPrimary,isOutput=$_isOutput,isView=$isView,inputConverter=$_inputConverter,outputConverter=$_outputConverter,schema=$_schema}";
}