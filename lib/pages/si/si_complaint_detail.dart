import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/config/env.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SIComplaintDetail extends StatefulWidget {
  final dynamic complaint;

  const SIComplaintDetail({Key? key, required this.complaint})
    : super(key: key);

  @override
  _SIComplaintDetailState createState() => _SIComplaintDetailState();
}

class _SIComplaintDetailState extends State<SIComplaintDetail> {
  final authController = Get.find<AppController>();
  bool isLoading = false;
  String? errorMessage;
  List<dynamic> similarCases = [];
  bool isFetchingSimilarCases = true;
  List<dynamic> headConstables = [];
  bool isFetchingHeadConstables = false;

  @override
  void initState() {
    super.initState();
    fetchSimilarCases();
  }

  Future<void> fetchSimilarCases() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Env.apiUrl}/fir/si-station?complaintType=${widget.complaint['complaintType']}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Filter out the current complaint and limit to 5 similar cases
          final allCases = data['data'] as List;
          final filtered =
              allCases
                  .where((c) => c['id'] != widget.complaint['id'])
                  .take(5)
                  .toList();

          setState(() {
            similarCases = filtered;
            isFetchingSimilarCases = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch similar cases';
            isFetchingSimilarCases = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isFetchingSimilarCases = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isFetchingSimilarCases = false;
      });
    }
  }

  Future<void> approveComplaint() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/police-stations/head-constables'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final hcs = data['data']['headConstables'] as List;

          if (hcs.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No Head Constables available in your station'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (!mounted) return;

          // Show enhanced list dialog
          final selectedHC = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Head Constable to Assign this case'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: hcs.length,
                  itemBuilder: (context, index) {
                    final hc = hcs[index];
                    final assignedCases = hc['assignedCases'] ?? 0;
                    final solvedCases = hc['solvedCases'] ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(hc['name']?.substring(0, 1) ?? 'HC'),
                        ),
                        title: Text(hc['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Badge: ${hc['badgeNumber'] ?? 'N/A'}'),
                            Text('Assigned Cases: $assignedCases'),
                            Text('Solved Cases: $solvedCases'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.pop(context, hc),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );

          if (selectedHC != null && mounted) {
            // Make the approval API call
            final approveResponse = await http.patch(
              Uri.parse(
                '${Env.apiUrl}/fir/${widget.complaint['id']}/approve/hc/${selectedHC['id']}',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${authController.jwt.value}',
              },
            );

            if (approveResponse.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Case approved and assigned successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to approve case'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchHeadConstables() async {
    if (isFetchingHeadConstables) return;

    setState(() {
      isFetchingHeadConstables = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/police-stations/head-constables'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            headConstables =
                data['data']['headConstables'].map((hc) {
                  return hc;
                }).toList();
            isFetchingHeadConstables = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch head constables';
            isFetchingHeadConstables = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isFetchingHeadConstables = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isFetchingHeadConstables = false;
      });
    }
  }

  Future<void> rejectComplaint() async {
    // Show dialog to get rejection reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _buildRejectDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      await _updateComplaintStatus('reject', reason: reason);
    }
  }

  Future<void> _updateComplaintStatus(
    String action, {
    String? reason,
    String? assignedOfficerId,
  }) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String endpoint;
      Map<String, dynamic> body = {};

      if (action == 'approve' && assignedOfficerId != null) {
        endpoint =
            '${Env.apiUrl}/fir/${widget.complaint['id']}/approve/hc/$assignedOfficerId';
      } else if (action == 'reject') {
        endpoint = '${Env.apiUrl}/fir/${widget.complaint['id']}/reject';
        body['reason'] = reason;
      } else {
        throw Exception('Invalid action or missing required parameters');
      }

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Show success message and pop back to the list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Complaint ${action == 'approve' ? 'approved and assigned' : 'rejected'} successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to ${action} complaint';
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
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildRejectDialog() {
    final TextEditingController reasonController = TextEditingController();

    return AlertDialog(
      title: const Text('Reject Complaint'),
      content: TextField(
        controller: reasonController,
        decoration: const InputDecoration(
          hintText: 'Enter reason for rejection',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, reasonController.text),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Complaint Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Complaint details card
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Complaint ID',
                              complaint['id'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Title',
                              complaint['title'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Type',
                              complaint['complaintType'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Category',
                              complaint['category'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Status',
                              complaint['status'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Created Date',
                              formatDate(complaint['createdAt']),
                            ),
                            _buildDetailRow(
                              'Incident Date',
                              formatDate(complaint['incidentDate']),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Complainant details card
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complainant Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Name',
                              complaint['complainantName'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Gender',
                              complaint['complainantGender'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Mobile',
                              complaint['complainantMobile'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Email',
                              complaint['complainantEmail'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Address',
                              complaint['complainantAddress'] ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Incident details card
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Incident Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Location',
                              complaint['incidentAddress'] ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaint['description'] ??
                                  'No description provided',
                            ),
                            if (complaint['notes'] != null &&
                                complaint['notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Notes:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(complaint['notes']),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Station and creator details
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Station & Creator Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Station',
                              complaint['station']?['name'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Created By',
                              complaint['createdBy']?['name'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Creator Role',
                              complaint['createdBy']?['role'] ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Similar cases section
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Similar Cases',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isFetchingSimilarCases)
                              const Center(child: CircularProgressIndicator())
                            else if (similarCases.isEmpty)
                              const Text('No similar cases found')
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: similarCases.length,
                                itemBuilder: (context, index) {
                                  final similarCase = similarCases[index];
                                  return ListTile(
                                    title: Text(similarCase['title'] ?? 'N/A'),
                                    subtitle: Text(
                                      '${similarCase['complaintType']} - ${formatDate(similarCase['createdAt'])}',
                                    ),
                                    trailing: Text(
                                      similarCase['status'] ?? 'N/A',
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          similarCase['status'],
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Action buttons
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: approveComplaint,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Approve Case'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: rejectComplaint,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('Reject Case'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CLOSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
