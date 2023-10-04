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
  final CommonRequestSchema? common;

  @DatasetRecordList()
  final List<HeaderQuerySchema>? headerQuery;
  @DatasetRecordList()
  final List? recordListQuery;
  @DatasetRecordList()
  final List? nestedRecordQuery;
  @DatasetRecordList()
  final List? nestedRecordListQuery;

  Map<String, dynamic> toJson() => _$ApiRequestModelToJson(this);
}

@SchemaSerializable(fieldRename: FieldRename.none)
class HeaderQuerySchema {
  HeaderQuerySchema({this.name, this.propertyNames});

  factory HeaderQuerySchema.fromJson(Map<String, dynamic> json) =>
      _$HeaderQuerySchemaFromJson(json);
  final String? name;
  final List<String>? propertyNames;

  static RecordSchema? get schema => _$HeaderQuerySchema();

  Map<String, dynamic> toJson() => _$HeaderQuerySchemaToJson(this);
}

@SchemaSerializable()
class CommonRequestSchema {
  CommonRequestSchema({this.os, this.application, this.userId, this.sessionId});

  factory CommonRequestSchema.fromJson(Map<String, dynamic> json) =>
      _$CommonRequestSchemaFromJson(json);
  final OsSchema? os;
  final ApplicationSchema? application;
  final String? userId;
  final String? sessionId;

  static RecordSchema? get schema => _$CommonRequestSchema();

  Map<String, dynamic> toJson() => _$CommonRequestSchemaToJson(this);
}

@SchemaSerializable()
class OsSchema {
  OsSchema({this.osId, this.osVersion});

  factory OsSchema.fromJson(Map<String, dynamic> json) =>
      _$OsSchemaFromJson(json);

  final String? osId;
  final String? osVersion;

  static RecordSchema? get schema => _$OsSchema();

  Map<String, dynamic> toJson() => _$OsSchemaToJson(this);
}

@SchemaSerializable()
class ApplicationSchema {
  ApplicationSchema({this.applicationId, this.applicationVersion});

  factory ApplicationSchema.fromJson(Map<String, dynamic> json) =>
      _$ApplicationSchemaFromJson(json);

  final String? applicationId;
  final String? applicationVersion;

  static RecordSchema? get schema => _$ApplicationSchema();

  Map<String, dynamic> toJson() => _$ApplicationSchemaToJson(this);
}
