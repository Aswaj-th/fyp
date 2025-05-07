import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/get.dart';
import 'package:get/get.dart';

class HCEditInvestigationFirst extends StatefulWidget {
  final String firId;

  const HCEditInvestigationFirst({required this.firId, Key? key})
    : super(key: key);

  @override
  State<HCEditInvestigationFirst> createState() =>
      _HCEditInvestigationFirstState();
}

class _HCEditInvestigationFirstState extends State<HCEditInvestigationFirst> {
  final AppController _authController = Get.find<AppController>();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _firData;

  @override
  void initState() {
    super.initState();
    _loadFirData();
  }

  Future<void> _loadFirData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/fir/${widget.firId}/station'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      // print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _firData = data['data'];
            // print(_firData?['investigations']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load FIR data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationCard(Map<String, dynamic> investigation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    investigation['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (investigation['isImportant'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Important',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              investigation['description'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: const Color(0xFF002B45),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadFirData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Case Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002B45),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_firData != null) ...[
                      _buildDetailRow('Title', _firData!['title'] ?? ''),
                      _buildDetailRow(
                        'Description',
                        _firData!['description'] ?? '',
                      ),
                      _buildDetailRow('Type', _firData!['complaintType'] ?? ''),
                      _buildDetailRow('Status', _firData!['status'] ?? ''),
                      _buildDetailRow(
                        'Incident Date',
                        _firData!['incidentDate'] ?? '',
                      ),
                      _buildDetailRow(
                        'Incident Address',
                        _firData!['incidentAddress'] ?? '',
                      ),
                      _buildDetailRow(
                        'Complainant Name',
                        _firData!['complainantName'] ?? '',
                      ),
                      _buildDetailRow(
                        'Complainant Gender',
                        _firData!['complainantGender'] ?? '',
                      ),
                      _buildDetailRow(
                        'Complainant Mobile',
                        _firData!['complainantMobile'] ?? '',
                      ),
                      if (_firData!['complainantEmail'] != null)
                        _buildDetailRow(
                          'Complainant Email',
                          _firData!['complainantEmail'] ?? '',
                        ),
                      _buildDetailRow(
                        'Complainant Address',
                        _firData!['complainantAddress'] ?? '',
                      ),
                      if (_firData!['approvedDate'] != null)
                        _buildDetailRow(
                          'Approved Date',
                          _firData!['approvedDate'] ?? '',
                        ),
                      if (_firData!['notes'] != null &&
                          _firData!['notes'].toString().isNotEmpty)
                        _buildDetailRow('Notes', _firData!['notes'] ?? ''),
                    ],
                    const SizedBox(height: 32),
                    if (_firData != null &&
                        _firData!['investigations'] != null) ...[
                      const Text(
                        'Investigations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002B45),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List<Map<String, dynamic>>.from(
                            _firData!['investigations'],
                          )
                          .map(
                            (investigation) =>
                                _buildInvestigationCard(investigation),
                          )
                          .toList(),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/hc/add-investigation',
                            arguments: widget.firId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Add Investigation',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
