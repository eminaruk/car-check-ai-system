import 'api_service.dart';

class StorageService {
  static Future<List<Map<String, dynamic>>> getVehicles() async {
    return await ApiService.getVehicles();
  }

  static Future<Map<String, dynamic>> saveVehicle(Map<String, dynamic> vehicle) async {
    return await ApiService.createVehicle(vehicle);
  }

  static Future<void> deleteVehicle(String id) async {
    await ApiService.deleteVehicle(id);
  }

  static Future<Map<String, dynamic>> updateVehicle(String id, Map<String, dynamic> updatedVehicle) async {
    return await ApiService.updateVehicle(id, updatedVehicle);
  }

  // Check methods
  static Future<List<Map<String, dynamic>>> getChecks() async {
    return await ApiService.getChecks();
  }

  static Future<Map<String, dynamic>> saveCheck(Map<String, dynamic> check) async {
    return await ApiService.createCheck(check);
  }
}
