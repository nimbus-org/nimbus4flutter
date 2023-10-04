// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_model.dart';

// **************************************************************************
// RecordSupporterGenerator
// **************************************************************************

class _LoginRequestRecord extends Record {
  _LoginRequestRecord()
      : super(
          RecordSchema([
            FieldSchema('mail_address'),
            FieldSchema('password'),
          ]),
        );
}

LoginRequestSchema _$LoginRequestSchemaFromJson(Map<String, dynamic> json) {
  final ds = _LoginRequestRecord();
  ds.fromMap(json);
  return LoginRequestSchema(
    mailAddress: json['mail_address'],
    password: json['password'],
  );
}

RecordSchema? _$LoginRequestSchema() {
  return _LoginRequestRecord().schema;
}

Map<String, dynamic> _$LoginRequestSchemaToJson(LoginRequestSchema instance) {
  final ds = _LoginRequestRecord();
  ds.setByName('mail_address', instance.mailAddress);
  ds.setByName('password', instance.password);
  return ds.toMap();
}

// **************************************************************************
// DatasetSupporterGenerator
// **************************************************************************

class _DataSet extends DataSet {
  _DataSet() : super('') {
    setHeaderSchema(_LoginRequestRecord().schema!, 'Login');
    setRecordListSchema(HeaderQuerySchema.schema!, 'HeaderQuery');
  }
}

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) {
  final ds = _DataSet();
  ds.fromList(json);
  return LoginRequestModel(
    login: LoginRequestSchema.fromJson(
      ds.getHeader('Login')?.toMap() ?? {},
    ),
  );
}

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) {
  final ds = _DataSet();
  final loginRecord = _LoginRequestRecord();
  loginRecord.fromMap(instance.login?.toJson());
  ds.setHeader(loginRecord, 'Login');
  ds.setRecordList(
    RecordList(HeaderQuerySchema.schema!)
        .fromMap(instance.headerQuery?.map((e) => e.toJson()).toList()),
    'HeaderQuery',
  );
  return ds.toMap();
}
