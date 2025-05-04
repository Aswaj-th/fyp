import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/get.dart';
import 'package:fyp/config/env.dart';

class AddPoliceOfficerPage extends StatefulWidget {
  @override
  _AddPoliceOfficerPageState createState() => _AddPoliceOfficerPageState();
}

class _AddPoliceOfficerPageState extends State<AddPoliceOfficerPage> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AppController>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _badgeNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedRole;
  String? _selectedStationId;
  List<Map<String, dynamic>> stations = [];
  bool isLoadingStations = true;

  final List<String> _roles = [
    'SUPERADMIN',
    'SI',
    'HC',
  ];

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    setState(() {
      isLoadingStations = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/police-stations'),
        headers: {
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stations = List<Map<String, dynamic>>.from(data['data']);
          isLoadingStations = false;
        });
      } else {
        Get.snackbar(
          'Error',
          'Failed to load stations',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isLoadingStations = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoadingStations = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      Get.snackbar(
        'Error',
        'Please select a role',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_selectedStationId == null) {
      Get.snackbar(
        'Error',
        'Please select a station',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${Env.apiUrl}/users');

    final payload = {
      "name": _nameController.text,
      "role": _selectedRole,
      "badgeNumber": _badgeNumberController.text,
      "phoneNumber": _phoneNumberController.text,
      "currentStationId": _selectedStationId,
      "isActive": true,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.jwt.value}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Officer added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          error['message'] ?? 'Failed to add officer',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _badgeNumberController,
                decoration: InputDecoration(
                  labelText: 'Badge Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter badge number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              isLoadingStations
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedStationId,
                      items: stations
                          .map((station) => DropdownMenuItem<String>(
                                value: station['id'].toString(),
                                child: Text(station['name']),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStationId = value),
                      decoration: InputDecoration(
                        labelText: 'Station',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a station';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Add Officer', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _badgeNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
