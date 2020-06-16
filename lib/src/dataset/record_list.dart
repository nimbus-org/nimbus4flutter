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

import 'dart:math';

import 'package:nimbus4flutter/nimbus4flutter.dart';

/// RecordList is a dynamic DTO that represents a two-dimensional data structure.
/// 
/// For example
/// ```dart
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// RecordList list = RecordList(
///   RecordSchema(
///     [
///       FieldSchema<String>("name"),
///       FieldSchema<int>("age")
///     ]
///   )
/// );
/// Record record1 = list.createRecord();
/// record1["name"] = "hoge";
/// record1["age"] = 20;
/// list.add(record1);
/// Record record2 = list.createRecord();
/// record2["name"] = "fuga";
/// record2["age"] = 15;
/// list.add(record2);
/// ```
class RecordList implements List<Record>{

  final RecordSchema _schema;
  final List<Record> _records;
  final Map<Object,Record> _primaryKeyMap;
  DataSet _dataSet;

  RecordList(RecordSchema schema)
   : _schema = schema,
    _records = List<Record>(),
    _primaryKeyMap = schema.hasPrimary ? Map<Object,Record>() : null;

  /// Schema definition
  RecordSchema get schema => _schema;

  /// The parent DataSet, which is null if it is an independent RecordList.
  set dataSet(ds){
    _dataSet = ds;
    _records?.forEach((record) => record.dataSet = ds);
  }
  DataSet get dataSet => _dataSet;

  @override
  Record get first => _records.first;

  @override
  set first(Record value){
    if(_records.length == 0){
      add(value);
    }else{
      this[0] = value;
    }
  }

  @override
  Record get last => _records.last;

  @override
  set last(Record value){
    if(_records.length == 0){
      add(value);
    }else{
      this[this.length - 1] = value;
    }
  }

  @override
  int get length => _records.length;

  @override
  set length(int value) => _records.length = value;

  @override
  Record get single => _records.single;

  @override
  bool get isEmpty => _records.isEmpty;
  
  @override
  bool get isNotEmpty => _records.isNotEmpty;
  
  @override
  Iterator<Record> get iterator => _records.iterator;

  @override
  Iterable<Record> get reversed => _records.reversed;

  @override
  Record operator [](int index) {
    return _records[index];
  }

  @override
  void operator []=(int index, Record value){
    if(_schema.hasPrimary && _primaryKeyMap.containsKey(value.primaryKey)){
      Record removeRecord = _records[index];
      if(value.primaryKey != removeRecord.primaryKey){
        throw Exception("Primary key is duplicate.primaryKey=${value.primaryKey}");
      }
      _primaryKeyMap[value.primaryKey] = value;
    }
    _records[index]=value;
  }

  @override
  List<Record> operator +(List<Record> other) {
    for(Record record in other){
      add(record);
    }
    return this;
  }

  @override
  void add(Record value){
    if(_schema.hasPrimary){
      if(_primaryKeyMap.containsKey(value.primaryKey)){
        throw Exception("Primary key is duplicate.primaryKey=${value.primaryKey}");
      }
      _primaryKeyMap[value.primaryKey] = value;
    }
    _records.add(value);
  }

  @override
  void addAll(Iterable<Record> iterable){
    for(Record record in iterable){
      add(record);
    }
  }

  @override
  bool any(bool test(Record element)) {
    return _records.any(test);
  }

  @override
  Map<int, Record> asMap() {
    return _records.asMap();
  }

  @override
  List<R> cast<R>() {
    return _records.cast();
  }

  @override
  void clear() {
    if(_schema.hasPrimary){
      _primaryKeyMap.clear();
    }
    _records.clear();
  }

  @override
  bool contains(Object element) {
    return _records.contains(element);
  }

  /// Check if a field with the given name exists.
  bool containsName(String name) => _schema.fieldMap.containsKey(name);

  // Create a Record.
  // 
  // To create a record with a value, specify [values]. Without arguments, it is the same as calling [fromMap()] after calling this method.
  Record createRecord({Map<String,Object> values}){
    Record record = Record(_schema);
    record.dataSet = _dataSet;
    if(values != null){
      record.fromMap(values);
    }
    return record;
  }

  @override
  Record elementAt(int index) {
    return _records.elementAt(index);
  }
  
  @override
  bool every(bool Function(Record element) test) {
    return _records.every(test);
  }
  
  @override
  Iterable<T> expand<T>(Iterable<T> f(Record element)){
    return _records.expand(f);
  }

  @override
  void fillRange(int start, int end, [Record fillValue]) {
    _records.fillRange(start, end, fillValue);
  }

