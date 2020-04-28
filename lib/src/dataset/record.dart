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

import 'dart:math';

class Record{

  final RecordSchema _schema;
  final Map<String,Object> _values;
  _RecordPrimaryKey _primaryKey;
  DataSet _dataSet;

  Record.empty() : _schema = null,_values=null,_primaryKey=null;

  Record(RecordSchema schema)
   : _schema = schema,
    _values = Map.fromIterable(schema.fields, key: (e) => e.name, value: (e) => e.defaultValue)
  {
    _primaryKey = schema.hasPrimary ? _RecordPrimaryKey(schema, _values) : null;
  }

  RecordSchema get schema => _schema;

  Object get primaryKey => _primaryKey;

  set dataSet(ds) => _dataSet = ds;

  DataSet get dataSet => _dataSet;

  _RecordMapAccessOperator<T> call<T>() => _RecordMapAccessOperator(this);

  Object operator [] (String name){
    return getByName(name);
  }

  void operator []=(String name, Object value){
    setByName(name, value);
  }

  bool containsName(String name) => _values.containsKey(name);

  T getByName<T>(String name){
    FieldSchema fs = _schema.fieldMap[name];
    if(fs == null){
      throw Exception("The specified field does not exist. name=$name, schema=$_schema");
    }
    Object value = fs.isView ? fs.viewValue(_dataSet, this) : _values[name];
    T ret;
    if(value == null){
      ret = null;
    }else{
      if(value is T){
        ret = value;
      }else{
        ret = fs.formatValue(value);
      }
    }
    return ret;
  }

  T getByIndex<T>(int index){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    return getByName(_schema.fields[index].name);
  }

  void setByName(String name, Object value){
    FieldSchema fs = _schema.fieldMap[name];
    if(fs == null){
      throw Exception("The specified field does not exist. name=$name, schema=$_schema");
    }
    if(fs.isView){
      throw Exception("The specified field is view. name=$name, schema=$_schema");
    }
    if(value != null){
      if(!fs.instanceof(value)){
        value = fs.parseValue(value);
        if(!fs.instanceof(value)){
          throw Exception("The type doesn't match. name=$name, type=${value.runtimeType}, schema=$_schema");
        }
      }
    }
    _values[name] = value;
  }

  void setByIndex(int index, Object value){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    setByName(_schema.fields[index].name, value);
  }

  Record createNestedRecordByName(String name){
    FieldSchema fs = _schema.fieldMap[name];
    if(fs == null){
      throw Exception("The specified field does not exist. name=$name, schema=$_schema");
    }
    if(fs.schema == null || fs.type != Record){
      throw Exception("The specified field does not record. name=$name, schema=$_schema");
    }
    return _dataSet.createNestedRecord(fs.schema);
  }

  Record createNestedRecordByIndex(int index){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    return createNestedRecordByName(_schema.fields[index].name);
  }

  RecordList createNestedRecordListByName(String name){
    FieldSchema fs = _schema.fieldMap[name];
    if(fs == null){
      throw Exception("The specified field does not exist. name=$name, schema=$_schema");
    }
    if(fs.schema == null || fs.type != RecordList){
      throw Exception("The specified field does not recordlist. name=$name, schema=$_schema");
    }
    return _dataSet.createNestedRecordList(fs.schema);
  }

  RecordList createNestedRecordListByIndex(int index){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    return createNestedRecordListByName(_schema.fields[index].name);
  }

  Object _getValue(FieldSchema field, bool toJsonType){
    Object value = _values[field.name];
    if(toJsonType
      && value != null
      && !(value is Record)
      && !(value is RecordList)
      && !(value is bool)
      && !(value is num)
      && !(value is String)
      && !(value is List<int>)
      && !(value is List<double>)
      && !(value is List<String>)
      && !(value is List<dynamic>)
    ){
      String str = getByName(field.name);
      value = str;
    }else{
      value = getByName(field.name);
    }
    return value;
  }

  Record fromRecord(Record record){
    for(String name in _schema.fieldMap.keys){
      if(record.containsName(name)){
        this[name] = record[name]; 
      }
    }
    return this;
  }

  Record fromMap(Map<String,Object> map){
    map.forEach(
      (name, value){
        if(containsName(name)){
          FieldSchema field = _schema.fieldMap[name];
          if(!field.isView){
            if(field.type == Record){
              setByName(name, _dataSet.createNestedRecord(field.schema).fromMap(value as Map<String,Object>));
            }else if(field.type == RecordList){
              setByName(name, _dataSet.createNestedRecordList(field.schema).fromMap(value as List<Map<String,Object>>));
            }else{
              setByName(name, value);
            }
          }
        }
      }
    );
    return this;
  }

  Map<String,Object> toMap({bool hasNull=true, bool toJsonType=false}){
    Map map = Map<String,Object>();
    for(FieldSchema field in _schema.fields){
      if(!field.isOutput){
        continue;
      }
      Object value = _getValue(field, toJsonType);
      if(!hasNull && value == null){
        continue;
      }
      if(field.type == Record){
        value = (value as Record).toMap(hasNull : hasNull, toJsonType:toJsonType);
      }else if(field.type == RecordList){
        value = (value as RecordList).toMap(hasNull : hasNull, toJsonType:toJsonType);
      }
      map[field.name] = value;
    }
    return map;
  }


