import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _vehiclesKey = 'vehicles';

  static Future<List<Map<String, dynamic>>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? vehiclesJson = prefs.getString(_vehiclesKey);

    if (vehiclesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(vehiclesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveVehicle(Map<String, dynamic> vehicle) async {
    final vehicles = await getVehicles();
    vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    vehicles.add(vehicle);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehiclesKey, jsonEncode(vehicles));
  }

  static Future<void> deleteVehicle(String id) async {
    final vehicles = await getVehicles();
    vehicles.removeWhere((v) => v['id'] == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehiclesKey, jsonEncode(vehicles));
  }

  static Future<void> updateVehicle(String id, Map<String, dynamic> updatedVehicle) async {
    final vehicles = await getVehicles();
    final index = vehicles.indexWhere((v) => v['id'] == id);

    if (index != -1) {
      vehicles[index] = {...updatedVehicle, 'id': id};

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_vehiclesKey, jsonEncode(vehicles));
    }
  }
}
