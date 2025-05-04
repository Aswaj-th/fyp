import 'package:flutter/material.dart';

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
      'title': 'Investigation Updates',
      'subtitle': 'Ensures safety by monitoring',
      'icon': Icons.search,
      'iconColor': Colors.lightBlue,
      'path': '',
    },
    {
      'title': 'Emergency',
      'subtitle': 'Simplifies communication with the housekeeping team.',
      'icon': Icons.emergency,
      'iconColor': Colors.redAccent,
      'path': '/sos',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
          decoration: const BoxDecoration(color: Color(0xFF002B45)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                      'assets/profile.jpg',
                    ), // Ensure this exists
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "SENIOR INSPECTOR",
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
            ],
          ),
        ),
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
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
