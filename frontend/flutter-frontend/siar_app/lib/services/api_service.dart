import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/students'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error al obtener estudiantes: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard/alerts'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error al obtener dashboard: $e');
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> getProgramsDistribution() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard/programs'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error al obtener programas: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
    return {'success': false, 'message': 'Error de conexión con el servidor'};
  }

  static Future<bool> intervenirEstudiante(String studentId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/$studentId/intervenir'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error al intervenir estudiante: $e');
    }
    return false;
  }
}