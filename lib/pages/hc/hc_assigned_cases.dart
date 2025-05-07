import 'package:flutter/material.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:fyp/config/env.dart';
import 'package:intl/intl.dart';

class HCAssignedCasesPage extends StatefulWidget {
  const HCAssignedCasesPage({Key? key}) : super(key: key);

  @override
  _HCAssignedCasesPageState createState() => _HCAssignedCasesPageState();
}

class _HCAssignedCasesPageState extends State<HCAssignedCasesPage> {
  final AppController _authController = Get.find<AppController>();
  List<Map<String, dynamic>> cases = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAssignedCases();
  }

  Future<void> fetchAssignedCases() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/fir/assigned-to-me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            cases = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load cases';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cases: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _formatId(String id) {
    if (id.length > 6) {
      return id.substring(0, 6);
    }
    return id;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
      case 'VERIFICATION':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B45),
        title: const Text("Assigned Cases"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              const Icon(Icons.notifications, size: 28),
              Positioned(
                right: 0,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "5",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: fetchAssignedCases,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Container(
                    color: Colors.blue[50],
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 2, child: Text("Case ID")),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Title",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Type",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Assigned Date",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Action",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cases.length,
                      itemBuilder: (context, index) {
                        final caseItem = cases[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(_formatId(caseItem["id"] ?? '')),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(caseItem["title"] ?? ''),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(caseItem["complaintType"] ?? ''),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        caseItem["status"] ?? '',
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  caseItem["approvedDate"] != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(
                                          caseItem['approvedDate'],
                                        ),
                                      )
                                      : '',
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/hc/edit-investigation-first',
                                      arguments: caseItem["id"],
                                    );
                                  },
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 8),
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}
