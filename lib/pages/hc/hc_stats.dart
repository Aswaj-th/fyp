import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/config/env.dart';

class HCStatsPage extends StatefulWidget {
  const HCStatsPage({Key? key}) : super(key: key);

  @override
  _HCStatsPageState createState() => _HCStatsPageState();
}

class _HCStatsPageState extends State<HCStatsPage> {
  final AppController _authController = Get.find<AppController>();
  bool _isLoading = true;
  String? _error;

  int _createdCases = 0;
  int _assignedCases = 0;

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
      // Fetch created cases
      final createdResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/created-by-me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      // Fetch assigned cases
      final assignedResponse = await http.get(
        Uri.parse('${Env.apiUrl}/fir/assigned-to-me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      if (createdResponse.statusCode == 200 &&
          assignedResponse.statusCode == 200) {
        final createdData = json.decode(createdResponse.body);
        final assignedData = json.decode(assignedResponse.body);

        if (createdData['success'] == true && assignedData['success'] == true) {
          setState(() {
            _createdCases = (createdData['data'] as List).length;
            _assignedCases = (assignedData['data'] as List).length;
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
      'title': 'Created Cases',
      'subtitle': 'Total cases created by you',
      'count': _createdCases.toString(),
      'icon': Icons.add_circle,
      'color': Colors.blue,
    },
    {
      'title': 'Assigned Cases',
      'subtitle': 'Cases assigned to you',
      'count': _assignedCases.toString(),
      'icon': Icons.assignment,
      'color': Colors.green,
    },
  ];

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
                    '📊 Statistics',
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
