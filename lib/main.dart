import 'package:flutter/material.dart';
import 'package:fyp/pages/hc_assigned_cases.dart';
import 'package:fyp/pages/hc_dashboard.dart';
import 'package:fyp/pages/admin_dashboard.dart';
import 'package:fyp/pages/hc_homepage.dart';
import 'package:fyp/pages/login_page.dart';
import 'package:fyp/pages/si_assign_to_hc.dart';
import 'package:fyp/pages/si_case_assign.dart';
import 'package:fyp/pages/si_complaints_approval.dart';
import 'package:fyp/pages/si_dashboard.dart';
import 'package:fyp/pages/si_menu.dart';
import 'package:fyp/pages/sos_page.dart';
// import your login page and any other pages as needed

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS',
      theme: ThemeData(primarySwatch: Colors.blue),

      // STARTING PAGE: you can change this to LoginScreen or a splash screen later
      home: HCHomepage(), // Placeholder for routing test

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
        '/admin': (context) => AdminDashboard(),

        //SOS
        '/sos': (context) => SOSAlertPage(),
      },
    );
  }
}
