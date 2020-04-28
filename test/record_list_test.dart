import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  group('primary test', () {
    test('primary test', () {
      RecordList list = RecordList(
        RecordSchema(
          [
            FieldSchema<String>("fieldName1",isPrimary: true),
            FieldSchema<int>("fieldName2"),
          ]
        )
      );
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "hoge",
          "fieldName2" :  1
        }
      ));
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "fuga",
          "fieldName2" :  2
        }
      ));
      expect(list.primary(list.createRecord(values: {"fieldName1" : "hoge"}))["fieldName2"], 1);
      expect(list.primary(list.createRecord(values: {"fieldName1" : "fuga"}))["fieldName2"], 2);
      expect(list.primary(list.createRecord(values: {"fieldName1" : "piyo"})), null);
    });
   test('non primary test', () {
      RecordList list = RecordList(
        RecordSchema(
          [
            FieldSchema<String>("fieldName1"),
            FieldSchema<int>("fieldName2"),
          ]
        )
      );
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "hoge",
          "fieldName2" :  1
        }
      ));
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "fuga",
          "fieldName2" :  2
        }
      ));
      expect(list.primary(list.createRecord(values: {"fieldName1" : "hoge"})), null);
    });
  });
  group('sort test', () {
    test('sortBy test', () {
      RecordList list = RecordList(
        RecordSchema(
          [
            FieldSchema<String>("fieldName1"),
            FieldSchema<int>("fieldName2"),
          ]
        )
      );
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "hoge",
          "fieldName2" :  1
        }
      ));
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "fuga",
          "fieldName2" :  3
        }
      ));
      list.add(list.createRecord(
        values: {
          "fieldName1" :  "piyo",
          "fieldName2" :  2
        }
      ));
      list.sortBy(["fieldName2"]);
      expect(list[0]["fieldName1"], "hoge");
      expect(list[1]["fieldName1"], "piyo");
      expect(list[2]["fieldName1"], "fuga");
      list.sortBy(["fieldName2"], [false]);
      expect(list[0]["fieldName1"], "fuga");
      expect(list[1]["fieldName1"], "piyo");
      expect(list[2]["fieldName1"], "hoge");
    });
  });
}
