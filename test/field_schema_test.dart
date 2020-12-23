import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  group('constructor test', () {
    test('constructor name', () {
      final fieldSchema = FieldSchema<String>('fieldName1');
      expect(fieldSchema.name, 'fieldName1');
      expect(fieldSchema.type == String, true);
      expect(fieldSchema.instanceof(""), true);
    });
    test('constructor converter', () {
      final fieldSchema = FieldSchema<List<int>>(
        'fieldName1',
        inputConverter: (ds, rec, input)=>Utf8Encoder().convert(input),
        outputConverter: (ds, rec, input)=>Utf8Decoder().convert(input)
      );
      expect(fieldSchema.name, 'fieldName1');
      expect(fieldSchema.instanceof(List<int>()), true);
      expect(fieldSchema.parseValue(null, null, "hoge"), Utf8Encoder().convert("hoge"));
      expect(fieldSchema.formatValue(null, null, Utf8Encoder().convert("hoge")), "hoge");
    });
    test('constructor record', () {
      final fieldSchema = FieldSchema.record('fieldName1','nestedRecordName');
      expect(fieldSchema.name, 'fieldName1');
      expect(fieldSchema.type == Record, true);
      expect(fieldSchema.schema, 'nestedRecordName');
    });
  });
}
