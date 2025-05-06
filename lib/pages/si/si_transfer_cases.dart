import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class TransferCasesPage extends StatelessWidget {
  final List<Map<String, String>> cases = [
    {"hc": "Vidyut", "type": "Theft", "date": "25/02/25"},
    {"hc": "Yogesh", "type": "Missing", "date": "25/02/25"},
    {"hc": "Om", "type": "Assault", "date": "25/02/25"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text(
                  "Transfer Cases",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.tune, color: Colors.green),
              ],
            ),
            SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue.shade100),
                  children: [
                    tableCell("Assigned HC's", isHeader: true),
                    tableCell("Type", isHeader: true),
                    tableCell("Status", isHeader: true),
                    tableCell("Date Filed", isHeader: true),
                    tableCell("Action", isHeader: true),
                  ],
                ),
                ...cases.map((c) {
                  return TableRow(
                    children: [
                      tableCell("HC ${c['hc']}"),
                      tableCell(c['type']!),
                      Center(
                        child: Icon(
                          Icons.radio_button_checked,
                          color: Colors.amber,
                        ),
                      ),
                      tableCell(c['date']!),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.cached, size: 16),
                          label: Text("Transfer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            textStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: isHeader ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(),
        textAlign: TextAlign.center,
      ),
    );
  }
}
