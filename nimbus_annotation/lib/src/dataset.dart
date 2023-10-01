/// Values for the automatic field renaming behavior for [DatasetSerializable] and [RecordSerializable].
enum FieldRename {
  /// Use the field name without changes.
  none,

  /// Encodes a field named `snakeCase` with a JSON key `snake_case`.
  snake,

  /// Encodes a field named `pascalCase` with a JSON key `PascalCase`.
  pascal,
}

class DatasetSerializable {
  const DatasetSerializable({
    this.name = '',
    this.fieldRename = FieldRename.snake,
  });

  final String name;
  final FieldRename fieldRename;
}

class DatasetHeader {
  const DatasetHeader();
}

class DatasetRecordList {
  const DatasetRecordList();
}

class RecordSerializable {
  const RecordSerializable({this.fieldRename = FieldRename.snake});

  final FieldRename fieldRename;
}
