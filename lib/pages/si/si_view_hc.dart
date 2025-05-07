import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/config/env.dart';
import 'package:intl/intl.dart';

class SIViewHCScreen extends StatefulWidget {
  @override
  _SIViewHCScreenState createState() => _SIViewHCScreenState();
}

class _SIViewHCScreenState extends State<SIViewHCScreen> {
  final AppController _authController = Get.find<AppController>();
  List<Map<String, dynamic>> _headConstables = [];
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
        Uri.parse('${Env.apiUrl}/police-stations/head-constables'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _headConstables = List<Map<String, dynamic>>.from(
              data['data']['headConstables'],
            );
            print(_headConstables);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to fetch head constables';
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
              "Head Constables",
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
            else if (_headConstables.isEmpty)
              const Center(child: Text('No head constables found'))
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
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Badge Number")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Joined Date")),
                      ],
                      rows:
                          _headConstables.map((hc) {
                            return DataRow(
                              cells: [
                                DataCell(Text(hc['name'] ?? '')),
                                DataCell(Text(hc['badgeNumber'] ?? '')),
                                DataCell(Text(hc['phoneNumber'] ?? '')),
                                DataCell(
                                  Text(
                                    hc['joinedDate'] != null
                                        ? DateFormat('yyyy-MM-dd').format(
                                          DateTime.parse(hc['joinedDate']),
                                        )
                                        : '',
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
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
    );
  }
}
