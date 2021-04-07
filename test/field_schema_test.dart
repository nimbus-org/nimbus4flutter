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
      expect(fieldSchema.parseValue(null, Record.empty(), "hoge"), "hoge");
      expect(fieldSchema.parseValue(null, Record.empty(), null), null);
      expect(fieldSchema.formatValue<String>(null, Record.empty(), "hoge"), "hoge");
      expect(fieldSchema.formatValue<String>(null, Record.empty(), null), null);
    });
    test('constructor converter', () {
      final fieldSchema = FieldSchema<List<int>>(
        'fieldName1',
        inputConverter: (ds, rec, input)=>input == null ? null : Utf8Encoder().convert(input),
        outputConverter: (ds, rec, input)=>input == null ? null : Utf8Decoder().convert(input)
      );
      expect(fieldSchema.name, 'fieldName1');
      expect(fieldSchema.instanceof(<int>[]), true);
      expect(fieldSchema.parseValue(null, Record.empty(), "hoge"), Utf8Encoder().convert("hoge"));
      expect(fieldSchema.parseValue(null, Record.empty(), null), null);
      expect(fieldSchema.formatValue<String>(null, Record.empty(), Utf8Encoder().convert("hoge")), "hoge");
      expect(fieldSchema.formatValue<String>(null, Record.empty(), null), null);
    });
    test('constructor record', () {
      final fieldSchema = FieldSchema.record('fieldName1','nestedRecordName');
      expect(fieldSchema.name, 'fieldName1');
      expect(fieldSchema.type == Record, true);
      expect(fieldSchema.schema, 'nestedRecordName');
    });
  });
}
