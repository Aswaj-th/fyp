import 'package:flutter/material.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/components/custom_navigation_bar.dart';

class HCHomepage extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'File Complaints',
      'subtitle': '',
      'icon': Icons.receipt,
      'path': '/hc/create-fir',
    },
    {
      'title': 'My Filed Complaints',
      'subtitle': '',
      'icon': Icons.receipt,
      'path': '/hc/my-fir',
    },
    {
      'title': 'Assigned cases',
      'subtitle': 'Committee members.',
      'icon': Icons.assignment_turned_in,
      'path': '/hc/assigned',
    },
    {
      'title': 'Investigation Updates',
      'subtitle': 'Ensures safety by monitoring society',
      'icon': Icons.visibility,
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

            // Check if the 'path' exists and is not empty before navigation
            return GestureDetector(
              onTap: () {
                // If path is not empty, navigate to the desired screen
                if (item['path'] != null && item['path'].isNotEmpty) {
                  Navigator.pushNamed(context, item['path']);
                } else {
                  // If no path, show a snackbar or some other action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No screen available for ${item['title']}'),
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
