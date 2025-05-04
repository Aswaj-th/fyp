import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/get.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class HCAssignedCasesPage extends StatelessWidget {
  final List<Map<String, dynamic>> cases = [
    {
      "id": "202401",
      "title": "Theft at Mall",
      "status": "green",
      "date": "25/02/25",
    },
    {
      "id": "202402",
      "title": "Missing Person",
      "status": "red",
      "date": "25/02/25",
    },
    {
      "id": "202403",
      "title": "Assault Case",
      "status": "green",
      "date": "25/02/25",
    },
    {
      "id": "202404",
      "title": "Fraud Complaint",
      "status": "yellow",
      "date": "25/02/25",
    },
    {
      "id": "202405",
      "title": "Cybercrime Fraud",
      "status": "green",
      "date": "25/02/25",
    },
    {
      "id": "202406",
      "title": "Vehicle Theft",
      "status": "green",
      "date": "25/02/25",
    },
    {
      "id": "202407",
      "title": "Harassment Case",
      "status": "yellow",
      "date": "25/02/25",
    },
    {
      "id": "202408",
      "title": "ATM Fraud",
      "status": "green",
      "date": "25/02/25",
    },
    {
      "id": "202409",
      "title": "Domestic Violence",
      "status": "red",
      "date": "25/02/25",
    },
    {
      "id": "202410",
      "title": "Kidnapping Attempt",
      "status": "green",
      "date": "25/02/25",
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "green":
        return Colors.green;
      case "yellow":
        return Colors.amber;
      case "red":
        return Colors.red;
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
      body: Column(
        children: [
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                    "Status",
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
                      Expanded(child: Text(caseItem["id"])),
                      Expanded(child: Text(caseItem["title"])),
                      Expanded(
                        child: Icon(
                          Icons.circle,
                          color: getStatusColor(caseItem["status"]),
                          size: 16,
                        ),
                      ),
                      Expanded(child: Text(caseItem["date"])),
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Icon(Icons.upload_file, size: 18),
                          ],
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
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 2,
      ),
    );
  }
}
