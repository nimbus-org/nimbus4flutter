import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

import 'api_request_model.dart';

part 'login_request_model.g.dart';

@DatasetSerializable()
class LoginRequestModel extends ApiRequestModel {
  LoginRequestModel({this.login});

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
  @DatasetHeader()
  final LoginRequestRecord? login;

  @override
  List<HeaderQueryRecord>? get headerQuery => [
        HeaderQueryRecord(name: 'Common'),
        HeaderQueryRecord(
          name: 'Login',
          propertyNames: ['user_id', 'session_id'],
        ),
      ];

  @override
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@RecordSerializable()
class LoginRequestRecord {
  LoginRequestRecord({this.mailAddress, this.password});

  factory LoginRequestRecord.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestRecordFromJson(json);
  final String? mailAddress;
  final String? password;

  static RecordSchema? get schema => _$LoginRequestRecordSchema();

  Map<String, dynamic> toJson() => _$LoginRequestRecordToJson(this);
}
