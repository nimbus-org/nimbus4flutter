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
  final LoginRequestSchema? login;

  @override
  List<HeaderQuerySchema>? get headerQuery => [
        HeaderQuerySchema(name: 'Common'),
        HeaderQuerySchema(
          name: 'Login',
          propertyNames: ['user_id', 'session_id'],
        ),
      ];

  @override
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@SchemaSerializable()
class LoginRequestSchema {
  LoginRequestSchema({this.mailAddress, this.password});

  factory LoginRequestSchema.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestSchemaFromJson(json);
  final String? mailAddress;
  final String? password;

  static RecordSchema? get schema => _$LoginRequestSchema();

  Map<String, dynamic> toJson() => _$LoginRequestSchemaToJson(this);
}
