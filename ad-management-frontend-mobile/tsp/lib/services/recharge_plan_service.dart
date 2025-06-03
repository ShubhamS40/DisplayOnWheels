import 'dart:convert';
import 'package:http/http.dart' as http;

// Service to handle API calls to the recharge plan endpoints
class RechargePlanService {
  final String baseUrl = 'http://3.110.135.112:5000/api/admin-manage';
  
  // Get all recharge plans
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recharge'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plans: $e');
    }
  }
  
  // Get plan by ID
  Future<Map<String, dynamic>> getPlanById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recharge/$id'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plan: $e');
    }
  }
  
  // Create a new recharge plan
  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-recharge-plan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(planData)
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating plan: $e');
    }
  }
  
  // Update an existing recharge plan
  Future<Map<String, dynamic>> updatePlan(int id, Map<String, dynamic> planData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-recharge-plan/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(planData)
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating plan: $e');
    }
  }
  
  // Toggle plan active status
  Future<Map<String, dynamic>> togglePlanActive(int id, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/is-recharge-plan-active/$id/active'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isActive': isActive})
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle plan status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling plan status: $e');
    }
  }
  
  // Delete a recharge plan
  Future<bool> deletePlan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete-recharge-plan/$id'));
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting plan: $e');
    }
  }
}
