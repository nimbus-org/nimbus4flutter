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

/// DataSet is a dynamic generic DTO.
/// 
/// DataSet can represent a data structure that summarizes multiple forms.
/// A report usually has a header part, which is a one-dimensional data structure, and a table part, which is a two-dimensional data structure.
/// 
/// The header part is represented by [Record] and the table part is represented by [RecordList].
/// DataSet can have multiple names for each of [Record], which is a header, and [RecordList], which is a table.
/// 
/// For example
/// ```dart
/// import 'package:nimbus4flutter/nimbus4flutter.dart';
/// 
/// DataSet dataSet = DataSet("CurriculumVitae");
/// dataSet.setHeaderSchema(
///   RecordSchema(
///     [
///       FieldSchema<String>("name"),
///       FieldSchema<int>("age")
///     ]
///   ),
///   "User"
/// );
/// dataSet.setRecordListSchema(
///   RecordSchema(
///     [
///       FieldSchema<String>("title"),
///       FieldSchema<String>("description"),
///       FieldSchema<DateTime>("from"),
///       FieldSchema<DateTime>("to")
///     ]
///   ),
///   "Career"
/// );
/// 
/// Record userHeader = dataSet.getHeader("User");
/// userHeader["name"] = "hoge";
/// userHeader["age"] = 20;
/// 
/// RecordList careerList = dataSet.getRecordList("Career");
/// careerList.add(
///   careerList.createRecord(
///     {
///       "title":"career1",
///       "description":"description1",
///       "from":DateFormat('yyyy/MM/dd').parse("2020/01/01"),
///       "to":DateFormat('yyyy/MM/dd').parse("2020/01/30")
///     }
///   )
/// );
/// careerList.add(
///   careerList.createRecord(
///     {
///       "title":"career2",
///       "description":"description2",
///       "from":DateFormat('yyyy/MM/dd').parse("2020/02/01"),
///       "to":DateFormat('yyyy/MM/dd').parse("2020/02/15")
///     }
///   )
/// );
/// ```
class DataSet{

  /// Name of this DataSet.
  String? name;

  Map<String?,Record> _headers = Map();
  Map<String?,RecordList> _recordLists = Map();
  Map<String?,RecordSchema> _nestedRecordSchemata = Map();
  Map<String?,RecordSchema> _nestedRecordListSchemata = Map();

  DataSet.empty():this(null);

  DataSet(this.name);

  /// Define the schema of the header part [Record], which is a one-dimensional data structure.
  /// 
  /// If [name] is not specified, it is treated as an unnamed header.
  void setHeaderSchema(RecordSchema schema,[String? name]){
    Record record = Record(schema);
    record.dataSet = this;
    _headers[name] = record;
  }

  /// Define the schema of the list part [RecordList], which is a two-dimensional data structure.
  /// 
  /// If [name] is not specified, it is treated as an unnamed list.
  void setRecordListSchema(RecordSchema schema,[String? name]){
    RecordList recordList = RecordList(schema);
    recordList.dataSet = this;
    _recordLists[name] = recordList;
  }

  /// Define a schema for [Record] to be nested as a field in [Record] or [RecordList].
  void setNestedRecordSchema(RecordSchema schema, String name){
    _nestedRecordSchemata[name] = schema;
  }

  /// Define a schema for [RecordList] to be nested as a field in [Record] or [RecordList].
  void setNestedRecordListSchema(RecordSchema schema, String name){
    _nestedRecordListSchemata[name] = schema;
  }

  /// Creates a nested [Record] with the specified name.
  Record createNestedRecord(String name){
    RecordSchema? schema = _nestedRecordSchemata[name];
    if(schema == null){
      throw Exception("Schema is not defined.name=$name");
    }
    Record record =  Record(schema);
    record.dataSet = this;
    return record;
  }

  /// Creates a nested [RecordList] with the specified name.
  RecordList createNestedRecordList(String name){
    RecordSchema? schema = _nestedRecordListSchemata[name];
    if(schema == null){
      throw Exception("Schema is not defined.name=$name");
    }
    RecordList recordList = RecordList(schema);
    recordList.dataSet = this;
    return recordList;
  }

  /// Get the header of the specified name.
  /// 
  /// If you don't specify [name], you will get an unnamed header.
  Record? getHeader([String? name]){
    return _headers[name];
  }

  /// Set the header of the specified name to the specified value.
  /// 
  /// If you don't specify [name], you will set an unnamed header.
  void setHeader(Record record, [String? name]){
    record.dataSet = this;
    _headers[name] = record;
  }

