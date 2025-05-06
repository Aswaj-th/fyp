import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FIRListPage extends StatefulWidget {
  @override
  _FIRListPageState createState() => _FIRListPageState();
}

class FIR {
  final String id;
  final String title;
  final DateTime incidentDate;

  FIR({required this.id, required this.title, required this.incidentDate});

  factory FIR.fromJson(Map<String, dynamic> json) {
    return FIR(
      id: json['_id'],
      title: json['title'],
      incidentDate: DateTime.parse(json['incidentDate']),
    );
  }
}

class FirService {
  Future<List<FIR>> getFIRsByHC(String hcId) async {
    final response = await http.get(
      Uri.parse('http://10.0.9.48:8080/api/fir/created-by-me'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FIR.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load FIRs');
    }
  }
}

class _FIRListPageState extends State<FIRListPage> {
  late Future<List<FIR>> _firListFuture;

  @override
  void initState() {
    super.initState();
    _firListFuture = fetchFIRsForHC();
  }

  Future<List<FIR>> fetchFIRsForHC() async {
    final hcId =
        'your_hc_id_here'; // Replace with actual user ID or fetch from controller
    return await FirService().getFIRsByHC(hcId);
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
                  subtitle: Text("Filed on: ${fir.incidentDate.toLocal()}"),
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
