import 'package:analyzer/dart/constant/value.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';
import 'package:source_gen/source_gen.dart';

T? readEnum<T extends Enum>(ConstantReader reader, List<T> values) =>
    reader.isNull
        ? null
        : enumValueForDartObject<T>(
            reader.objectValue,
            values,
            (f) => f.name,
          );

T enumValueForDartObject<T>(
  DartObject source,
  List<T> items,
  String Function(T) name,
) =>
    items[source.getField('index')!.toIntValue()!];

extension ConstantReaderExt on ConstantReader {
  DatasetSerializable toDataSet() {
    return DatasetSerializable(
      name: this.read('name').literalValue as String,
      fieldRename: readEnum(this.read('fieldRename'), FieldRename.values) ??
          FieldRename.none,
    );
  }

  RecordSerializable toRecord() {
    return RecordSerializable(
      fieldRename: readEnum(this.read('fieldRename'), FieldRename.values) ??
          FieldRename.none,
    );
  }
}
