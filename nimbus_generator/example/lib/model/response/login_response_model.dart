import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

part 'login_response_model.g.dart';

/// "schema": {
//      "header": {
//          "Common": [
//              "result_code",
//              "result_message"
//          ],
//          "Login": [
//              "user_id",
//              "session_id",
//          ]
//      }
//  },
@DatasetSerializable(name: 'ResponseDataSet')
class LoginResponseModel {
  LoginResponseModel({this.login});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  @DatasetHeader()
  final LoginResponseSchema? login;
}

@SchemaSerializable()
class LoginResponseSchema {
  LoginResponseSchema({this.userId, this.sessionId});

  factory LoginResponseSchema.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseSchemaFromJson(json);

  static RecordSchema? get schema => _$LoginResponseSchema();

  Map<String, dynamic> toJson() => _$LoginResponseSchemaToJson(this);

  final String? userId;
  final String? sessionId;
}
