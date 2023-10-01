// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// RecordSupporterGenerator
// **************************************************************************

class _CommonRecord extends Record {
  _CommonRecord()
      : super(
          RecordSchema([
            FieldSchema('result_code'),
            FieldSchema('result_message'),
          ]),
        );
}

CommonRecord _$CommonRecordFromJson(Map<String, dynamic> json) {
  final ds = _CommonRecord();
  ds.fromMap(json);
  return CommonRecord(
    resultCode: json['result_code'],
    resultMessage: json['result_message'],
  );
}

RecordSchema? _$CommonRecordSchema() {
  return _CommonRecord().schema;
}

Map<String, dynamic> _$CommonRecordToJson(CommonRecord instance) {
  final ds = _CommonRecord();
  ds.setByName('result_code', instance.resultCode);
  ds.setByName('result_message', instance.resultMessage);
  return ds.toMap();
}

// **************************************************************************
// DatasetSupporterGenerator
// **************************************************************************

class _DataSet extends DataSet {
  _DataSet() : super('') {
    setHeaderSchema(_CommonRecord().schema!, 'Common');
  }
}

ApiResponseModel _$ApiResponseModelFromJson(Map<String, dynamic> json) {
  final ds = _DataSet();
  ds.fromList(json);
  return ApiResponseModel(
    common: CommonRecord.fromJson(
      ds.getHeader('Common')?.toMap() ?? {},
    ),
  );
}

Map<String, dynamic> _$ApiResponseModelToJson(ApiResponseModel instance) {
  final ds = _DataSet();
  final commonRecord = _CommonRecord();
  commonRecord.fromMap(instance.common?.toJson());
  ds.setHeader(commonRecord, 'Common');
  return ds.toMap();
}