  @override
  Record firstWhere(bool test(Record element), {Record orElse()}) {
    return _records.firstWhere(test, orElse:orElse);
  }
   
  
  @override
  T fold<T>(T initialValue, T combine(T previousValue, Record element)){
    return _records.fold(initialValue, combine);
  }
   
  @override
  Iterable<Record> followedBy(Iterable<Record> other) {
    return _records.followedBy(other);
  }
  
  @override
  void forEach(void Function(Record element) f) {
    _records.forEach(f);
  }

  /// Copies the value of the specified RecordList to this RecordList.
  RecordList fromRecordList(RecordList list){
    list.forEach(
      (value){
        Record rec = createRecord();
        rec.fromRecord(value);
        add(rec);
      }
    );
    return this;
  }

  /// Copies the value of the specified List to this RecordList.
  RecordList fromMap(List<dynamic> list){
    list.forEach(
      (value){
        Record rec = createRecord();
        rec.fromMap(value);
        add(rec);
      }
    );
    return this;
  }

  /// Copies the value of the specified Map to this RecordList.
  RecordList fromMapByMap(Map<dynamic, dynamic> map){
    if(schema.hasPrimary && schema.primaryFields.length == 1){
      map.forEach(
        (key, value){
          Record rec = createRecord();
          schema.fields.forEach(
            (field){
              if(field.isPrimary){
                rec.setByName(field.name, key);
              }else{
                if(value is Map){
                  if(field.isRecord){
                    rec.setByName(field.name, _dataSet.createNestedRecord(field.schema).fromMap(value));
                  }else{
                    rec.fromMap(value);
                  }
                }else if(value is List && field.isRecordList){
                  rec.setByName(field.name, _dataSet.createNestedRecordList(field.schema).fromMap(value));
                }else{
                  rec.setByName(field.name, value);
                }
              }
            }
          );
          add(rec);
        }
      );
    }else{
      return this;
    }
    return this;
  }

  /// Output the value of this record to the List
  /// 
  /// If [hasNull] is set to false, fields with a value of null will not be output. this can be used to reduce the output when there is no need to tell that they are null.
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
  List<Map<String,Object>> toMap({bool hasNull=true,bool toJsonType=false}){
    List<Map<String,Object>> list = List();
    Iterator<Record> itr = iterator;
    while(itr.moveNext()){
      list.add(itr.current.toMap(hasNull:hasNull, toJsonType:toJsonType));
    }
    return list;
  }

  /// Copies the value of the specified List to this RecordList.
  /// 
  /// If there is no guarantee that the schema of the List matches the schema of this record, specify the schema map of this record in [recordSchemaMap], and the schema map of the entire [DataSet] in [schemaMap] if there is a nested [Record] or [RecordList].
  RecordList fromList(List<List<Object>> list,[Map<String,Object> recordListSchemaMap, Map<String,Object> schemaMap]){
    list.forEach(
      (value){
        Record rec = createRecord();
        rec.fromList(value, recordListSchemaMap, schemaMap);
        add(rec);
      }
    );
    return this;
  }

  /// Output the value of this RecordList to the List
  /// 
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
  List<List<Object>> toDeepList({bool toJsonType=false}){
    List<List<Object>> list = List();
    Iterator<Record> itr = iterator;
    while(itr.moveNext()){
      list.add(itr.current.toList(toJsonType:toJsonType));
    }
    return list;
  }
  
  @override
  Iterable<Record> getRange(int start, int end) {
    return _records.getRange(start, end);
  }
  
  @override
  int indexOf(Record element, [int start = 0]) {
    return _records.indexOf(element, start);
  }
  
  @override
  int indexWhere(bool Function(Record element) test, [int start = 0]) {
    return _records.indexWhere(test, start);
  }
  
  @override
  void insert(int index, Record value) {
    if(_schema.hasPrimary){
      if(_primaryKeyMap.containsKey(value.primaryKey)){
        throw Exception("Primary key is duplicate.primaryKey=${value.primaryKey}");
      }
      _primaryKeyMap[value.primaryKey] = value;
    }
    _records.insert(index, value);
  }

  @override
  void insertAll(int index, Iterable<Record> iterable) {
    for(Record record in iterable){
      insert(index++, record);
    }
  }
  
  @override
  String join([String separator = ""]) {
    return _records.join(separator);
  }
  
  @override
  int lastIndexOf(Record element, [int start]) {
    return _records.lastIndexOf(element, start);
  }
  
  @override
  int lastIndexWhere(bool Function(Record element) test, [int start]) {
    return _records.lastIndexWhere(test, start);
  }
  
  @override
  Record lastWhere(bool Function(Record element) test, {Record Function() orElse}) {
    return _records.lastWhere(test, orElse:orElse);
  }
  
