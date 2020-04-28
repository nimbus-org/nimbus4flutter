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

class DataSet{
  String name;
  Map<String,Record> _headers = Map();
  Map<String,RecordList> _recordLists = Map();
  Map<String,RecordSchema> _nestedRecordSchemata = Map();
  Map<String,RecordSchema> _nestedRecordListSchemata = Map();

  DataSet.empty():this(null);

  DataSet(this.name);

  void setHeaderSchema(RecordSchema schema,[String name]){
    Record record = Record(schema);
    record.dataSet = this;
    _headers[name] = record;
  }

  void setRecordListSchema(RecordSchema schema,[String name]){
    RecordList recordList = RecordList(schema);
    recordList.dataSet = this;
    _recordLists[name] = recordList;
  }

  void setNestedRecordSchema(RecordSchema schema, String name){
    _nestedRecordSchemata[name] = schema;
  }

  void setNestedRecordListSchema(RecordSchema schema, String name){
    _nestedRecordListSchemata[name] = schema;
  }

  Record createNestedRecord(String name){
    RecordSchema schema = _nestedRecordSchemata[name];
    if(schema == null){
      throw Exception("Schema is not defined.name=$name");
    }
    Record record =  Record(schema);
    record.dataSet = this;
    return record;
  }

  RecordList createNestedRecordList(String name){
    RecordSchema schema = _nestedRecordListSchemata[name];
    if(schema == null){
      throw Exception("Schema is not defined.name=$name");
    }
    RecordList recordList = RecordList(schema);
    recordList.dataSet = this;
    return recordList;
  }

  Record getHeader([String name]){
    return _headers[name];
  }

  void setHeader(Record record, [String name]){
    _headers[name] = record;
  }

  RecordList getRecordList([String name]){
    return _recordLists[name];
  }
  
  void setRecordList(RecordList record, [String name]){
    _recordLists[name] = record;
  }

  DataSet fromMap(Map<String,Object> map){
    MapEntry dsEntry = map.entries.first;
    if(name == null){
      name = dsEntry.key;
    }
    Map<String,Object> dsMap = dsEntry.value;
    Map<String,Object> headers = dsMap["header"];
    if(headers != null){
      headers.forEach(
        (name, value){
          Record header = _headers[name?.length == 0 ? null : name];
          if(header != null){
            header.fromMap(value);
          }
        }
      );
    }
    Map<String,Object> recordLists = dsMap["recordList"];
    if(recordLists != null){
      recordLists.forEach(
        (name, value){
          RecordList list = _recordLists[name?.length == 0 ? null : name];
          if(list != null){
            list.fromMap(value);
          }
        }
      );
    }
    return this;
  }

