import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_constants.dart';
import 'models/enquiry_model.dart';

class EnquiriesRepository {
  final http.Client _client;

  EnquiriesRepository({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetches enquiries list from GET /enquiries
  Future<List<EnquiryModel>> fetchEnquiries(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/enquiries');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => EnquiryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load enquiries (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Network error while loading enquiries: $e');
    }
  }

  /// Fetches employees list from GET /employees
  Future<List<Map<String, dynamic>>> fetchEmployees(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/employees');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetches services list from GET /services
  Future<List<Map<String, dynamic>>> fetchServices(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/services');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Creates a new enquiry POST /enquiries
  Future<EnquiryModel> createEnquiry({
    required String token,
    required String client,
    required String number,
    required String product,
    required String priority,
    required String notes,
    required int assignedToId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/enquiries');

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'client': client,
        'number': number,
        'product': product,
        'priority': priority,
        'notes': notes,
        'status': 'New',
        'assignedToId': assignedToId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EnquiryModel.fromJson(data);
    } else {
      throw Exception('Failed to create enquiry');
    }
  }

  /// Updates an existing enquiry PATCH /enquiries/:id
  Future<EnquiryModel> updateEnquiry({
    required String token,
    required int enquiryId,
    required String client,
    required String number,
    required String product,
    required String priority,
    required String notes,
    required int assignedToId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/enquiries/$enquiryId');

    final response = await _client.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'client': client,
        'number': number,
        'product': product,
        'priority': priority,
        'notes': notes,
        'assignedToId': assignedToId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EnquiryModel.fromJson(data);
    } else {
      throw Exception('Failed to update enquiry');
    }
  }

  /// Deletes an enquiry DELETE /enquiries/:id
  Future<void> deleteEnquiry({
    required String token,
    required int enquiryId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/enquiries/$enquiryId');

    final response = await _client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete enquiry');
    }
  }
}
