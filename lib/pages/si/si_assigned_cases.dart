import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class SIAssignedCasesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cases = [
    {'type': 'Theft', 'assignable': true},
    {'type': 'Missing', 'assignable': true},
    {'type': 'Assault', 'assignable': true},
    {'type': 'Fraud', 'assignable': false},
    ...List.generate(6, (_) => {'type': 'Cyber crime', 'assignable': false}),
  ];

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
              "← Assigned Cases",
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
                    cases.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['type'])),
                          const DataCell(
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                          const DataCell(Text("25/02/25")),
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
                                if (item['assignable']) ...[
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Assign HC",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ] else ...[
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
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }
}