  Map<String,Object> _toSchemaMap(bool toJsonType){
    Map<String,Object> schemaMap = new Map();
    if(_headers.isNotEmpty){
      Map<String,Object> headerSchemaMap = new Map();
      schemaMap["header"] = headerSchemaMap;
      _headers.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          headerSchemaMap[name] = value.schema.toMap();
        }
      );
    }
    if(_recordLists.isNotEmpty){
      Map<String,Object> recordListSchemaMap = new Map();
      schemaMap["recordList"] = recordListSchemaMap;
      _recordLists.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          recordListSchemaMap[name] = value.schema.toMap();
        }
      );
    }
    if(_nestedRecordSchemata.isNotEmpty){
      Map<String,Object> nestedRecordSchemaMap = new Map();
      schemaMap["nestedRecord"] = nestedRecordSchemaMap;
      _nestedRecordSchemata.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          nestedRecordSchemaMap[name] = value.toMap();
        }
      );
    }
    if(_nestedRecordListSchemata.isNotEmpty){
      Map<String,Object> nestedRecordListSchemaMap = new Map();
      schemaMap["nestedRecordList"] = nestedRecordListSchemaMap;
      _nestedRecordListSchemata.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          nestedRecordListSchemaMap[name] = value.toMap();
        }
      );
    }
    return schemaMap;
  }

  Map<String,Object> toMap({bool hasNull=true, bool isOutputSchema=false, bool toJsonType=false}){
    Map map = Map<String,Object>();
    if(isOutputSchema){
      map["schema"] = _toSchemaMap(toJsonType);
    }
    if(_headers.isNotEmpty){
      Map<String,Object> headerMap = new Map();
      map["header"] = headerMap;
      _headers.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          headerMap[name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
        }
      );
    }
    if(_recordLists.isNotEmpty){
      Map<String,Object> recordListMap = new Map();
      map["recordList"] = recordListMap;
      _recordLists.forEach(
        (name, value){
          if(toJsonType && name == null){
            name = "";
          }
          recordListMap[name] = value.toMap(hasNull:hasNull,toJsonType:toJsonType);
        }
      );
    }
    Map dsMap = Map<String,Object>();
    dsMap[name == null ? "" : name] = map;
    return dsMap;
  }

  DataSet fromList(Map<String,Object> map,{bool isListHeader:true, bool isListRecordList:true}){
    MapEntry dsEntry = map.entries.first;
    if(name == null){
      name = dsEntry.key;
    }
    Map<String,Object> dsMap = dsEntry.value;
    Map<String,Object> schemaMap = dsMap["schema"];
    Map<String,Object> headerSchemata = schemaMap == null ? null : schemaMap["header"];
    Map<String,Object> headers = dsMap["header"];
    if(headers != null){
      headers.forEach(
        (name, value){
          Record header = _headers[name?.length == 0 ? null : name];
          if(header != null){
            if(isListHeader){
              Map<String,Object> headerSchema = headerSchemata == null ? null : headerSchemata[name?.length == 0 ? null : name];
              header.fromList(value, headerSchema, schemaMap);
            }else{
              header.fromMap(value);
            }
          }
        }
      );
    }
    Map<String,Object> recordListSchemata = schemaMap == null ? null : schemaMap["recordList"];
    Map<String,Object> recordLists = dsMap["recordList"];
    if(recordLists != null){
      recordLists.forEach(
        (name, value){
          RecordList list = _recordLists[name?.length == 0 ? null : name];
          if(list != null){
            if(isListRecordList){
              Map<String,Object> recordListSchema = recordListSchemata == null ? null : recordListSchemata[name?.length == 0 ? null : name];
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

  Map<String,Object> toList(
    {
      bool hasNull=true,
      bool isOutputSchema=false,
      bool toJsonType=false,
      bool isListHeader:true,
      bool isListRecordList:true
    }
  ){
    Map map = Map<String,Object>();
    if(isOutputSchema){
      map["schema"] = _toSchemaMap(toJsonType);
    }
    if(_headers.isNotEmpty){
      Map<String,Object> headerMap = new Map();
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
      Map<String,Object> recordListMap = new Map();
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
    Map dsMap = Map<String,Object>();
    dsMap[name == null ? "" : name] = map;
    return dsMap;
  }

  void clear(){
    _headers.values.forEach((record)=>record.clear());
    _recordLists.values.forEach((list)=>list.clear());
  }

  DataSet clone([bool isDeep=false]){
    DataSet ds = DataSet(name);
    _headers.forEach((key, value){
      ds._headers[key] = value.clone();
    });
    _recordLists.forEach((key, value){
      ds._recordLists[key] = value.clone(isDeep);
    });
    _nestedRecordSchemata.forEach((key, value){
      ds._nestedRecordSchemata[key] = value;
    });
    _nestedRecordListSchemata.forEach((key, value){
      ds._nestedRecordListSchemata[key] = value;
    });
    return ds;
  }

}

class QueryDataSet extends DataSet{

  static const String _HEADER_QUERY = "HeaderQuery";
  static const String _RECORD_LIST_QUERY = "RecordListQuery";
  static const String _NESTED_RECORD_QUERY = "NestedRecordQuery";
  static const String _NESTED_RECORD_LIST_QUERY = "NestedRecordListQuery";

  QueryDataSet.empty() : this(null);

  QueryDataSet(String name):super(name){
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
  
  RecordList get headerQuery =>  getRecordList(_HEADER_QUERY);
  RecordList get recordListQuery =>  getRecordList(_RECORD_LIST_QUERY);
  RecordList get nestedRecordQuery =>  getRecordList(_NESTED_RECORD_QUERY);
  RecordList get nestedRecordListQuery =>  getRecordList(_NESTED_RECORD_LIST_QUERY);
}

abstract class QueryDataSetField{
  static const String NAME = "name";
  static const String PROPERTY_NAMES = "propertyNames";
  static const String FROM_INDEX = "fromIndex";
  static const String MAX_SIZE = "maxSize";
}
