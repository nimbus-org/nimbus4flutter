// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// RecordSupporterGenerator
// **************************************************************************

class _LoginResponseRecord extends Record {
  _LoginResponseRecord()
      : super(
          RecordSchema([
            FieldSchema('user_id'),
            FieldSchema('session_id'),
          ]),
        );
}

LoginResponseSchema _$LoginResponseSchemaFromJson(Map<String, dynamic> json) {
  final ds = _LoginResponseRecord();
  ds.fromMap(json);
  return LoginResponseSchema(
    userId: json['user_id'],
    sessionId: json['session_id'],
  );
}

RecordSchema? _$LoginResponseSchema() {
  return _LoginResponseRecord().schema;
}

Map<String, dynamic> _$LoginResponseSchemaToJson(LoginResponseSchema instance) {
  final ds = _LoginResponseRecord();
  ds.setByName('user_id', instance.userId);
  ds.setByName('session_id', instance.sessionId);
  return ds.toMap();
}

// **************************************************************************
// DatasetSupporterGenerator
// **************************************************************************

class _DataSet extends DataSet {
  _DataSet() : super('ResponseDataSet') {
    setHeaderSchema(_LoginResponseRecord().schema!, 'Login');
  }
}

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) {
  final ds = _DataSet();
  ds.fromList(json);
  return LoginResponseModel(
    login: LoginResponseSchema.fromJson(
      ds.getHeader('Login')?.toMap() ?? {},
    ),
  );
}

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) {
  final ds = _DataSet();
  final loginRecord = _LoginResponseRecord();
  loginRecord.fromMap(instance.login?.toJson());
  ds.setHeader(loginRecord, 'Login');
  return ds.toMap();
}
