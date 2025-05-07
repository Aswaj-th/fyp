import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/config/env.dart';
import 'package:fyp/pages/si/si_case_details.dart';

class SIAssignedCasesScreen extends StatefulWidget {
  @override
  _SIAssignedCasesScreenState createState() => _SIAssignedCasesScreenState();
}

class _SIAssignedCasesScreenState extends State<SIAssignedCasesScreen> {
  final AppController _authController = Get.find<AppController>();
  List<Map<String, dynamic>> _cases = [];
  List<Map<String, dynamic>> _filteredCases = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            _filteredCases = _cases;
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

  void _filterCases(String query) {
    setState(() {
      _filteredCases = _cases.where((case_) {
        final title = case_['title']?.toString().toLowerCase() ?? '';
        final type = case_['complaintType']?.toString().toLowerCase() ?? '';
        final assignedTo = case_['assignedTo']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        
        return title.contains(searchLower) || 
               type.contains(searchLower) ||
               assignedTo.contains(searchLower);
      }).toList();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData statusIcon;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'PENDING':
        chipColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'REJECTED':
        chipColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 16),
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Assigned Cases",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search cases by title, type, or assigned officer...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCases('');
                            },
                          ),
                        ),
                        onChanged: _filterCases,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedFilter == 'All',
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedFilter = 'All';
                                  _filteredCases = _cases;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Approved'),
                              selected: _selectedFilter == 'Approved',
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedFilter = 'Approved';
                                  _filteredCases = _cases
                                      .where((case_) =>
                                          case_['status']?.toString().toUpperCase() ==
                                          'APPROVED')
                                      .toList();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Pending'),
                              selected: _selectedFilter == 'Pending',
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedFilter = 'Pending';
                                  _filteredCases = _cases
                                      .where((case_) =>
                                          case_['status']?.toString().toUpperCase() ==
                                          'PENDING')
                                      .toList();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_filteredCases.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No cases found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Title",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Type",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Assigned To",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Assigned Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Approved Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Investigations",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Action",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _filteredCases.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(Text(item['complaintType'] ?? '')),
                              DataCell(Text(item['assignedTo'] ?? '')),
                              DataCell(_buildStatusChip(item['status'] ?? '')),
                              DataCell(
                                Text(_formatDate(item['assignedDate'] ?? '')),
                              ),
                              DataCell(
                                Text(_formatDate(item['approvedDate'] ?? '')),
                              ),
                              DataCell(
                                Text(
                                  '${item['investigations']?.length ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SICaseDetailsScreen(
                                          caseData: item,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: 'View Details',
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
      ),
    );
  }
}
