import 'package:flutter/material.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/components/custom_app_bar.dart';

class AdminDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'Add Stations',
      'subtitle': 'Add new police stations',
      'icon': Icons.local_police,
      'path': '/admin/addstation',
    },
    {
      'title': 'View Stations',
      'subtitle': 'Manage police stations',
      'icon': Icons.list_alt,
      'path': '/admin/stations',
    },
    {
      'title': 'Add Officers',
      'subtitle': 'Add new police officers',
      'icon': Icons.person_add,
      'path': '/admin/addofficer',
    },
    {
      'title': 'View Officers',
      'subtitle': 'Manage police officers',
      'icon': Icons.people,
      'path': '/admin/officers',
    },
    {
      'title': 'All Cases',
      'subtitle': 'Track financial & dues',
      'icon': Icons.receipt_long,
      'path': '',
    },
    {
      'title': 'Reports',
      'subtitle': 'Monitor entry and exit',
      'icon': Icons.bar_chart,
      'path': '',
    },
    {
      'title': 'System Logs',
      'subtitle': 'Communicate with housekeeping',
      'icon': Icons.note,
      'path': '',
    },
    {
      'title': 'Setting',
      'subtitle': 'Report issues',
      'icon': Icons.settings,
      'path': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: gridItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            final String path = item['path'] ?? '';
            return InkWell(
              onTap: () {
                if (path.isNotEmpty) {
                  Navigator.pushNamed(context, path);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This feature is coming soon!'),
                    ),
                  );
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 40, color: Colors.black87),
                      SizedBox(height: 10),
                      Text(
                        item['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        item['subtitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}