  /// Get the list of the specified name.
  /// 
  /// If you don't specify [name], you will get an unnamed list.
  RecordList? getRecordList([String? name]){
    return _recordLists[name];
  }
  
  /// Set the lsit of the specified name to the specified value.
  /// 
  /// If you don't specify [name], you will set an unnamed list.
  void setRecordList(RecordList list, [String? name]){
    list.dataSet = this;
    _recordLists[name] = list;
  }

  /// Read [DataSet] from the Map which has [Record] and [RecordList] expressed in Map format.
  /// 
  /// Record and RecordList in Map format are flexible to increase or decrease the number of fields when interacting with the other party.
  /// Instead, in RecordList, the larger the number of data, the more redundant the field name output becomes, so the output size becomes huge.
  ///
  /// For exmaple
  /// ```json
  /// {
  ///   "User":{
  ///     "header":{
  ///       "":{
  ///         "name":"hoge",
  ///         "age":20,
  ///         "hasSpouse":false
  ///       }
  ///     },
  ///     "recordList":{
  ///       "career":[
  ///         {
  ///           "title":"career1",
  ///           "from":"2020/01/01",
  ///           "to":"2020/01/30",
  ///           "detail":["detail1","detail2"]
  ///         },
  ///         {
  ///           "title":"career2",
  ///           "from":"2020/02/01",
  ///           "to":"2020/04/30",
  ///           "detail":["detail1","detail2"]
  ///         }
  ///       ]
  ///      }
  ///    }
  ///  }
  /// ```
  DataSet fromMap(Map<String,Object?>? map){
    if(map == null){
      return this;
    }
    MapEntry dsEntry = map.entries.first;
    if(name == null){
      name = dsEntry.key;
    }
    Map<String?,Object?>? dsMap = dsEntry.value;
    if(dsMap == null){
      return this;
    }
    Map<String?,Object?>? headers = dsMap["header"] as Map<String?,Object?>?;
    if(headers != null){
      headers.forEach(
        (name, value){
          Record? header = _headers[name?.length == 0 ? null : name];
          if(header != null && value != null){
            header.fromMap(value as Map<String,Object?>);
          }
        }
      );
    }
    Map<String?,Object?>? recordLists = dsMap["recordList"] as Map<String?,Object?>?;
    if(recordLists != null){
      recordLists.forEach(
        (name, value){
          RecordList? list = _recordLists[name?.length == 0 ? null : name];
          if(list != null && value != null){
            if(value is List){
              list.fromMap(value);
            }else if(value is Map){
              list.fromMapByMap(value);
            }
          }
        }
      );
    }
    return this;
  }

  Map<String,Object> _toSchemaMap(bool toJsonType){
    Map<String,Object> schemaMap = new Map();
    if(_headers.isNotEmpty){
      Map<String?,Object> headerSchemaMap = new Map();
      schemaMap["header"] = headerSchemaMap;
      _headers.forEach(
        (name, value){
          if(value.schema != null){
            headerSchemaMap[name == null && toJsonType ? "" : name] = value.schema!.toMap();
          }
        }
      );
    }
    if(_recordLists.isNotEmpty){
      Map<String?,Object> recordListSchemaMap = new Map();
      schemaMap["recordList"] = recordListSchemaMap;
      _recordLists.forEach(
        (name, value){
          recordListSchemaMap[name == null && toJsonType ? "" : name] = value.schema.toMap();
        }
      );
    }
    if(_nestedRecordSchemata.isNotEmpty){
      Map<String?,Object> nestedRecordSchemaMap = new Map();
      schemaMap["nestedRecord"] = nestedRecordSchemaMap;
      _nestedRecordSchemata.forEach(
        (name, value){
          nestedRecordSchemaMap[name == null && toJsonType ? "" : name] = value.toMap();
        }
      );
    }
    if(_nestedRecordListSchemata.isNotEmpty){
      Map<String?,Object> nestedRecordListSchemaMap = new Map();
      schemaMap["nestedRecordList"] = nestedRecordListSchemaMap;
      _nestedRecordListSchemata.forEach(
        (name, value){
          nestedRecordListSchemaMap[name == null && toJsonType ? "" : name] = value.toMap();
        }
      );
    }
    return schemaMap;
  }

