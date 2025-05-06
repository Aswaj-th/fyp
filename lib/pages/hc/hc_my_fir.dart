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
  final String? notes;

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
    this.notes,
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
      notes:
          json['notes'] != null && json['notes'].toString().isNotEmpty
              ? json['notes']
              : null,
    );
  }
}

// FIR fetching service
class FirService {
  final authController = Get.find<AppController>();
  Future<List<dynamic>> getFIRsByHC() async {
    final response = await http
        .get(
          Uri.parse('${Env.apiUrl}/fir/created-by-me'),
          headers: {
            'Authorization': 'Bearer ${authController.jwt.value}',
            'Content-Type': 'application/json',
          },
        )
        .timeout(Duration(seconds: 10));

    // print(response.statusCode);

    // print("\n\n\n\n\n\n\n\n\n\n\n" + response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      final List<dynamic> data = jsonResponse['data'];
      // print(data[0]['status']);
      return data;
    } else {
      // print(response.body);
      // print("Some error inside here");
      throw Exception('Failed to load FIRs');
    }
  }
}

// Page state
class _FIRListPageState extends State<FIRListPage> {
  late Future<List<dynamic>> _firListFuture;

  @override
  void initState() {
    super.initState();
    _firListFuture = fetchFIRsForHC();
    print(_firListFuture);
  }

  Future<List<dynamic>> fetchFIRsForHC() async {
    return await FirService().getFIRsByHC();
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Filed FIRs")),
      body: FutureBuilder<List<dynamic>>(
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
              final fir = firList[index] as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FIR Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      buildRow('Title', fir['title'] ?? 'N/A'),
                      buildRow(
                        'Incident Date',
                        (fir['incidentDate'] != null)
                            ? DateTime.parse(
                              fir['incidentDate'],
                            ).toLocal().toString().split(' ')[0]
                            : 'N/A',
                      ),
                      buildRow(
                        'Complainant Name',
                        fir['complainantName'] ?? 'N/A',
                      ),
                      buildRow('Mobile', fir['complainantMobile'] ?? 'N/A'),
                      buildRow('Gender', fir['complainantGender'] ?? 'N/A'),
                      buildRow(
                        'Email',
                        (fir['complainantEmail']?.isNotEmpty ?? false)
                            ? fir['complainantEmail']
                            : 'N/A',
                      ),
                      buildRow(
                        'Incident Address',
                        fir['incidentAddress'] ?? 'N/A',
                      ),
                      buildRow('Complaint Type', fir['complaintType'] ?? 'N/A'),
                      buildRow('Category', fir['category'] ?? 'N/A'),
                      if ((fir['notes']?.isNotEmpty ?? false))
                        buildRow('Notes', fir['notes']),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
