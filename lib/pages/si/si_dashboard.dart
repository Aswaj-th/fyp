import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/config/env.dart';

class SIDashboardFull extends StatefulWidget {
  @override
  _SIDashboardFullState createState() => _SIDashboardFullState();
}

class _SIDashboardFullState extends State<SIDashboardFull> {
  final AppController _authController = Get.find<AppController>();
  bool _isLoading = true;
  String? _error;

  // Stats data
  int _totalComplaints = 0;
  int _pendingApprovals = 0;
  int _assignedInvestigations = 0;
  int _closedCases = 0;

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
      // Fetch all cases for total count
      final allResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      // Fetch pending cases
      final pendingResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station?status=PENDING'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      // Fetch assigned cases
      final assignedResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station?status=APPROVED'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      // Fetch closed cases
      final closedResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/si-station?status=COMPLETED'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      if (allResponse.statusCode == 200 &&
          pendingResponse.statusCode == 200 &&
          assignedResponse.statusCode == 200 &&
          closedResponse.statusCode == 200) {
        final allData = json.decode(allResponse.body);
        final pendingData = json.decode(pendingResponse.body);
        final assignedData = json.decode(assignedResponse.body);
        final closedData = json.decode(closedResponse.body);

        if (allData['success'] == true &&
            pendingData['success'] == true &&
            assignedData['success'] == true &&
            closedData['success'] == true) {
          setState(() {
            _totalComplaints = (allData['data'] as List).length;
            _pendingApprovals = (pendingData['data'] as List).length;
            _assignedInvestigations = (assignedData['data'] as List).length;
            _closedCases = (closedData['data'] as List).length;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to fetch data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error';
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

  List<Map<String, dynamic>> get stats => [
    {
      'title': 'Total Complaints',
      'subtitle': 'All complaints filed under SI jurisdiction',
      'count': _totalComplaints.toString(),
      'icon': Icons.folder,
      'color': Colors.amber,
    },
    {
      'title': 'Pending Approval',
      'subtitle': 'Complaints waiting for SI review',
      'count': _pendingApprovals.toString(),
      'icon': Icons.search,
      'color': Colors.lightBlue,
    },
    {
      'title': 'Assigned Investigations',
      'subtitle': 'Active cases assigned to HCs',
      'count': _assignedInvestigations.toString(),
      'icon': Icons.assignment,
      'color': Colors.green,
    },
    {
      'title': 'Closed Cases',
      'subtitle': 'Marked complete/closed',
      'count': _closedCases.toString(),
      'icon': Icons.close,
      'color': Colors.red,
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
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
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(12.0),
                children: [
                  const Text(
                    '📊 Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        stats.map((item) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 3),
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['count'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(item['icon'], color: item['color']),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }
}
