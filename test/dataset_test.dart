import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  FieldConverter<dynamic,DateTime> stringToDate = (input)=>DateFormat('yyyy/MM/dd').parse(input);
  FieldConverter<DateTime,dynamic> dateToString = (input)=>DateFormat('yyyy/MM/dd').format(input);
  group('convert map test', () {
    test('convert map test', () {
     DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse"),
            FieldSchema.list("emergencyContact", "contact")
          ]
        )
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List<String>>("detail")
          ]
        ),
        "career"
      );
      ds.setNestedRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<String>("tel")
          ]
        ),
        "contact"
      );
      ds.getHeader().fromMap(
        {
          "name":"hoge",
          "age":20,
          "hasSpouse" : false,
          "emergencyContact":[
            {
              "name":"fuga",
              "tel":"1234567890"
            },
            {
              "name":"piyo",
              "tel":"0123456789"
            }
          ]
        }
      );
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career1",
            "from":"2020/01/01",
            "to":"2020/01/30",
            "detail":["detail1","detail2"]
          }
        )
      );
      var now = DateTime.now();
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career2",
            "from":"2020/02/01",
            "to":now,
            "detail":["detail1","detail2"]
          }
        )
      );
      Map<String,Object> dsMap = ds.toMap();
      expect(dsMap["User"] != null, true);
      Map<String,Object> user = dsMap["User"];
      expect(user["header"] != null, true);
      Map<String,Object> headers = user["header"];
      expect(headers[null] != null, true);
      Map<String,Object> header = headers[null];
      expect(header["name"], "hoge");
      expect(header["age"], 20);
      expect(header["hasSpouse"], false);
      expect(header["emergencyContact"] != null, true);
      List<Map<String,Object>> emergencyContact = header["emergencyContact"];
      expect(emergencyContact.length, 2);
      expect(emergencyContact[0]["name"], "fuga");
      expect(emergencyContact[0]["tel"], "1234567890");
      expect(emergencyContact[1]["name"], "piyo");
      expect(emergencyContact[1]["tel"], "0123456789");
      expect(user["recordList"] != null, true);
      Map<String,Object> recordLists = user["recordList"];
      expect(recordLists["career"] != null, true);
      List<Map<String,Object>> career = recordLists["career"];
      expect(career.length, 2);
      expect(career[0]["title"], "career1");
      expect(career[0]["from"], stringToDate("2020/01/01"));
      expect(career[0]["to"], stringToDate("2020/01/30"));
      expect(career[0]["detail"], ["detail1","detail2"]);
      expect(career[1]["title"], "career2");
      expect(career[1]["from"], stringToDate("2020/02/01"));
      expect(career[1]["to"], now);
      expect(career[1]["detail"], ["detail1","detail2"]);
      ds.clear();
      expect(ds.getHeader()["name"], null);
      expect(ds.getHeader()["age"], null);
      expect(ds.getHeader()["hasSpouse"], null);
      expect(ds.getHeader()["emergencyContact"], null);
      expect(ds.getRecordList("career").length, 0);
      ds.fromMap(dsMap);
      expect(ds.getHeader()["name"], "hoge");
      expect(ds.getHeader()["age"], 20);
      expect(ds.getHeader()["hasSpouse"], false);
      expect(ds.getHeader()["emergencyContact"] != null, true);
      RecordList emergencyContactList = ds.getHeader()["emergencyContact"];
      expect(emergencyContactList.length, 2);
      expect(emergencyContactList[0]["name"], "fuga");
      expect(emergencyContactList[0]["tel"], "1234567890");
      expect(emergencyContactList[1]["name"], "piyo");
      expect(emergencyContactList[1]["tel"], "0123456789");
      expect(ds.getRecordList("career").length, 2);
      expect(ds.getRecordList("career")[0]["title"], "career1");
      expect(ds.getRecordList("career")[0]["from"], stringToDate("2020/01/01"));
      expect(ds.getRecordList("career")[0]["to"], stringToDate("2020/01/30"));
      expect(ds.getRecordList("career")[0]["detail"], ["detail1","detail2"]);
      expect(ds.getRecordList("career")[1]["title"], "career2");
      expect(ds.getRecordList("career")[1]["from"], stringToDate("2020/02/01"));
      expect(ds.getRecordList("career")[1]["to"], now);
      expect(ds.getRecordList("career")[1]["detail"], ["detail1","detail2"]);
    });
    test('convert map for json test', () {
     DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse")
          ]
        )
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List<String>>("detail")
          ]
        ),
        "career"
      );
      ds.getHeader().fromMap(
        {
          "name":"hoge",
          "age":20,
          "hasSpouse" : false
        }
      );
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career1",
            "from":"2020/01/01",
            "to":"2020/01/30",
            "detail":["detail1","detail2"]
          }
        )
      );
      var now = DateTime.now();
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career2",
            "from":"2020/02/01",
            "to":now,
            "detail":["detail1","detail2"]
          }
        )
      );
      Map<String,Object> dsMap = ds.toMap(toJsonType: true);
      expect(dsMap["User"] != null, true);
      Map<String,Object> user = dsMap["User"];
      expect(user["header"] != null, true);
      Map<String,Object> headers = user["header"];
      expect(headers[""] != null, true);
      Map<String,Object> header = headers[""];
      expect(header["name"], "hoge");
      expect(header["age"], 20);
      expect(header["hasSpouse"], false);
      expect(user["recordList"] != null, true);
      Map<String,Object> recordLists = user["recordList"];
      expect(recordLists["career"] != null, true);
      List<Map<String,Object>> career = recordLists["career"];
      expect(career.length, 2);
      expect(career[0]["title"], "career1");
      expect(career[0]["from"], "2020/01/01");
      expect(career[0]["to"], "2020/01/30");
      expect(career[0]["detail"], ["detail1","detail2"]);
      expect(career[1]["title"], "career2");
      expect(career[1]["from"], "2020/02/01");
      expect(career[1]["to"], dateToString(now));
      expect(career[1]["detail"], ["detail1","detail2"]);
      ds.clear();
      expect(ds.getHeader()["name"], null);
      expect(ds.getHeader()["age"], null);
      expect(ds.getHeader()["hasSpouse"], null);
      expect(ds.getRecordList("career").length, 0);
      ds.fromMap(dsMap);
      expect(ds.getHeader()["name"], "hoge");
      expect(ds.getHeader()["age"], 20);
      expect(ds.getHeader()["hasSpouse"], false);
      expect(ds.getRecordList("career").length, 2);
      expect(ds.getRecordList("career")[0]["title"], "career1");
      expect(ds.getRecordList("career")[0]["from"], stringToDate("2020/01/01"));
      expect(ds.getRecordList("career")[0]["to"], stringToDate("2020/01/30"));
      expect(ds.getRecordList("career")[0]["detail"], ["detail1","detail2"]);
      expect(ds.getRecordList("career")[1]["title"], "career2");
      expect(ds.getRecordList("career")[1]["from"], stringToDate("2020/02/01"));
      expect(ds.getRecordList("career")[1]["to"], stringToDate(dateToString(now)));
      expect(ds.getRecordList("career")[1]["detail"], ["detail1","detail2"]);
    });
    test('convert map with schema test', () {
     DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse")
          ]
        )
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List<String>>("detail")
          ]
        ),
        "career"
      );
      Map<String,Object> dsMap = ds.toMap(isOutputSchema: true);
      expect(dsMap["User"] != null, true);
      Map<String,Object> user = dsMap["User"];
      expect(user["schema"] != null, true);
      Map<String,Object> schema = user["schema"];
      {
        expect(schema["header"] != null, true);
        Map<String,Object> headers = schema["header"];
        expect(headers[null] != null, true);
        Map<String,Object> header = headers[null];
        expect(header["name"] != null, true);
        Map<String,Object> name = header["name"];
        expect(name["index"], 0);
        expect(name["type"], "value");
        expect(header["age"] != null, true);
        Map<String,Object> age = header["age"];
        expect(age["index"], 1);
        expect(age["type"], "value");
        expect(header["hasSpouse"] != null, true);
        Map<String,Object> hasSpouse = header["hasSpouse"];
        expect(hasSpouse["index"], 2);
        expect(hasSpouse["type"], "value");
        expect(schema["recordList"] != null, true);
        Map<String,Object> recordLists = schema["recordList"];
        expect(recordLists["career"] != null, true);
        Map<String,Object> career = recordLists["career"];
        expect(career["title"] != null, true);
        Map<String,Object> title = career["title"];
        expect(title["index"], 0);
        expect(title["type"], "value");
        expect(career["from"] != null, true);
        Map<String,Object> from = career["from"];
        expect(from["index"], 1);
        expect(from["type"], "value");
        expect(career["to"] != null, true);
        Map<String,Object> to = career["to"];
        expect(to["index"], 2);
        expect(to["type"], "value");
        expect(career["detail"] != null, true);
        Map<String,Object> detail = career["detail"];
        expect(detail["index"], 3);
        expect(detail["type"], "value");
      }
      Map<String,Object> headers = user["header"];
      expect(headers[null] != null, true);
      Map<String,Object> header = headers[null];
      expect(header["name"], null);
      expect(header["age"], null);
      expect(header["hasSpouse"], null);
      expect(user["recordList"] != null, true);
      Map<String,Object> recordLists = user["recordList"];
      expect(recordLists["career"] != null, true);
      List<Map<String, Object>> career = recordLists["career"];
      expect(career.length, 0);
      ds.fromMap(dsMap);
      expect(ds.getHeader()["name"], null);
      expect(ds.getHeader()["age"], null);
      expect(ds.getHeader()["hasSpouse"], null);
      expect(ds.getRecordList("career").length, 0);
    });
  });
  group('convert json test', () {
    test('convert json test', () {
     DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse")
          ]
        )
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List>("detail")
          ]
        ),
        "career"
      );
      ds.getHeader().fromMap(
        {
          "name":"hoge",
          "age":20,
          "hasSpouse" : false
        }
      );
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career1",
            "from":"2020/01/01",
            "to":"2020/01/30",
            "detail":["detail1","detail2"]
          }
        )
      );
      var now = DateTime.now();
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career2",
            "from":"2020/02/01",
            "to":now,
            "detail":["detail1","detail2"]
          }
        )
      );
      Map<String,Object> dsMap = ds.toMap(toJsonType: true);
      String json = JsonEncoder().convert(dsMap);
      dsMap = JsonDecoder().convert(json);
      ds.clear();
      expect(ds.getHeader()["name"], null);
      expect(ds.getHeader()["age"], null);
      expect(ds.getHeader()["hasSpouse"], null);
      expect(ds.getRecordList("career").length, 0);
      ds.fromMap(dsMap);
      expect(ds.getHeader()["name"], "hoge");
      expect(ds.getHeader()["age"], 20);
      expect(ds.getHeader()["hasSpouse"], false);
      expect(ds.getRecordList("career").length, 2);
      expect(ds.getRecordList("career")[0]["title"], "career1");
      expect(ds.getRecordList("career")[0]["from"], stringToDate("2020/01/01"));
      expect(ds.getRecordList("career")[0]["to"], stringToDate("2020/01/30"));
      expect(ds.getRecordList("career")[0]["detail"], ["detail1","detail2"]);
      expect(ds.getRecordList("career")[1]["title"], "career2");
      expect(ds.getRecordList("career")[1]["from"], stringToDate("2020/02/01"));
      expect(ds.getRecordList("career")[1]["to"], stringToDate(dateToString(now)));
      expect(ds.getRecordList("career")[1]["detail"], ["detail1","detail2"]);
    });
  });
  group('convert list test', () {
    test('convert list test', () {
     DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse")
          ]
        )
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List<String>>("detail")
          ]
        ),
        "career"
      );
      ds.getHeader().fromMap(
        {
          "name":"hoge",
          "age":20,
          "hasSpouse" : false
        }
      );
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career1",
            "from":"2020/01/01",
            "to":"2020/01/30",
            "detail":["detail1","detail2"]
          }
        )
      );
      var now = DateTime.now();
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career2",
            "from":"2020/02/01",
            "to":now,
            "detail":["detail1","detail2"]
          }
        )
      );
      Map<String,Object> dsMap = ds.toList();
      expect(dsMap["User"] != null, true);
      Map<String,Object> user = dsMap["User"];
      expect(user["header"] != null, true);
      Map<String,Object> headers = user["header"];
      expect(headers[null] != null, true);
      List<Object> header = headers[null];
      expect(header[0], "hoge");
      expect(header[1], 20);
      expect(header[2], false);
      expect(user["recordList"] != null, true);
      Map<String,Object> recordLists = user["recordList"];
      expect(recordLists["career"] != null, true);
      List<List<Object>> career = recordLists["career"];
      expect(career.length, 2);
      expect(career[0][0], "career1");
      expect(career[0][1], stringToDate("2020/01/01"));
      expect(career[0][2], stringToDate("2020/01/30"));
      expect(career[0][3], ["detail1","detail2"]);
      expect(career[1][0], "career2");
      expect(career[1][1], stringToDate("2020/02/01"));
      expect(career[1][2], now);
      expect(career[1][3], ["detail1","detail2"]);
      ds.clear();
      expect(ds.getHeader()["name"], null);
      expect(ds.getHeader()["age"], null);
      expect(ds.getHeader()["hasSpouse"], null);
      expect(ds.getRecordList("career").length, 0);
      ds.fromList(dsMap);
      expect(ds.getHeader()["name"], "hoge");
      expect(ds.getHeader()["age"], 20);
      expect(ds.getHeader()["hasSpouse"], false);
      expect(ds.getRecordList("career").length, 2);
      expect(ds.getRecordList("career")[0]["title"], "career1");
      expect(ds.getRecordList("career")[0]["from"], stringToDate("2020/01/01"));
      expect(ds.getRecordList("career")[0]["to"], stringToDate("2020/01/30"));
      expect(ds.getRecordList("career")[0]["detail"], ["detail1","detail2"]);
      expect(ds.getRecordList("career")[1]["title"], "career2");
      expect(ds.getRecordList("career")[1]["from"], stringToDate("2020/02/01"));
      expect(ds.getRecordList("career")[1]["to"], now);
      expect(ds.getRecordList("career")[1]["detail"], ["detail1","detail2"]);
    });
  });
  group('view field test', () {
    test('view field test', () {
      DataSet ds = DataSet("User");
      ds.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age"),
            FieldSchema<bool>("hasSpouse"),
            FieldSchema<int>.view(
              "careerCount",
              (ds, rec, dv) => ds?.getRecordList("career")?.length,
              defaultValue: 0
            ),
            FieldSchema.record("careerTerm", "term")
          ]
        )
      );
      ds.setNestedRecordSchema(
        RecordSchema(
          [
            FieldSchema<DateTime>.view(
              "from",
              (ds, rec, dv){
                List<Object> froms = ds?.getRecordList("career")?.map((element) => element["from"])?.toList();
                froms?.sort();
                return froms?.length == 0 ? dv : froms?.first;
              },
              outputConverter: dateToString
            ),
            FieldSchema<DateTime>.view(
              "to",
              (ds, rec, dv){
                List<Object> tos = ds?.getRecordList("career")?.map((element) => element["to"])?.toList();
                tos?.sort();
                return tos?.length == 0 ? dv : tos?.last;
              },
              outputConverter: dateToString
            ),
          ]
        ),
         "term"
      );
      ds.setRecordListSchema(
        RecordSchema(
          [
            FieldSchema<String>("title"),
            FieldSchema<DateTime>("from", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<DateTime>("to", inputConverter: stringToDate, outputConverter: dateToString),
            FieldSchema<List<String>>("detail")
          ]
        ),
        "career"
      );
      ds.getHeader().fromMap(
        {
          "name":"hoge",
          "age":20,
          "hasSpouse" : false,
          "careerTerm" : {
            "from" : null,
            "to" : null
          }
        }
      );
      expect(ds.getHeader()["careerCount"], 0);
      expect((ds.getHeader()["careerTerm"] as Record)["from"], null);
      expect((ds.getHeader()["careerTerm"] as Record)["to"], null);
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career1",
            "from":"2020/01/01",
            "to":"2020/01/30",
            "detail":["detail1","detail2"]
          }
        )
      );
      var now = DateTime.now();
      ds.getRecordList("career").add(
        ds.getRecordList("career").createRecord(
          values:{
            "title":"career2",
            "from":"2020/02/01",
            "to":now,
            "detail":["detail1","detail2"]
          }
        )
      );
      expect(ds.getHeader()["careerCount"], 2);
      expect((ds.getHeader()["careerTerm"] as Record).getByName<String>("from"), "2020/01/01");
      expect((ds.getHeader()["careerTerm"] as Record).getByName<String>("to"), dateToString(now));
    });
  });
}
