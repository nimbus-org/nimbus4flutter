import 'package:nimbus_annotation/nimbus_annotation.dart';

@DatasetSerializable()
class ApiResponseModel {
  ApiResponseModel({this.common});

  @DatasetHeader()
  final CommonRecord? common;
}

@RecordSerializable()
class CommonRecord {
  CommonRecord({this.resultCode, this.resultMessage});

  final String? resultCode;
  final String? resultMessage;
}
