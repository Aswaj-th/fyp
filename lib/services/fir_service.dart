import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:fyp/config/env.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => 'API Error ($statusCode): $message';
}

class FirService {
  final AppController _authController = Get.find<AppController>();
  final Duration timeout = Duration(seconds: 30);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_authController.jwt.value}',
  };

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '${Env.apiUrl}$endpoint',
      ).replace(queryParameters: queryParams);
      print('Making $method request to: $uri');

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers).timeout(timeout);
          break;
        case 'POST':
          final encodedBody = json.encode(body);
          print('Request body: $encodedBody');
          response = await http
              .post(uri, headers: _headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: _headers, body: json.encode(body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers).timeout(timeout);
          break;
        default:
          throw NetworkException('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}');
      print(
        'Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        String errorMessage;
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? 'Unknown error occurred';
        } catch (e) {
          errorMessage = 'Error: ${response.statusCode}';
        }
        throw ApiException(errorMessage, response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw NetworkException(
        'No internet connection. Make sure your server is running at ${Env.apiUrl}',
      );
    } on TimeoutException catch (e) {
      print('Timeout Exception: $e');
      throw NetworkException(
        'Request timed out. Server might be unresponsive.',
      );
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw NetworkException('Invalid response format. Check server response.');
    } catch (e) {
      print('Unexpected error: $e');
      if (e is NetworkException || e is ApiException) rethrow;
      throw NetworkException('An unexpected error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllFirs({
    String? status,
    String? stationId,
    String? createdById,
  }) async {
    final queryParams = {
      if (status != null) 'status': status,
      if (stationId != null) 'stationId': stationId,
      if (createdById != null) 'createdById': createdById,
    };

    final response = await _makeRequest(
      'GET',
      '/fir',
      queryParams: queryParams,
    );
    final List<dynamic> data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getFirById(String id) async {
    final response = await _makeRequest('GET', '/fir/$id/station');
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createFir(Map<String, dynamic> firData) async {
    print(firData);
    final response = await _makeRequest('POST', '/fir', body: firData);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createInvestigation(
    Map<String, dynamic> investigationData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/investigation',
      body: investigationData,
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createFirSummary(
    Map<String, dynamic> summaryData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/fir-summary',
      body: summaryData,
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> closeFir(String firId, String closedById) async {
    final response = await _makeRequest(
      'POST',
      '/fir/$firId/close',
      body: {'closedById': closedById},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateFir(
    String firId,
    Map<String, dynamic> updateData,
  ) async {
    final response = await _makeRequest('PUT', '/fir/$firId', body: updateData);
    return json.decode(response.body);
  }

  Future<void> deleteFir(String firId) async {
    await _makeRequest('DELETE', '/fir/$firId');
  }
}
