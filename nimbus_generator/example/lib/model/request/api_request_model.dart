import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

part 'api_request_model.g.dart';

@DatasetSerializable()
class ApiRequestModel {
  ApiRequestModel({
    this.common,
    this.headerQuery,
    this.recordListQuery,
    this.nestedRecordQuery,
    this.nestedRecordListQuery,
  });

  factory ApiRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestModelFromJson(json);
  @DatasetHeader()
  final CommonRequestRecord? common;

  @DatasetRecordList()
  final List<HeaderQueryRecord>? headerQuery;
  @DatasetRecordList()
  final List? recordListQuery;
  @DatasetRecordList()
  final List? nestedRecordQuery;
  @DatasetRecordList()
  final List? nestedRecordListQuery;

  Map<String, dynamic> toJson() => _$ApiRequestModelToJson(this);
}

@RecordSerializable(fieldRename: FieldRename.none)
class HeaderQueryRecord {
  HeaderQueryRecord({this.name, this.propertyNames});

  factory HeaderQueryRecord.fromJson(Map<String, dynamic> json) =>
      _$HeaderQueryRecordFromJson(json);
  final String? name;
  final List<String>? propertyNames;

  static RecordSchema? get schema => _$HeaderQueryRecordSchema();

  Map<String, dynamic> toJson() => _$HeaderQueryRecordToJson(this);
}

@RecordSerializable()
class CommonRequestRecord {
  CommonRequestRecord({this.os, this.application, this.userId, this.sessionId});

  factory CommonRequestRecord.fromJson(Map<String, dynamic> json) =>
      _$CommonRequestRecordFromJson(json);
  final OsRecord? os;
  final ApplicationRecord? application;
  final String? userId;
  final String? sessionId;

  static RecordSchema? get schema => _$CommonRequestRecordSchema();

  Map<String, dynamic> toJson() => _$CommonRequestRecordToJson(this);
}

@RecordSerializable()
class OsRecord {
  OsRecord({this.osId, this.osVersion});

  factory OsRecord.fromJson(Map<String, dynamic> json) =>
      _$OsRecordFromJson(json);

  final String? osId;
  final String? osVersion;

  static RecordSchema? get schema => _$OsRecordSchema();

  Map<String, dynamic> toJson() => _$OsRecordToJson(this);
}

@RecordSerializable()
class ApplicationRecord {
  ApplicationRecord({this.applicationId, this.applicationVersion});

  factory ApplicationRecord.fromJson(Map<String, dynamic> json) =>
      _$ApplicationRecordFromJson(json);

  final String? applicationId;
  final String? applicationVersion;

  static RecordSchema? get schema => _$ApplicationRecordSchema();

  Map<String, dynamic> toJson() => _$ApplicationRecordToJson(this);
}