  /// Outputs a map with Record and RecordList expressed in Map format.
  /// 
  /// If [hasNull] is set to false, fields with a value of null will not be printed; this can be used to reduce the output when there is no need to tell that they are null.
  /// If [isOutputSchema] is set to true, the schema information is output. You can specify this if you don't want to share the schema with the other party, but you don't need to specify this in general.
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
  Map<String,Object> toMap({bool hasNull=true, bool isOutputSchema=false, bool toJsonType=false}){
    Map<String,Object> map = Map();
    if(isOutputSchema){
      map["schema"] = _toSchemaMap(toJsonType);
    }
    if(_headers.isNotEmpty){
      Map<String?,Object> headerMap = new Map();
      map["header"] = headerMap;
      _headers.forEach(
        (name, value){
          headerMap[name == null && toJsonType ? "" : name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
        }
      );
    }
    if(_recordLists.isNotEmpty){
      Map<String?,Object> recordListMap = new Map();
      map["recordList"] = recordListMap;
      _recordLists.forEach(
        (name, value){
          recordListMap[name == null && toJsonType ? "" : name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
        }
      );
    }
    Map<String,Object> dsMap = Map();
    dsMap[name == null ? "" : name!] = map;
    return dsMap;
  }

  /// Read [DataSet] from the Map which has [Record] and [RecordList] expressed in List format.
  /// 
  /// List format records and record lists are vulnerable to field increases and decreases when interacting with others.
  /// Instead, the output size can be minimized.
  /// 
  /// For example
  /// ```json
  /// {
  ///   "User":{
  ///     "header":{
  ///       "":["hoge",20,false]
  ///     },
  ///     "recordList":{
  ///       "career":[
  ///         ["career1","from":"2020/01/01","2020/01/30",["detail1","detail2"]],
  ///         ["career2","from":"2020/02/01","2020/04/30",["detail1","detail2"]]
  ///       ]
  ///      }
  ///    }
  ///  }
  /// ```
  DataSet fromList(Map<String,dynamic>? map,{bool isListHeader=true, bool isListRecordList=true}){
    if(map == null){
      return this;
    }
    MapEntry dsEntry = map.entries.first;
    if(name == null){
      name = dsEntry.key;
    }
    Map<String,dynamic?> dsMap = dsEntry.value;
    Map<String,dynamic?>? schemaMap = dsMap["schema"];
    Map<String?,dynamic?>? headerSchemata = schemaMap == null ? null : schemaMap["header"];
    Map<String?,dynamic?>? headers = dsMap["header"];
    if(headers != null){
      headers.forEach(
        (name, value){
          Record? header = _headers[name?.length == 0 ? null : name];
          if(header != null){
            if(isListHeader){
              Map<String,dynamic>? headerSchema = headerSchemata == null ? null : headerSchemata[name?.length == 0 ? null : name];
              header.fromList(value, headerSchema, schemaMap);
            }else{
              header.fromMap(value);
            }
          }
        }
      );
    }
    Map<String?,dynamic?>? recordListSchemata = schemaMap == null ? null : schemaMap["recordList"];
    Map<String?,dynamic?>? recordLists = dsMap["recordList"];
    if(recordLists != null){
      recordLists.forEach(
        (name, value){
          RecordList? list = _recordLists[name?.length == 0 ? null : name];
          if(list != null){
            if(isListRecordList){
              Map<String,dynamic?>? recordListSchema = recordListSchemata == null ? null : recordListSchemata[name?.length == 0 ? null : name];
              list.fromList(value, recordListSchema, schemaMap);
            }else{
              list.fromMap(value);
            }
          }
        }
      );
    }
    return this;
  }

  /// Outputs a map with Record and RecordList expressed in List format.
  /// 
  /// If [hasNull] is set to false, fields with a value of null will not be printed; this can be used to reduce the output when there is no need to tell that they are null.
  /// If [isOutputSchema] is set to true, the schema information is output. It is specified to compensate for the weaknesses of the List format, which is vulnerable to increasing or decreasing fields or not sharing a schema with an opponent.
  /// If [toJsonType] is set to true, fields of unsuitable JSON types will be attempted to be converted to String.
  /// If [isListHeader] is set to false, the output format of Header is set to Map format.
  /// If [isListRecordList] is set to false, the output format of RecordList is set to Map format.
  Map<String,Object> toList(
    {
      bool hasNull=true,
      bool isOutputSchema=false,
      bool toJsonType=false,
      bool isListHeader=true,
      bool isListRecordList=true
    }
  ){
    Map map = Map<String,Object>();
    if(isOutputSchema){
      map["schema"] = _toSchemaMap(toJsonType);
    }
    if(_headers.isNotEmpty){
      Map<String?,Object> headerMap = new Map();
      map["header"] = headerMap;
      _headers.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          if(isListHeader){
            headerMap[name] = value.toList(toJsonType:toJsonType);
          }else{
            headerMap[name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
          }
        }
      );
    }
    if(_recordLists.isNotEmpty){
      Map<String?,Object> recordListMap = new Map();
      map["recordList"] = recordListMap;
      _recordLists.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          if(isListRecordList){
            recordListMap[name] = value.toDeepList(toJsonType:toJsonType);
          }else{
            recordListMap[name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
          }
        }
      );
    }
    Map<String,Object> dsMap = Map();
    dsMap[name == null ? "" : name!] = map;
    return dsMap;
  }

