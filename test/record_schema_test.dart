import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  group('constructor test', () {
    test('constructor', () {
      final recordSchema = RecordSchema(
        [
          FieldSchema<String>('fieldName1', isPrimary: true),
          FieldSchema<int>('fieldName2'),
        ]
      );
      expect(recordSchema.fields[0].name, 'fieldName1');
      expect(recordSchema.fields[1].name, 'fieldName2');
      expect(recordSchema.fieldMap['fieldName1']!.name, 'fieldName1');
      expect(recordSchema.fieldMap['fieldName2']!.name, 'fieldName2');
      expect(recordSchema.hasPrimary, true);
      expect(recordSchema.primaryFields.length, 1);
      expect(recordSchema.primaryFields[0].name, 'fieldName1');
      expect(recordSchema.length, 2);
      expect(recordSchema.names.toList(), ['fieldName1','fieldName2']);
    });
  });
}
