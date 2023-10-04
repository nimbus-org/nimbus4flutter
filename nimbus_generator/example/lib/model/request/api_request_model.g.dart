// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_request_model.dart';

// **************************************************************************
// RecordSupporterGenerator
// **************************************************************************

class _HeaderQueryRecord extends Record {
  _HeaderQueryRecord()
      : super(
          RecordSchema([
            FieldSchema('name'),
            FieldSchema('propertyNames'),
          ]),
        );
}

HeaderQuerySchema _$HeaderQuerySchemaFromJson(Map<String, dynamic> json) {
  final ds = _HeaderQueryRecord();
  ds.fromMap(json);
  return HeaderQuerySchema(
    name: json['name'],
    propertyNames: json['propertyNames'],
  );
}

RecordSchema? _$HeaderQuerySchema() {
  return _HeaderQueryRecord().schema;
}

Map<String, dynamic> _$HeaderQuerySchemaToJson(HeaderQuerySchema instance) {
  final ds = _HeaderQueryRecord();
  ds.setByName('name', instance.name);
  ds.setByName('propertyNames', instance.propertyNames);
  return ds.toMap();
}

class _CommonRequestRecord extends Record {
  _CommonRequestRecord()
      : super(
          RecordSchema([
            FieldSchema.record('os', 'os'),
            FieldSchema.record('application', 'application'),
            FieldSchema('user_id'),
            FieldSchema('session_id'),
          ]),
        ) {
    setByName('os', _OsRecord());
    setByName('application', _ApplicationRecord());
  }
}

CommonRequestSchema _$CommonRequestSchemaFromJson(Map<String, dynamic> json) {
  final ds = _CommonRequestRecord();
  ds.fromMap(json);
  return CommonRequestSchema(
    os: OsSchema.fromJson(json['os']),
    application: ApplicationSchema.fromJson(json['application']),
    userId: json['user_id'],
    sessionId: json['session_id'],
  );
}

RecordSchema? _$CommonRequestSchema() {
  return _CommonRequestRecord().schema;
}

Map<String, dynamic> _$CommonRequestSchemaToJson(CommonRequestSchema instance) {
  final ds = _CommonRequestRecord();
  final osRecord = _OsRecord().fromMap(instance.os?.toJson() ?? {});
  ds.setByName('os', osRecord);
  final applicationRecord =
      _ApplicationRecord().fromMap(instance.application?.toJson() ?? {});
  ds.setByName('application', applicationRecord);
  ds.setByName('user_id', instance.userId);
  ds.setByName('session_id', instance.sessionId);
  return ds.toMap();
}

class _OsRecord extends Record {
  _OsRecord()
      : super(
          RecordSchema([
            FieldSchema('os_id'),
            FieldSchema('os_version'),
          ]),
        );
}

OsSchema _$OsSchemaFromJson(Map<String, dynamic> json) {
  final ds = _OsRecord();
  ds.fromMap(json);
  return OsSchema(
    osId: json['os_id'],
    osVersion: json['os_version'],
  );
}

RecordSchema? _$OsSchema() {
  return _OsRecord().schema;
}

Map<String, dynamic> _$OsSchemaToJson(OsSchema instance) {
  final ds = _OsRecord();
  ds.setByName('os_id', instance.osId);
  ds.setByName('os_version', instance.osVersion);
  return ds.toMap();
}

class _ApplicationRecord extends Record {
  _ApplicationRecord()
      : super(
          RecordSchema([
            FieldSchema('application_id'),
            FieldSchema('application_version'),
          ]),
        );
}

ApplicationSchema _$ApplicationSchemaFromJson(Map<String, dynamic> json) {
  final ds = _ApplicationRecord();
  ds.fromMap(json);
  return ApplicationSchema(
    applicationId: json['application_id'],
    applicationVersion: json['application_version'],
  );
}

RecordSchema? _$ApplicationSchema() {
  return _ApplicationRecord().schema;
}

Map<String, dynamic> _$ApplicationSchemaToJson(ApplicationSchema instance) {
  final ds = _ApplicationRecord();
  ds.setByName('application_id', instance.applicationId);
  ds.setByName('application_version', instance.applicationVersion);
  return ds.toMap();
}

// **************************************************************************
// DatasetSupporterGenerator
// **************************************************************************

class _DataSet extends DataSet {
  _DataSet() : super('') {
    setHeaderSchema(_CommonRequestRecord().schema!, 'Common');
    setRecordListSchema(_HeaderQueryRecord().schema!, 'HeaderQuery');
    setRecordListSchema(RecordSchema(const []), 'RecordListQuery');
    setRecordListSchema(RecordSchema(const []), 'NestedRecordQuery');
    setRecordListSchema(RecordSchema(const []), 'NestedRecordListQuery');
  }
}

ApiRequestModel _$ApiRequestModelFromJson(Map<String, dynamic> json) {
  final ds = _DataSet();
  ds.fromList(json);
  return ApiRequestModel(
    common: CommonRequestSchema.fromJson(
      ds.getHeader('Common')?.toMap() ?? {},
    ),
    headerQuery: ds
        .getRecordList('HeaderQuery')
        ?.toMap()
        .map((e) => HeaderQuerySchema.fromJson(e))
        .toList(),
    recordListQuery:
        ds.getRecordList('RecordListQuery')?.toMap().map((e) => e).toList(),
    nestedRecordQuery:
        ds.getRecordList('NestedRecordQuery')?.toMap().map((e) => e).toList(),
    nestedRecordListQuery: ds
        .getRecordList('NestedRecordListQuery')
        ?.toMap()
        .map((e) => e)
        .toList(),
  );
}

Map<String, dynamic> _$ApiRequestModelToJson(ApiRequestModel instance) {
  final ds = _DataSet();
  final commonRecord = _CommonRequestRecord();
  commonRecord.fromMap(instance.common?.toJson());
  ds.setHeader(commonRecord, 'Common');
  final headerQueryRecord = RecordList(_HeaderQueryRecord().schema!);
  headerQueryRecord
      .fromMap(instance.headerQuery?.map((e) => e.toJson()).toList());
  ds.setRecordList(headerQueryRecord, 'HeaderQuery');
  return ds.toMap();
}
