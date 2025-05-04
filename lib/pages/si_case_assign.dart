import 'package:flutter/material.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
          decoration: const BoxDecoration(color: Color(0xFF002B45)),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "HEAD CONSTABLE",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        "Dev Ambale",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "5",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                headingRowColor: MaterialStateProperty.all(Colors.blue[100]),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'File Complaint',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Assigned Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Investigation Updates',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS Alert'),
        ],
      ),
    );
  }
}
