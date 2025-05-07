import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fyp/config/env.dart';
import 'package:fyp/get.dart';

class AdminCasesPage extends StatefulWidget {
  const AdminCasesPage({Key? key}) : super(key: key);

  @override
  _AdminCasesPageState createState() => _AdminCasesPageState();
}

class _AdminCasesPageState extends State<AdminCasesPage> {
  final AppController authController = Get.find<AppController>();
  List<Map<String, dynamic>> cases = [];
  List<Map<String, dynamic>> filteredCases = [];
  bool isLoading = true;
  String? errorMessage;

  // Filter states
  String? selectedStation;
  String? selectedStatus;
  String? selectedOfficer;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController searchController = TextEditingController();

  // Filter options
  final List<String> statusOptions = [
    'PENDING',
    'APPROVED',
    'REJECTED',
    'CLOSED',
  ];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> officers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch all cases
      final response = await http
          .get(
            Uri.parse('${Env.apiUrl}/fir/superadmin/all-firs'),
            headers: {
              'Authorization': 'Bearer ${authController.jwt.value}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['data'] != null) {
          print(data['data'][0]['assignedOfficer']);
          setState(() {
            cases = List<Map<String, dynamic>>.from(data['data']);
            filteredCases = cases;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Invalid response format from server';
            isLoading = false;
          });
          _showMessage('Invalid response format from server', isError: true);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load cases';
        setState(() {
          this.errorMessage = errorMessage;
          isLoading = false;
        });
        _showMessage(errorMessage, isError: true);
      }

      // Fetch stations
      final stationsResponse = await http
          .get(
            Uri.parse('${Env.apiUrl}/police-stations'),
            headers: {
              'Authorization': 'Bearer ${authController.jwt.value}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (stationsResponse.statusCode == 200) {
        final stationsData = jsonDecode(stationsResponse.body);
        // print(stationsData);
        if (stationsData != null && stationsData['data'] != null) {
          setState(() {
            stations = List<Map<String, dynamic>>.from(stationsData['data']);
          });
        }
      }

      // Fetch officers
      final officersResponse = await http
          .get(
            Uri.parse('${Env.apiUrl}/users/officers'),
            headers: {
              'Authorization': 'Bearer ${authController.jwt.value}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (officersResponse.statusCode == 200) {
        final officersData = jsonDecode(officersResponse.body);
        if (officersData != null && officersData['data'] != null) {
          setState(() {
            officers = List<Map<String, dynamic>>.from(officersData['data']);
          });
        }
      }
    } on TimeoutException {
      setState(() {
        errorMessage =
            'Connection timed out. Please check your internet connection and try again.';
        isLoading = false;
      });
      _showMessage('Connection timed out. Please try again.', isError: true);
    } catch (e) {
      print('Exception occurred: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
      _showMessage('Failed to load cases: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredCases =
          cases.where((caseData) {
            // Search text filter
            if (searchController.text.isNotEmpty) {
              final searchTerm = searchController.text.toLowerCase();
              final title = (caseData['title'] ?? '').toString().toLowerCase();
              final description =
                  (caseData['description'] ?? '').toString().toLowerCase();
              final caseId = (caseData['id'] ?? '').toString().toLowerCase();
              final complainantName =
                  (caseData['complainantName'] ?? '').toString().toLowerCase();

              if (!title.contains(searchTerm) &&
                  !description.contains(searchTerm) &&
                  !caseId.contains(searchTerm) &&
                  !complainantName.contains(searchTerm)) {
                return false;
              }
            }

            // Status filter
            if (selectedStatus != null &&
                caseData['status'] != selectedStatus) {
              return false;
            }

            // Station filter
            if (selectedStation != null &&
                caseData['stationId'] != selectedStation) {
              return false;
            }

            // Officer filter
            if (selectedOfficer != null &&
                caseData['assignedOfficerId'] != selectedOfficer) {
              return false;
            }

            // Date range filter
            if (startDate != null || endDate != null) {
              final caseDate = DateTime.parse(caseData['createdAt']);
              if (startDate != null && caseDate.isBefore(startDate!)) {
                return false;
              }
              if (endDate != null &&
                  caseDate.isAfter(endDate!.add(const Duration(days: 1)))) {
                return false;
              }
            }

            return true;
          }).toList();

      // Sort by date (newest first)
      filteredCases.sort(
        (a, b) => DateTime.parse(
          b['createdAt'],
        ).compareTo(DateTime.parse(a['createdAt'])),
      );
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Cases'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Station filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Police Station',
                    ),
                    value: selectedStation,
                    items:
                        stations.map((station) {
                          return DropdownMenuItem<String>(
                            value: station['id'],
                            child: Text(station['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => selectedStation = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: selectedStatus,
                    items:
                        statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Officer filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Assigned Officer',
                    ),
                    value: selectedOfficer,
                    items:
                        officers.map((officer) {
                          return DropdownMenuItem<String>(
                            value: officer['id'],
                            child: Text(officer['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => selectedOfficer = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date range picker
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => startDate = date);
                            }
                          },
                          child: Text(
                            startDate == null
                                ? 'Start Date'
                                : DateFormat('dd/MM/yyyy').format(startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => endDate = date);
                            }
                          },
                          child: Text(
                            endDate == null
                                ? 'End Date'
                                : DateFormat('dd/MM/yyyy').format(endDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedStation = null;
                    selectedStatus = null;
                    selectedOfficer = null;
                    startDate = null;
                    endDate = null;
                  });
                  _applyFilters();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  void _showCaseDetails(Map<String, dynamic> caseData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(caseData['title'] ?? 'Case Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Case ID', caseData['id'] ?? 'N/A'),
                  _buildDetailRow('Status', caseData['status'] ?? 'N/A'),
                  _buildDetailRow('Type', caseData['complaintType'] ?? 'N/A'),
                  _buildDetailRow(
                    'Station',
                    caseData['station']?['name'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Assigned Officer',
                    caseData['assignedOfficerName'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Created Date',
                    caseData['createdAt'] != null
                        ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.parse(caseData['createdAt']))
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(caseData['description'] ?? 'No description available'),
                  if (caseData['investigationReport'] != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Investigation Report:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(caseData['investigationReport']),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and filter bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search cases...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cases table
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : filteredCases.isEmpty
                      ? const Center(
                        child: Text(
                          'No cases found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Case ID')),
                              DataColumn(label: Text('Title')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Station')),
                              DataColumn(label: Text('Assigned Officer')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Created Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows:
                                filteredCases.map((caseData) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          caseData['id'] != null
                                              ? caseData['id']
                                                  .toString()
                                                  .substring(
                                                    caseData['id']
                                                            .toString()
                                                            .length -
                                                        4,
                                                  )
                                              : 'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Text(caseData['title'] ?? 'N/A'),
                                      ),
                                      DataCell(
                                        Text(
                                          caseData['complaintType'] ?? 'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          caseData['station']?['name'] ?? 'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          caseData['assignedOfficerName'] ??
                                              'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              caseData['status'] ?? '',
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            caseData['status'] ?? 'N/A',
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                caseData['status'] ?? '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          caseData['createdAt'] != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(
                                                  caseData['createdAt'],
                                                ),
                                              )
                                              : 'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility,
                                              ),
                                              onPressed:
                                                  () => _showCaseDetails(
                                                    caseData,
                                                  ),
                                              tooltip: 'View Details',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.download),
                                              onPressed: () {
                                                // Implement download functionality
                                              },
                                              tooltip: 'Download Report',
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
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}
