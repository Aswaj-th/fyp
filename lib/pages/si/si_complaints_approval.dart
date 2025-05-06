import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class SIComplaintApprovals extends StatelessWidget {
  final List<Map<String, String>> approvals = List.generate(10, (index) {
    return {
      'type':
          index < 4
              ? ['Theft', 'Missing', 'Assault', 'Fraud'][index]
              : 'Cyber crime',
      'date': '25/02/25',
    };
  });

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
              "← Complaint Approvals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue[100]),
                columnSpacing: 10,
                columns: const [
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Assigned Date")),
                  DataColumn(label: Text("Action")),
                ],
                rows:
                    approvals.map((complaint) {
                      return DataRow(
                        cells: [
                          DataCell(Text(complaint['type']!)),
                          DataCell(
                            const Icon(
                              Icons.circle,
                              color: Colors.orange,
                              size: 14,
                            ),
                          ),
                          DataCell(Text(complaint['date']!)),
                          DataCell(
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "View",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Approve",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Reject",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }
}
