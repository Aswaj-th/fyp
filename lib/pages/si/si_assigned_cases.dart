import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/config/env.dart';

class SIAssignedCasesScreen extends StatefulWidget {
  @override
  _SIAssignedCasesScreenState createState() => _SIAssignedCasesScreenState();
}

class _SIAssignedCasesScreenState extends State<SIAssignedCasesScreen> {
  final AppController _authController = Get.find<AppController>();
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station?status=APPROVED'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _cases = List<Map<String, dynamic>>.from(data['data']);
            print(_cases);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to fetch cases';
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showCaseDetails(Map<String, dynamic> caseData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Case Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildDetailRow('Title', caseData['title'] ?? ''),
                  _buildDetailRow('Description', caseData['description'] ?? ''),
                  _buildDetailRow(
                    'Incident Date',
                    _formatDate(caseData['incidentDate'] ?? ''),
                  ),
                  _buildDetailRow(
                    'Incident Address',
                    caseData['incidentAddress'] ?? '',
                  ),
                  _buildDetailRow(
                    'Complaint Type',
                    caseData['complaintType'] ?? '',
                  ),
                  _buildDetailRow('Category', caseData['category'] ?? ''),
                  const Divider(),
                  const Text(
                    'Complainant Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Name', caseData['complainantName'] ?? ''),
                  _buildDetailRow(
                    'Gender',
                    caseData['complainantGender'] ?? '',
                  ),
                  _buildDetailRow(
                    'Mobile',
                    caseData['complainantMobile'] ?? '',
                  ),
                  _buildDetailRow('Email', caseData['complainantEmail'] ?? ''),
                  _buildDetailRow(
                    'Address',
                    caseData['complainantAddress'] ?? '',
                  ),
                  const Divider(),
                  const Text(
                    'Case Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Status', caseData['status'] ?? ''),
                  _buildDetailRow(
                    'Created At',
                    _formatDate(caseData['createdAt'] ?? ''),
                  ),
                  if (caseData['approvedDate'] != null)
                    _buildDetailRow(
                      'Approved At',
                      _formatDate(caseData['approvedDate'] ?? ''),
                    ),
                  if (caseData['closedDate'] != null)
                    _buildDetailRow(
                      'Closed At',
                      _formatDate(caseData['closedDate'] ?? ''),
                    ),
                  if (caseData['notes'] != null &&
                      caseData['notes'].toString().isNotEmpty)
                    _buildDetailRow('Notes', caseData['notes'] ?? ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assigned Cases",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_cases.isEmpty)
              const Center(child: Text('No assigned cases found'))
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.blue[100],
                      ),
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(label: Text("Title")),
                        DataColumn(label: Text("Type")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Assigned Date")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows:
                          _cases.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['title'] ?? '')),
                                DataCell(Text(item['complaintType'] ?? '')),
                                DataCell(
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ),
                                DataCell(
                                  Text(_formatDate(item['assignedDate'] ?? '')),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showCaseDetails(item),
                                        icon: const Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "View",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // TODO: Implement approve action
                                        },
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Approve",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // TODO: Implement reject action
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Reject",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }
}
