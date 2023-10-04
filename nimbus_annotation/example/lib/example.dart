import 'package:nimbus_annotation/nimbus_annotation.dart';

@DatasetSerializable()
class ApiResponseModel {
  ApiResponseModel({this.common});

  @DatasetHeader()
  final CommonSchema? common;
}

@SchemaSerializable()
class CommonSchema {
  CommonSchema({this.resultCode, this.resultMessage});

  final String? resultCode;
  final String? resultMessage;
}
