import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/config/env.dart';
import 'package:fyp/get.dart';
import 'package:get/get.dart';

class FIRListPage extends StatefulWidget {
  @override
  _FIRListPageState createState() => _FIRListPageState();
}

// Updated FIR model
class FIR {
  final String id;
  final String title;
  final DateTime incidentDate;
  final String description;
  final String incidentAddress;
  final String complainantName;
  final String complainantGender;
  final String complainantMobile;
  final String? complainantEmail; // nullable
  final String complainantAddress;
  final String complaintType;
  final String category;
  final String notes;

  FIR({
    required this.id,
    required this.title,
    required this.incidentDate,
    required this.description,
    required this.incidentAddress,
    required this.complainantName,
    required this.complainantGender,
    required this.complainantMobile,
    this.complainantEmail, // nullable
    required this.complainantAddress,
    required this.complaintType,
    required this.category,
    required this.notes,
  });

  factory FIR.fromJson(Map<String, dynamic> json) {
    return FIR(
      id: json['_id'],
      title: json['title'] ?? '',
      incidentDate: DateTime.parse(json['incidentDate']),
      description: json['description'] ?? '',
      incidentAddress: json['incidentAddress'] ?? '',
      complainantName: json['complainantName'] ?? '',
      complainantGender: json['complainantGender'] ?? '',
      complainantMobile: json['complainantMobile'] ?? '',
      complainantEmail:
          json['complainantEmail'] != null &&
                  json['complainantEmail'].toString().isNotEmpty
              ? json['complainantEmail']
              : null,
      complainantAddress: json['complainantAddress'] ?? '',
      complaintType: json['complaintType'] ?? '',
      category: json['category'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

// FIR fetching service
class FirService {
  final authController = Get.find<AppController>();
  Future<List<FIR>> getFIRsByHC() async {
    final response = await http
        .get(
          Uri.parse('${Env.apiUrl}/fir/created-by-me'),
          headers: {
            'Authorization': 'Bearer ${authController.jwt.value}',
            'Content-Type': 'application/json',
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((json) => FIR.fromJson(json)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load FIRs');
    }
  }
}

// Page state
class _FIRListPageState extends State<FIRListPage> {
  late Future<List<FIR>> _firListFuture;

  @override
  void initState() {
    super.initState();
    _firListFuture = fetchFIRsForHC();
  }

  Future<List<FIR>> fetchFIRsForHC() async {
    return await FirService().getFIRsByHC();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Filed FIRs")),
      body: FutureBuilder<List<FIR>>(
        future: _firListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No FIRs found."));
          }

          final firList = snapshot.data!;
          return ListView.builder(
            itemCount: firList.length,
            itemBuilder: (context, index) {
              final fir = firList[index];
              return Card(
                child: ListTile(
                  title: Text(fir.title),
                  subtitle: Text(
                    "Filed on: ${fir.incidentDate.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to FIR detail page if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
