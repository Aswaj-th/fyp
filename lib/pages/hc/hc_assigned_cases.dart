import 'package:flutter/material.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HCAssignedCasesPage extends StatefulWidget {
  const HCAssignedCasesPage({Key? key}) : super(key: key);

  @override
  _HCAssignedCasesPageState createState() => _HCAssignedCasesPageState();
}

class _HCAssignedCasesPageState extends State<HCAssignedCasesPage> {
  List<Map<String, dynamic>> cases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedCases();
  }

  Future<void> fetchAssignedCases() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.9.48:8080/api/fir/assigned-to-me'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cases = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cases');
      }
    } catch (e) {
      print('Error fetching cases: $e');
      setState(() {
        isLoading = false;
      });
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
                        Expanded(
                          child: Text(
                            "Case ID",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Title",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Assigned Date",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
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
                              Expanded(child: Text(caseItem["id"] ?? '')),
                              Expanded(child: Text(caseItem["title"] ?? '')),
                              Expanded(child: Text(caseItem["date"] ?? '')),
                              Expanded(
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