  @override
  Iterable<T> map<T>(T Function(Record element) test){
    return _records.map(test);
  }

  /// Primary key search with the specified [Record] as the key.
  Record primary(Record key){
    if(!_schema.hasPrimary){
      return null;
    }
    return _primaryKeyMap[key.primaryKey];
  }
  
  @override
  Record reduce(Record combine(Record value, Record element)){
    Record value = first.clone();
    skip(1).forEach((element) {
      value = combine(value, element);
    });
    return value;
  }

  @override
  bool remove(Object value) {
    if(!value is Record){
      return false;
    }
    Record record = value as Record;
    if(record.schema != _schema){
      return false;
    }
    int index = _records.indexOf(record);
    if(index < 0){
      return false;
    }
    removeAt(index);
    return true;
  }
  
  @override
  Record removeAt(int index) {
    Record removed = _records.removeAt(index);
    if(removed != null && _schema.hasPrimary){
      _primaryKeyMap.remove(removed.primaryKey);
    }
    return removed;
  }
  
  @override
  Record removeLast() {
    return removeAt(length - 1);
  }

  @override
  void removeRange(int start, int end){
    for(int i = start; i < end; i++){
      removeAt(start);
    }
  }
  
  @override
  void removeWhere(bool test(Record element)){
    int i = _records.length -1;
    for(Record record in _records.reversed){
      if(test(record)){
        removeAt(i);
      }
      i--;
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<Record> replacement) {
    removeRange(start, end);
    insertAll(start, replacement);
  }

  @override
  void retainWhere(bool Function(Record element) test) {
    removeWhere((rec)=>!test(rec));
  }
  
  
  @override
  void setAll(int index, Iterable<Record> iterable){
    for(Record record in iterable){
      this[index++] = record;
    }
  }
  
  @override
  void setRange(int start, int end, Iterable<Record> iterable, [int skipCount = 0]){
    removeRange(start, end);
    insertAll(start, iterable.skip(skipCount));
  }
  
  @override
  void shuffle([Random random]) {
    _records.shuffle(random);
  }
  
  @override
  Record singleWhere(bool test(Record element), {Record orElse()}) {
    return _records.singleWhere(test, orElse:orElse);
  }
  
  @override
  Iterable<Record> skip(int count) {
    return _records.skip(count);
  }
  
  @override
  Iterable<Record> skipWhile(bool test(Record value)) {
    return _records.skipWhile(test);
  }

  @override
  void sort([int Function(Record a, Record b) compare]) {
    _records.sort(compare);
  }

  /// Sort by the specified field name.
  /// 
  /// The ascending/descending order is specified by the [isAsc] parameter.
  void sortBy(List<String> names, [List<bool> isAsc]){
    sort(
      (a, b){
        int result = 0;
        for(int i = 0; i < names.length; i++){
          String name = names[i];
          bool asc = isAsc == null ? true : isAsc[i];
          Object aVal = a[name];
          Object bVal = b[name];
          if(aVal == null && bVal != null){
            result = asc ? -1 : 1;
            break;
          }
          if(aVal != null && bVal == null){
            result = asc ? 1 : -1;
            break;
          }
          if(aVal == null && bVal == null){
            continue;
          }
          if(aVal is Comparable){
            result = aVal.compareTo(bVal);
            if(!asc){
              result = -result;
            }
            if(result != 0){
              break;
            }
          }
        }
        return result;
      }
    );
  }

  @override
  List<Record> sublist(int start, [int end]) {
    return _records.sublist(start, end);
  }

  @override
  Iterable<Record> take(int count){
    return _records.take(count);
  }
  
  @override
  Iterable<Record> takeWhile(bool test(Record value)) {
    return _records.takeWhile(test);
  }
  
  @override
  List<Record> toList({bool growable = true}) {
    return _records.toList(growable:growable);
  }

  @override
  Set<Record> toSet() {
    return _records.toSet();
  }

  @override
  Iterable<Record> where(bool Function(Record element) test) {
    return _records.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _records.whereType();
  }

  void validate(){
    _records.forEach((record)=>record.validate());
  }
  bool hasValidateError(){
    for(Record record in _records){
      if(record.hasValidateError()){
        return true;
      }
    }
    return false;
  }

  /// Clone the data.
  /// 
  /// If [isDeep] is not set to true, the clone will be a shallow copy.
  RecordList clone([bool isDeep=false]){
    RecordList list = cloneEmpty();
    list.dataSet = _dataSet;
    if(isDeep){
      for(Record record in _records){
        list.add(record.clone());
      }
    }else{
      list.addAll(this);
    }
    return list;
  }

  RecordList cloneEmpty(){
    return RecordList(_schema);
  }
}
