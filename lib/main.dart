import 'package:flutter/material.dart';
import 'package:fyp/get.dart';
import 'package:fyp/pages/superadmin/admin_add_officer.dart';
import 'package:fyp/pages/superadmin/admin_add_station.dart';
import 'package:get/get.dart';
import 'package:fyp/pages/hc/hc_assigned_cases.dart';
import 'package:fyp/pages/hc/hc_dashboard.dart';
import 'package:fyp/pages/superadmin/admin_dashboard.dart';
import 'package:fyp/pages/hc/hc_homepage.dart';
import 'package:fyp/pages/login_page.dart';
import 'package:fyp/pages/si/si_assign_to_hc.dart';
import 'package:fyp/pages/si/si_case_assign.dart';
import 'package:fyp/pages/si/si_complaints_approval.dart';
import 'package:fyp/pages/si/si_dashboard.dart';
import 'package:fyp/pages/si/si_menu.dart';
import 'package:fyp/pages/sos_page.dart';
import 'package:get_storage/get_storage.dart';
// import your login page and any other pages as needed

void main() async {
  await GetStorage.init();
  Get.put(AppController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppController>();
    
    return MaterialApp(
      title: 'SOS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Obx(() {
        // If no JWT token, show login page
        if (authController.jwt.value.isEmpty) {
          return LoginPage();
        }
        
        // If logged in, show appropriate dashboard based on role
        switch (authController.userRole.value) {
          case 'SUPERADMIN':
            return AdminDashboard();
          case 'HC':
            return HCHomepage();
          case 'SI':
            return SIMenu();
          default:
            return LoginPage();
        }
      }),

      routes: {
        //auth pages
        '/login': (context) => LoginPage(),

        // HC ROUTES
        '/hc/dashboard': (context) => HCDashboardPage(),
        '/hc/assigned': (context) => HCAssignedCasesPage(),
        '/hc/home': (context) => HCHomepage(),

        // SI ROUTES
        '/si/dashboard': (context) => SIDashboardFull(),
        '/si/assigned-cases': (context) => SIAssignedCasesScreen(),
        '/si/menu': (context) => SIMenu(),
        '/si/assign-to-hc': (context) => SIAssignToHCScreen(),
        '/si/complaint-approval': (context) => SIComplaintApprovals(),

        //ADMIN routes
        '/admin/home': (context) => AdminDashboard(),
        '/admin/addstation': (context) => AddStationPage(),
        '/admin/addofficer': (context) => AddPoliceOfficerPage(),

        //SOS
        '/sos': (context) => SOSAlertPage(),
      },
    );
  }
}
