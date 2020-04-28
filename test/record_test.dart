import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  group('accessor test', () {
    test('map accessor', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2',defaultValue: 0),
        ]
      ));
      record["fieldName1"] = "hoge";
      expect(record["fieldName1"], 'hoge');
      expect(record["fieldName2"], 0);
    });
    test('map setter no field', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
        ]
      ));
      try{
        record["fieldName3"] = "hoge";
        fail("except Exception");
      }catch(e){
        expect(e is Exception, true);
      }
    });
    test('map setter type unmatch', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<int>('fieldName1', isPrimary: true),
        ]
      ));
      try{
        record["fieldName1"] = Map();
        fail("except Exception");
      }catch(e){
        expect(e is Exception, true);
      }
    });
     test('map accessor auto convert', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2'),
          FieldSchema<double>('fieldName3'),
          FieldSchema<bool>('fieldName4'),
        ]
      ));
      record["fieldName1"] = 100;
      expect(record["fieldName1"], '100');
      expect(record<int>()["fieldName1"], 100);
      record["fieldName1"] = 100.12;
      expect(record["fieldName1"], '100.12');
      expect(record<double>()["fieldName1"], 100.12);
      record["fieldName1"] = true;
      expect(record["fieldName1"], 'true');
      expect(record<bool>()["fieldName1"], true);
      record["fieldName2"] = '100';
      expect(record["fieldName2"], 100);
      record["fieldName3"] = '100.12';
      expect(record["fieldName3"], 100.12);
      record["fieldName4"] = 'true';
      expect(record["fieldName4"], true);
      record["fieldName4"] = '1';
      expect(record["fieldName4"], true);
      record["fieldName4"] = 'on';
      expect(record["fieldName4"], true);
      record["fieldName4"] = 'off';
      expect(record["fieldName4"], false);
    });
    test('index accessor', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2',defaultValue: 0),
        ]
      ));
      record.setByIndex(0,"hoge");
      expect(record.getByIndex(0), 'hoge');
      expect(record.getByIndex(1), 0);
    });
    test('index setter no field', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
        ]
      ));
      try{
        record.setByIndex(1,"hoge");
        fail("except Exception");
      }catch(e){
        expect(e is Exception, true);
      }
      try{
        record.getByIndex(1);
        fail("except Exception");
      }catch(e){
        expect(e is Exception, true);
      }
    });
    test('index setter type unmatch', () {
      final record = Record(RecordSchema(
        [
          FieldSchema<int>('fieldName1', isPrimary: true),
        ]
      ));
      try{
        record.setByIndex(0, Map());
        fail("except Exception");
      }catch(e){
        expect(e is Exception, true);
      }
    });
  });
  group('primary key test', () {
    test('single primary key', () {
      final record1 = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2',defaultValue: 0),
        ]
      ));
      final record2 = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2',defaultValue: 0),
        ]
      ));
      record1["fieldName1"] = "hoge";
      record1["fieldName2"] = 100;
      record2["fieldName1"] = "hoge";
      record2["fieldName2"] = 100;
      expect(record1.primaryKey == record2.primaryKey, true);
      record2["fieldName1"] = "fuga";
      expect(record1.primaryKey == record2.primaryKey, false);
    });
    test('complex primary key', () {
      final record1 = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2', isPrimary: true, defaultValue: 0),
          FieldSchema<double>('fieldName3',defaultValue: 0.0),
        ]
      ));
      final record2 = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2', isPrimary: true, defaultValue: 0),
          FieldSchema<double>('fieldName3',defaultValue: 0.0),
        ]
      ));
      record1["fieldName1"] = "hoge";
      record1["fieldName2"] = 100;
      record1["fieldName3"] = 0.1;
      record2["fieldName1"] = "hoge";
      record2["fieldName2"] = 100;
      record2["fieldName3"] = 0.1;
      expect(record1.primaryKey == record2.primaryKey, true);
      record2["fieldName2"] = 200;
      expect(record1.primaryKey == record2.primaryKey, false);
    });
  });
  group('convert map test', () {
    test('simple record', () {
       final record = Record(RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2', isPrimary: true, defaultValue: 0),
          FieldSchema<double>('fieldName3',defaultValue: 0.0),
        ]
      ));
      record["fieldName1"] = "hoge";
      record["fieldName2"] = 100;
      record["fieldName3"] = 0.1;
      Map map = record.toMap();
      expect(map.length, 3);
      expect(map["fieldName1"], "hoge");
      expect(map["fieldName2"], 100);
      expect(map["fieldName3"], 0.1);
   });
  });
}