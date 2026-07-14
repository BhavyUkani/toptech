import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? read(String key) {
    return _prefs.getString(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> saveToken(String token) async {
    await write('token', token);
  }

  String? getToken() {
    return read('token');
  }

  Future<void> saveEmployee(String employeeJson) async {
    await write('employee_data', employeeJson);
  }

  String? getEmployee() {
    return read('employee_data');
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