  Record fromList(List<Object> list,[Map<String,Object> recordSchemaMap, Map<String,Object> schemaMap]){
    if(recordSchemaMap == null){
      for(int i = 0; i < min(list.length, _schema.length); i++){
        FieldSchema field = _schema.fields[i];
        Object value = list[i];
        if(field.isView){
          continue;
        }
        if(field.type == Record){
          value = _dataSet.createNestedRecord(field.schema).fromList(value as List<Object>);
        }else if(field.type == RecordList){
          value = _dataSet.createNestedRecordList(field.schema).fromList(value as List<List<Object>>);
        }
        setByIndex(i, value);
      }
    }else{
      Map<String,Object> nestedRecordSchemaMap = schemaMap == null ? null : schemaMap["nestedRecord"];
      Map<String,Object> nestedRecordListSchemaMap = schemaMap == null ? null : schemaMap["nestedRecordList"];
      for(int i = 0; i < _schema.length; i++){
        FieldSchema field = _schema.fields[i];
        if(field.isView){
          continue;
        }
        Map<String,Object> fieldSchemaMap = recordSchemaMap[field.name];
        if(fieldSchemaMap == null){
          continue;
        }
        Object value = list[fieldSchemaMap["index"]];
        if(field.type == Record){
          value = _dataSet.createNestedRecord(field.schema).fromList(
            value as List<Object>,
            nestedRecordSchemaMap == null ? null : nestedRecordSchemaMap[fieldSchemaMap["schema"]],
            schemaMap
          );
        }else if(field.type == RecordList){
          value = _dataSet.createNestedRecordList(field.schema).fromList(
            value as List<List<Object>>,
            nestedRecordListSchemaMap == null ? null : nestedRecordListSchemaMap[fieldSchemaMap["schema"]],
            schemaMap
          );
        }
        setByIndex(i, value);
      }
    }
    return this;
  }

  List<Object> toList({bool toJsonType=false}){
    List list = List();
    for(FieldSchema field in _schema.fields){
      if(!field.isOutput){
        continue;
      }
      Object value = _getValue(field, toJsonType);
      if(value != null){
        if(field.type == Record){
          value = (value as Record).toList(toJsonType:toJsonType);
        }else if(field.type == RecordList){
          value = (value as RecordList).toDeepList(toJsonType:toJsonType);
        }
      }
      list.add(value);
    }
    return list;
  }
  
  @override
  bool operator ==(dynamic other){
    if(!(other is Record)){
      return false;
    }
    if(_schema.hasPrimary){
      if(!other._schema.hasPrimary){
        return false;
      }
      if(_schema.primaryFieldMap.keys.toSet().difference(other._schema.primaryFieldMap.keys.toSet()).isNotEmpty){
        return false;
      }
      for(FieldSchema fs in _schema.primaryFields){
        if(_values[fs.name] != other._values[fs.name]){
          return false;
        }
      }
    }else{
      for (MapEntry<String, Object> entry in this._values.entries) {
        if(!other.containsName(entry.key)){
          return false;
        }
        if(entry.value != other._values[entry.key]){
          return false;
        }
      }
    }
    return true;
  }
  
  @override
  int get hashCode{
    int hashCode = 0;
    if(_schema.hasPrimary){
      for(FieldSchema fs in _schema.primaryFields){
        Object value = _values[fs.name];
        hashCode += value == null ? 0 : value.hashCode;
      }
   }else{
      for (Object value in this._values.values) {
        hashCode += value == null ? 0 : value.hashCode;
      }
    }
    return hashCode;
  }
  
  @override
  String toString() => "${super.toString()}{_values=$_values}";

  Record clone(){
    Record record = Record(this._schema);
    record.dataSet = _dataSet;
    record._values.addAll(_values);
    return record;
  }

  void clear(){
    _schema.fields.forEach((field) => _values[field.name]=field.defaultValue);
  }
}

class _RecordPrimaryKey{
  final Map<String,Object> _values;
  final RecordSchema _schema;

  const _RecordPrimaryKey(this._schema, this._values);

  @override
  bool operator ==(dynamic other){
    if(!(other is _RecordPrimaryKey)){
      return false;
    }
    if(_schema.primaryFieldMap.keys.toSet().difference(other._schema.primaryFieldMap.keys.toSet()).isNotEmpty){
      return false;
    }
    for(FieldSchema fs in _schema.primaryFields){
      if(_values[fs.name] != other._values[fs.name]){
        return false;
      }
    }
    return true;
  }
  
  @override
  int get hashCode{
    int hashCode = 0;
    for(FieldSchema fs in _schema.primaryFields){
      Object value = _values[fs.name];
      hashCode += value == null ? 0 : value.hashCode;
    }
    return hashCode;
  }
  
  @override
  String toString(){
    StringBuffer buf = StringBuffer(super.toString());
    buf.write('{');
    for(int i = 0; i < _schema.primaryFields.length; i++){
      if(i != 0){
        buf.write(',');
      }
      Object value = _values[_schema.primaryFields[i].name];
      buf.write(value);
    }
    buf.write('}');
    return buf.toString();
  }
}

class _RecordMapAccessOperator<T> {
    final Record record;

    const _RecordMapAccessOperator(this.record);

    T operator [](String name) => record.getByName(name);
}
