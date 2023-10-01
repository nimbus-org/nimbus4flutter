import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

part 'api_response_model.g.dart';

@DatasetSerializable()
class ApiResponseModel {
  ApiResponseModel({this.common});

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseModelToJson(this);

  @DatasetHeader()
  final CommonRecord? common;
}

@RecordSerializable()
class CommonRecord {
  CommonRecord({this.resultCode, this.resultMessage});

  factory CommonRecord.fromJson(Map<String, dynamic> json) =>
      _$CommonRecordFromJson(json);

  static RecordSchema? get schema => _$CommonRecordSchema();

  Map<String, dynamic> toJson() => _$CommonRecordToJson(this);

  final String? resultCode;
  final String? resultMessage;
}