import 'package:flutter/material.dart';
import 'package:fyp/get.dart';
import 'package:fyp/pages/hc/create_fir_page.dart';
import 'package:fyp/pages/hc/hc_my_fir.dart';
import 'package:fyp/pages/splash_screen.dart';
import 'package:fyp/pages/superadmin/admin_add_officer.dart';
import 'package:fyp/pages/superadmin/admin_add_station.dart';
import 'package:fyp/pages/superadmin/admin_stations_list.dart';
import 'package:fyp/pages/superadmin/admin_users_list.dart';
import 'package:get/get.dart';
import 'package:fyp/pages/hc/hc_assigned_cases.dart';
import 'package:fyp/pages/hc/hc_dashboard.dart';
import 'package:fyp/pages/superadmin/admin_dashboard.dart';
import 'package:fyp/pages/hc/hc_homepage.dart';
import 'package:fyp/pages/login_page.dart';
import 'package:fyp/pages/si/si_assign_to_hc.dart';
import 'package:fyp/pages/si/si_assigned_cases.dart';
import 'package:fyp/pages/si/si_complaints_approval.dart';
import 'package:fyp/pages/si/si_dashboard.dart';
import 'package:fyp/pages/si/si_menu.dart';
import 'package:fyp/pages/sos_page.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fyp/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp/pages/hc/hc_edit_investigation_first.dart';
import 'package:fyp/pages/si/si_transfer_cases.dart';


void main() async {
  await GetStorage.init();
  Get.put(AppController());
  Get.put(AuthController()); // Initialize AuthController
  await Supabase.initialize(
    url: "https://xufmvctnzhyujpqaoowp.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1Zm12Y3Ruemh5dWpwcWFvb3dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTI5MzEsImV4cCI6MjA1OTU2ODkzMX0.WTixnRaJOziT4ToxL1o-VMTUR129MSAV_KbdGpJ1yxI",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Police Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        //auth pages
        '/login': (context) => LoginPage(),

        // HC ROUTES
        '/hc/dashboard': (context) => HCDashboardPage(),
        '/hc/assigned': (context) => HCAssignedCasesPage(),
        '/hc/create-fir': (context) => CreateFirPage(),
        '/hc/my-fir': (context) => FIRListPage(),
        '/hc/home': (context) => HCHomepage(),
        '/hc/edit-investigation-first': (context) {
          final firId = ModalRoute.of(context)!.settings.arguments as String;
          return FIRDetailPage(firId: firId);
        },

        // SI ROUTES
        '/si/dashboard': (context) => SIDashboardFull(),
        '/si/assigned-cases': (context) => SIAssignedCasesScreen(),
        '/si/menu': (context) => SIMenu(),
        '/si/assign-to-hc': (context) => SIAssignToHCScreen(),
        '/si/complaint-approval': (context) => SIComplaintApprovals(),
        '/si/transfer-cases': (context) => TransferCasesPage(),

        //ADMIN routes
        '/admin/home': (context) => AdminDashboard(),
        '/admin/addstation': (context) => AddStationPage(),
        '/admin/stations': (context) => AdminStationsList(),
        '/admin/addofficer': (context) => AddPoliceOfficerPage(),
        '/admin/officers': (context) => AdminUsersList(),

        //SOS
        '/sos': (context) => SOSAlertPage(),
      },
    );
  }
}
