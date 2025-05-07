import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class SIMenu extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'Dashboard',
      'subtitle': 'Connect society member',
      'icon': Icons.grid_view,
      'iconColor': Colors.blue,
      'path': '/si/dashboard',
    },
    {
      'title': 'Complaints for Approval',
      'subtitle': 'See and approve or reject new complaints',
      'icon': Icons.balance,
      'iconColor': Colors.amber,
      'path': '/si/complaint-approval',
    },
    {
      'title': 'Assigned cases',
      'subtitle': '9 committee members.',
      'icon': Icons.folder,
      'iconColor': Colors.orange,
      'path': '/si/assigned-cases',
    },
    {
      'title': 'View HCs',
      'subtitle': 'View all head constables',
      'icon': Icons.search,
      'iconColor': Colors.lightBlue,
      'path': '/si/view-hcs',
    }
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
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
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 40, color: item['iconColor']),
                      const SizedBox(height: 10),
                      Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['subtitle'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
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
