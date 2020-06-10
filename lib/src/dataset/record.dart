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

/// Record is a dynamic DTO that represents a one-dimensional data structure.
/// 
/// For example
/// ```dart
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// Record record = Record(
///   RecordSchema(
///     [
///       FieldSchema<String>("name"),
///       FieldSchema<int>("age")
///     ]
///   )
/// );
/// record["name"] = "hoge";
/// record["age"] = 20;
/// ```
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

  /// Schema definition
  RecordSchema get schema => _schema;

  /// Primary key
  Object get primaryKey => _primaryKey;

  /// The parent DataSet, which is null if it is an independent record.
  DataSet get dataSet => _dataSet;
  set dataSet(ds) => _dataSet = ds;

  _RecordMapAccessOperator<T> call<T>() => _RecordMapAccessOperator(this);

  /// Get the value of the specified field name.
  Object operator [] (String name){
    return getByName(name);
  }

  /// Set the value of the specified field name.
  void operator []=(String name, Object value){
    setByName(name, value);
  }

  /// Check if a field with the given name exists.
  bool containsName(String name) => _values.containsKey(name);

  /// Get the value of the specified field name.
  /// 
  /// If the type of the requested return value is different from the type of this field defined, then an output conversion is performed.
  /// And if you specify a field name that is not defined, it throws an exception.
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

  /// Get the value of the specified field index.
  /// 
  /// If the type of the requested return value is different from the type of this field defined, then an output conversion is performed.
  /// And if you specify a field index that is not defined, it throws an exception.
  T getByIndex<T>(int index){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    return getByName(_schema.fields[index].name);
  }

  /// Set the value of the specified field name.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field name that is not defined.
  ///  * If you specify a field that is a view.
  ///  * If input conversion is not possible.
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

  /// Set the value of the specified field index.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field index that is not defined.
  ///  * If you specify a field that is a view.
  ///  * If input conversion is not possible.
  void setByIndex(int index, Object value){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    setByName(_schema.fields[index].name, value);
  }

  /// Create a nested [Record] with the specified field name.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field name that is not defined.
  ///  * If the specified field is not a nested [Record].
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

  /// Create a nested [Record] with the specified field index.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field index that is not defined.
  ///  * If the specified field is not a nested [Record].
  Record createNestedRecordByIndex(int index){
    if(index < 0 || index >= _schema.length){
      throw Exception("The specified field does not exist. index=$index, schema=$_schema");
    }
    return createNestedRecordByName(_schema.fields[index].name);
  }

  /// Create a nested [RecordList] with the specified field name.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field name that is not defined.
  ///  * If the specified field is not a nested [RecordList].
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

  /// Create a nested [RecordList] with the specified field index.
  /// 
  /// It throw exceptions in the following cases.
  ///  * If you specify a field index that is not defined.
  ///  * If the specified field is not a nested [RecordList].
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

  /// Copies the value of the specified record to this record.
  Record fromRecord(Record record){
    for(String name in _schema.fieldMap.keys){
      if(record.containsName(name)){
        this[name] = record[name]; 
      }
    }
    return this;
  }

  /// Copies the value of the specified Map to this record.
  Record fromMap(Map<String,Object> map){
    map.forEach(
      (name, value){
        if(containsName(name)){
          FieldSchema field = _schema.fieldMap[name];
          if(!field.isView){
            if(field.isRecord){
              if(value is Map){
                setByName(name, _dataSet.createNestedRecord(field.schema).fromMap(value));
              }
            }else if(field.isRecordList){
              if(value is List){
                setByName(name, _dataSet.createNestedRecordList(field.schema).fromMap(value));
              }else if(value is Map){
                setByName(name, _dataSet.createNestedRecordList(field.schema).fromMapByMap(value));
              }
            }else{
              setByName(name, value);
            }
          }
        }
      }
    );
    return this;
  }

  /// Output the value of this record to the Map
  /// 
  /// If [hasNull] is set to false, fields with a value of null will not be output. this can be used to reduce the output when there is no need to tell that they are null.
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
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
      if(field.isRecord){
        value = (value as Record).toMap(hasNull : hasNull, toJsonType:toJsonType);
      }else if(field.isRecordList){
        value = (value as RecordList).toMap(hasNull : hasNull, toJsonType:toJsonType);
      }
      map[field.name] = value;
    }
    return map;
  }


  /// Copies the value of the specified List to this record.
  /// 
  /// If there is no guarantee that the schema of the List matches the schema of this record, specify the schema map of this record in [recordSchemaMap], and the schema map of the entire [DataSet] in [schemaMap] if there is a nested [Record] or [RecordList].
  Record fromList(List<Object> list,[Map<String,Object> recordSchemaMap, Map<String,Object> schemaMap]){
    if(recordSchemaMap == null){
      for(int i = 0; i < min(list.length, _schema.length); i++){
        FieldSchema field = _schema.fields[i];
        Object value = list[i];
        if(field.isView){
          continue;
        }
        if(field.isRecord){
          value = _dataSet.createNestedRecord(field.schema).fromList(value as List<Object>);
        }else if(field.isRecordList){
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
        if(field.isRecord){
          value = _dataSet.createNestedRecord(field.schema).fromList(
            value as List<Object>,
            nestedRecordSchemaMap == null ? null : nestedRecordSchemaMap[fieldSchemaMap["schema"]],
            schemaMap
          );
        }else if(field.isRecordList){
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

  /// Output the value of this record to the List
  /// 
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
  List<Object> toList({bool toJsonType=false}){
    List list = List();
    for(FieldSchema field in _schema.fields){
      if(!field.isOutput){
        continue;
      }
      Object value = _getValue(field, toJsonType);
      if(value != null){
        if(field.isRecord){
          value = (value as Record).toList(toJsonType:toJsonType);
        }else if(field.isRecordList){
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

  /// Clone the data.
  Record clone(){
    Record record = cloneEmpty();
    record.dataSet = _dataSet;
    record._values.addAll(_values);
    return record;
  }

  Record cloneEmpty(){
    return Record(_schema);
  }

  /// Clear the data.
  /// The set schema information will not be cleared.
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
