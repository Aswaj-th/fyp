import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class SIDashboardFull extends StatelessWidget {
  final List<Map<String, dynamic>> stats = [
    {
      'title': 'Total Complaints',
      'subtitle': 'All complaints filed under SI jurisdiction',
      'count': '36',
      'icon': Icons.folder,
      'color': Colors.amber,
    },
    {
      'title': 'Pending Approval',
      'subtitle': 'Complaints waiting for SI review',
      'count': '08',
      'icon': Icons.search,
      'color': Colors.lightBlue,
    },
    {
      'title': 'Assigned Investigations',
      'subtitle': 'Active cases assigned to HCs',
      'count': '28',
      'icon': Icons.assignment,
      'color': Colors.green,
    },
    {
      'title': 'Transferred',
      'subtitle': 'Cases transferred to other stations',
      'count': '05',
      'icon': Icons.folder_shared,
      'color': Colors.orange,
    },
    {
      'title': 'Closed Cases',
      'subtitle': 'Marked complete/closed',
      'count': '05',
      'icon': Icons.close,
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> tableData = [
    {
      'id': '202401',
      'title': 'Theft at Mall',
      'date': '25/02/25',
      'status': 'green',
      'hc': 'HC Vidyut',
    },
    {
      'id': '202402',
      'title': 'Missing Person',
      'date': '25/02/25',
      'status': 'red',
      'hc': '---',
    },
    {
      'id': '202403',
      'title': 'Assault Case',
      'date': '25/02/25',
      'status': 'green',
      'hc': 'HC Om',
    },
    {
      'id': '202404',
      'title': 'Fraud Complaint',
      'date': '25/02/25',
      'status': 'yellow',
      'hc': 'HC Rakesh',
    },
    {
      'id': '202405',
      'title': 'Cybercrime Fraud',
      'date': '25/02/25',
      'status': 'green',
      'hc': 'HC Rom',
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
      body: ListView(
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(
              columnSpacing: 10,
              headingRowColor: MaterialStateProperty.all(Colors.blue[100]),
              columns: const [
                DataColumn(label: Text("Case ID")),
                DataColumn(label: Text("Title")),
                DataColumn(label: Text("Assigned Date")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Assigned HC")),
                DataColumn(label: Text("Action")),
              ],
              rows:
                  tableData.map((caseItem) {
                    return DataRow(
                      cells: [
                        DataCell(Text(caseItem['id'])),
                        DataCell(Text(caseItem['title'])),
                        DataCell(Text(caseItem['date'])),
                        DataCell(
                          Icon(
                            Icons.circle,
                            color: getStatusColor(caseItem['status']),
                            size: 14,
                          ),
                        ),
                        DataCell(Text(caseItem['hc'])),
                        DataCell(
                          Row(
                            children: const [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 6),
                              Icon(Icons.share, size: 16),
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
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}
