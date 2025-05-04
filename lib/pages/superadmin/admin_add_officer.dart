import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPoliceOfficerPage extends StatefulWidget {
  @override
  _AddPoliceOfficerPageState createState() => _AddPoliceOfficerPageState();
}

class _AddPoliceOfficerPageState extends State<AddPoliceOfficerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _selectedRole;
  String? _selectedStationId;
  String? _selectedStatus;
  DateTime? _joiningDate;

  bool _isLoading = false;

  final List<String> _roles = ['DGP', 'SI', 'HC'];
  final List<String> _stations = ['Station A', 'Station B'];
  final List<String> _statuses = ['Active', 'Inactive'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('https://yourapi.com/api/add-officer');

    final payload = {
      "name": _nameController.text,
      "role": _selectedRole,
      "badge_number": _badgeController.text,
      "station_id": _selectedStationId,
      "contact_number": _contactController.text,
      "active_status": _selectedStatus,
      "joining_date": _joiningDate?.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/officer-list');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add officer')));
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Police Officer')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Info', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                initialValue: 'AutoGen by Backend',
                readOnly: true,
                decoration: InputDecoration(labelText: 'Police ID'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items:
                    _roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
                decoration: InputDecoration(labelText: 'Role'),
                validator: (val) => val == null ? 'Please select a role' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _badgeController,
                decoration: InputDecoration(labelText: 'Badge Number'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter badge number'
                            : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStationId,
                items:
                    _stations
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedStationId = val),
                decoration: InputDecoration(labelText: 'Station ID'),
                validator:
                    (val) => val == null ? 'Please select a station' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Contact Number'),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter contact' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items:
                    _statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val),
                decoration: InputDecoration(labelText: 'Active Status'),
                validator: (val) => val == null ? 'Please select status' : null,
              ),
              SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(labelText: 'Joining Date'),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _joiningDate = picked);
                    }
                  },
                  child: Text(
                    _joiningDate == null
                        ? 'Select Date'
                        : _joiningDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Add Officer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
