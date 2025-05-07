import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/config/env.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fyp/pages/si/si_complaint_detail.dart';

class SIComplaintApprovals extends StatefulWidget {
  @override
  _SIComplaintApprovalsState createState() => _SIComplaintApprovalsState();
}

class _SIComplaintApprovalsState extends State<SIComplaintApprovals> {
  final authController = Get.find<AppController>();
  bool isLoading = true;
  List<dynamic> pendingComplaints = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPendingComplaints();
  }

  Future<void> fetchPendingComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station?status=PENDING'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            pendingComplaints = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage =
                data['message'] ?? 'Failed to fetch pending complaints';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void navigateToDetailPage(dynamic complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SIComplaintDetail(complaint: complaint),
      ),
    ).then((_) {
      // Refresh the list when returning from detail page
      fetchPendingComplaints();
    });
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
             Row(
                      children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "Pending Complaint Approvals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (pendingComplaints.isEmpty)
              const Center(
                child: Text(
                  'No pending complaints found',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.blue[100],
                        ),
                        columnSpacing: 8,
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 80,
                        columns: const [
                          DataColumn(
                            label: SizedBox(width: 120, child: Text("Title")),
                          ),
                          DataColumn(
                            label: SizedBox(width: 80, child: Text("Type")),
                          ),
                          DataColumn(
                            label: SizedBox(width: 50, child: Text("Status")),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 90,
                              child: Text("Created Date"),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(width: 80, child: Text("Action")),
                          ),
                        ],
                        rows:
                            pendingComplaints.map((complaint) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 120,
                                      child: Text(
                                        complaint['title'] ?? 'N/A',
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(complaint['complaintType'] ?? 'N/A'),
                                  ),
                                  DataCell(
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.orange,
                                      size: 14,
                                    ),
                                  ),
                                  DataCell(
                                    Text(formatDate(complaint['createdAt'])),
                                  ),
                                  DataCell(
                                    TextButton.icon(
                                      onPressed:
                                          () => navigateToDetailPage(complaint),
                                      icon: const Icon(
                                        Icons.remove_red_eye,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        "View Details",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomNavigationBar(currentIndex: ),
    );
  }
}
