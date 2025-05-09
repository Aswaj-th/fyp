import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/get.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomNavigationBar({Key? key, required this.currentIndex, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppController>();
    final userRole = authController.userRole.value;

    // Define navigation items based on user role
    List<BottomNavigationBarItem> getNavigationItems() {
      switch (userRole) {
        case 'ADMIN':
          return const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ];
        case 'SI':
          return const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'SOS Alert',
            ),
          ];
        case 'HC':
          return const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'SOS Alert',
            ),
          ];
        default:
          return const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ];
      }
    }

    // Define navigation routes based on user role
    String? getRouteForIndex(int index) {
      switch (userRole) {
        case 'SI':
          switch (index) {
            case 0:
              return '/si/home';
            case 1:
              return '/si/dashboard';
            case 4:
              return '/sos';
          }
          break;
        case 'HC':
          switch (index) {
            case 0:
              return '/hc/home';
            case 1:
              return '/hc/stats';
            case 2:
              return '/sos';
          }
          break;
        case 'ADMIN':
          switch (index) {
            case 0:
              return '/admin/dashboard';
            case 1:
              return '';
          }
          break;
      }
      return null;
    }

    void handleNavigation(int index) {
      if (index == currentIndex) return;

      final route = getRouteForIndex(index);
      if (route != null && route.isNotEmpty) {
        Navigator.pushNamed(context, route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This feature is coming soon!')),
        );
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: onTap ?? handleNavigation,
      items: getNavigationItems(),
    );
  }
}
