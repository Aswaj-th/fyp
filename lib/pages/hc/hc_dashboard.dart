import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:fyp/get.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class HCDashboardPage extends StatelessWidget {
  final List<Map<String, String>> cases = [
    {
      'id': '234541',
      'title': 'Theft in Hotel',
      'status': 'Ongoing',
      'date': '20/04/24',
    },
    {
      'id': '233487',
      'title': 'Missing Person',
      'status': 'Pending',
      'date': '21/04/24',
    },
    {
      'id': '232244',
      'title': 'Assault Case',
      'status': 'Closed',
      'date': '18/04/24',
    },
    {
      'id': '230111',
      'title': 'Fraud Complaint',
      'status': 'Ongoing',
      'date': '17/04/24',
    },
    {
      'id': '229324',
      'title': 'Cybercrime Fraud',
      'status': 'Pending',
      'date': '15/04/24',
    },
  ];

  Widget buildCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(icon, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Top Summary Cards
              Row(
                children: [
                  buildCard(
                    'Total Assigned\nCases',
                    '36',
                    Icons.folder,
                    Colors.orange,
                  ),
                  SizedBox(width: 8),
                  buildCard(
                    'Pending\nInvestigations',
                    '08',
                    Icons.search,
                    Colors.blue,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  buildCard(
                    'Completed\nCases',
                    '28',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  SizedBox(width: 8),
                  buildCard('SOS Alert\nSent', '05', Icons.warning, Colors.red),
                ],
              ),
              SizedBox(height: 20),
              // Data Table Header
              Container(
                width: double.infinity,
                color: Colors.grey.shade300,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text('Case ID')),
                    Expanded(flex: 3, child: Text('Title')),
                    Expanded(flex: 2, child: Text('Status')),
                    Expanded(flex: 2, child: Text('Assigned')),
                    Expanded(child: Text('Action')),
                  ],
                ),
              ),
              // Data Table Rows
              ...cases.map(
                (caseItem) => Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(caseItem['id']!)),
                      Expanded(flex: 3, child: Text(caseItem['title']!)),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(
                              caseItem['status'] == 'Closed'
                                  ? Icons.check
                                  : caseItem['status'] == 'Pending'
                                  ? Icons.timelapse
                                  : Icons.loop,
                              color:
                                  caseItem['status'] == 'Closed'
                                      ? Colors.green
                                      : caseItem['status'] == 'Pending'
                                      ? Colors.orange
                                      : Colors.blue,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(caseItem['status']!),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(caseItem['date']!)),
                      Expanded(child: Icon(Icons.remove_red_eye, size: 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }
}
