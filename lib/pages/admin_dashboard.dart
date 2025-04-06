import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'Dashboard',
      'subtitle': 'Connect society member',
      'icon': Icons.dashboard,
    },
    {
      'title': 'Manage Stations',
      'subtitle': 'Committee members',
      'icon': Icons.local_police,
    },
    {
      'title': 'Manage Officers',
      'subtitle': 'Know staff and duties',
      'icon': Icons.group,
    },
    {
      'title': 'All Cases',
      'subtitle': 'Track financial & dues',
      'icon': Icons.receipt_long,
    },
    {
      'title': 'Reports',
      'subtitle': 'Monitor entry and exit',
      'icon': Icons.bar_chart,
    },
    {
      'title': 'System Logs',
      'subtitle': 'Communicate with housekeeping',
      'icon': Icons.note,
    },
    {'title': 'Setting', 'subtitle': 'Report issues', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: Container(
          padding: EdgeInsets.only(top: 50, left: 16, right: 16),
          decoration: BoxDecoration(color: Color(0xFF002B45)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SUPER ADMIN",
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
                  Spacer(),
                  Stack(
                    children: [
                      Icon(Icons.notifications, color: Colors.white, size: 28),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "5",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            return Card(
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
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
