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
  final CommonSchema? common;
}

@SchemaSerializable()
class CommonSchema {
  CommonSchema({this.resultCode, this.resultMessage});

  factory CommonSchema.fromJson(Map<String, dynamic> json) =>
      _$CommonSchemaFromJson(json);

  static RecordSchema? get schema => _$CommonSchema();

  Map<String, dynamic> toJson() => _$CommonSchemaToJson(this);

  final String? resultCode;
  final String? resultMessage;
}