  /// Clear the data.
  /// The set schema information will not be cleared.
  void clear(){
    _headers.values.forEach((record)=>record.clear());
    _recordLists.values.forEach((list)=>list.clear());
  }

  /// Clone the data.
  /// 
  /// If [isDeep] is not set to true, the clone of RecordList will be a shallow copy.
  DataSet clone([bool isDeep=false]){
    DataSet ds = cloneEmpty();
    _headers.forEach((key, value){
      Record newRec = value.clone();
      ds.setHeader(newRec, key);
    });
    _recordLists.forEach((key, value){
      ds.setRecordList(value.clone(isDeep), key);
    });
    _nestedRecordSchemata.forEach((key, value){
      ds._nestedRecordSchemata[key] = value;
    });
    _nestedRecordListSchemata.forEach((key, value){
      ds._nestedRecordListSchemata[key] = value;
    });
    return ds;
  }

  DataSet cloneEmpty(){
    return DataSet(name);
  }

}

/// A DataSet with a query.
///
/// When a DataSet is used as a request to the server, a query can be specified for the response DataSet.
class QueryDataSet extends DataSet{

  static const String _HEADER_QUERY = "HeaderQuery";
  static const String _RECORD_LIST_QUERY = "RecordListQuery";
  static const String _NESTED_RECORD_QUERY = "NestedRecordQuery";
  static const String _NESTED_RECORD_LIST_QUERY = "NestedRecordListQuery";

  QueryDataSet.empty() : this(null);

  QueryDataSet(String? name):super(name){
    this.setRecordListSchema(
      RecordSchema(
        [
          FieldSchema<String>(QueryDataSetField.NAME),
          FieldSchema<List<String>>(QueryDataSetField.PROPERTY_NAMES)
        ]
      ),
      _HEADER_QUERY
    );
    this.setRecordListSchema(
      RecordSchema(
        [
          FieldSchema<String>(QueryDataSetField.NAME),
          FieldSchema<List<String>>(QueryDataSetField.PROPERTY_NAMES),
          FieldSchema<int>(QueryDataSetField.FROM_INDEX),
          FieldSchema<int>(QueryDataSetField.MAX_SIZE)
        ]
      ),
      _RECORD_LIST_QUERY
    );
    this.setRecordListSchema(
      RecordSchema(
        [
          FieldSchema<String>(QueryDataSetField.NAME),
          FieldSchema<List<String>>(QueryDataSetField.PROPERTY_NAMES)
        ]
      ),
      _NESTED_RECORD_QUERY
    );
    this.setRecordListSchema(
      RecordSchema(
        [
          FieldSchema<String>(QueryDataSetField.NAME),
          FieldSchema<List<String>>(QueryDataSetField.PROPERTY_NAMES),
        ]
      ),
      _NESTED_RECORD_LIST_QUERY
    );
  }
  
  /// It is a RecordList that specifies the query to the header.
  /// 
  /// See [QueryDataSetField] for a list of possible field names
  RecordList get headerQuery =>  getRecordList(_HEADER_QUERY)!;
  
  /// It is a RecordList that specifies the query to the lsit.
  /// 
  /// See [QueryDataSetField] for a list of possible field names
  RecordList get recordListQuery =>  getRecordList(_RECORD_LIST_QUERY)!;
  
  /// It is a RecordList that specifies the query to the nested header.
  /// 
  /// See [QueryDataSetField] for a list of possible field names
  RecordList get nestedRecordQuery =>  getRecordList(_NESTED_RECORD_QUERY)!;
  
  /// It is a RecordList that specifies the query to the nested list.
  /// 
  /// See [QueryDataSetField] for a list of possible field names
  RecordList get nestedRecordListQuery =>  getRecordList(_NESTED_RECORD_LIST_QUERY)!;
}

/// Class that defines the field name of a DataSet with a query.
abstract class QueryDataSetField{

  /// A field name that specifies the name of the header or list to be requested.
  static const String NAME = "name";

  /// A field name that specifies the name of a field in the requested header or list.
  static const String PROPERTY_NAMES = "propertyNames";

  /// A field name that specifies the starting index of the requested list.
  static const String FROM_INDEX = "fromIndex";

  /// A field name that specifies the maximum size of the requested list.
  static const String MAX_SIZE = "maxSize";
}
