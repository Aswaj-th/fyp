import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FIRDetailPage extends StatefulWidget {
  final String firId;

  const FIRDetailPage({required this.firId, Key? key}) : super(key: key);

  @override
  State<FIRDetailPage> createState() => _FIRDetailPageState();
}

class _FIRDetailPageState extends State<FIRDetailPage> {
  late Future<List<dynamic>> _firDetails;

  @override
  void initState() {
    super.initState();
    _firDetails = FirService().getFirDetailsById(widget.firId);
  }

  Widget _buildMainFIRBox(Map<String, dynamic> fir) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fir['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Description: ${fir['description']}"),
            Text("Date: ${fir['incidentDate']}"),
            Text("Address: ${fir['incidentAddress']}"),
            Text(
              "Complainant: ${fir['complainantName']} (${fir['complainantGender']})",
            ),
            Text("Mobile: ${fir['complainantMobile']}"),
            if (fir['complainantEmail'] != null)
              Text("Email: ${fir['complainantEmail']}"),
            Text("Complainant Address: ${fir['complainantAddress']}"),
            Text("Complaint Type: ${fir['complaintType']}"),
            Text("Category: ${fir['category']}"),
            Text("Notes: ${fir['notes']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateBox(Map<String, dynamic> update) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(
          update['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(update['description']),
            SizedBox(height: 4),
            Text("Updated: ${update['updateDate']}"),
            if (update['isImportant'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text("★ Important", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FIR Details")),
      body: FutureBuilder<List<dynamic>>(
        future: _firDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No details found'));

          final data = snapshot.data!;
          final fir = data.first;
          final updates = data.sublist(1);

          return ListView(
            children: [
              _buildMainFIRBox(fir),
              ...updates.map((u) => _buildUpdateBox(u)).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addUpdate', arguments: widget.firId);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FirService {
  final String baseUrl = 'http://10.0.9.48:8080'; // Replace with your base URL

  Future<List<dynamic>> getFirDetailsById(String firId) async {
    final url = Uri.parse('$baseUrl/api/$firId/station');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception('Failed to fetch FIR details');
    }
  }
}
