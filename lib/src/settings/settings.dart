import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../nimbus4flutter.dart';

Future<T?> loadSetting<T>(String name, T setting) async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? settingJson = prefs.getString(name);
  if(settingJson == null){
    return null;
  }
  if(setting is Record){
    return setting.fromMap(JsonDecoder().convert(settingJson)) as T;
  }else if(setting is RecordList){
    return setting.fromMap(JsonDecoder().convert(settingJson)) as T;
  }else if(setting is DataSet){
    return setting.fromMap(JsonDecoder().convert(settingJson)) as T;
  }else{
    return JsonDecoder().convert(settingJson);
  }
}

void saveSetting(String name, Object setting) async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String settingJson;
  if(setting is Record){
    settingJson = JsonEncoder().convert(setting.toMap(toJsonType: true));
  }else if(setting is RecordList){
    settingJson = JsonEncoder().convert(setting.toMap(toJsonType: true));
  }else if(setting is DataSet){
    settingJson = JsonEncoder().convert(setting.toMap(toJsonType: true));
  }else{
    settingJson = JsonEncoder().convert(setting);
  }
  prefs.setString(name, settingJson);
}
