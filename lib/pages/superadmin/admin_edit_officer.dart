import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/get.dart';
import 'package:fyp/config/env.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:async';

class EditOfficerPage extends StatefulWidget {
  final Map<String, dynamic> officer;

  const EditOfficerPage({Key? key, required this.officer}) : super(key: key);

  @override
  _EditOfficerPageState createState() => _EditOfficerPageState();
}

class _EditOfficerPageState extends State<EditOfficerPage> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AppController>();
  bool _isLoading = false;
  bool isLoadingStations = true;
  List<Map<String, dynamic>> stations = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _badgeNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  String? _selectedRole;
  String? _selectedStationId;
  bool _isActive = true;

  final List<String> _roles = ['SUPERADMIN', 'SI', 'HC'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    fetchStations();
  }

  void _initializeForm() {
    _nameController.text = widget.officer['name'] ?? '';
    _badgeNumberController.text = widget.officer['badgeNumber'] ?? '';
    _phoneNumberController.text = widget.officer['phoneNumber'] ?? '';
    _selectedRole = widget.officer['role'];
    _selectedStationId = widget.officer['station']?['id']?.toString();
    _isActive = widget.officer['isActive'] ?? true;

    // Initialize joining date
    final joiningDate =
        widget.officer['joiningDate'] != null
            ? DateTime.parse(widget.officer['joiningDate'])
            : DateTime.now();
    _joiningDateController.text = DateFormat('yyyy-MM-dd').format(joiningDate);
  }

  Future<void> fetchStations() async {
    setState(() {
      isLoadingStations = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/police-stations'),
        headers: {'Authorization': 'Bearer ${authController.jwt.value}'},
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_joiningDateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (_selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a station'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if token exists
    if (authController.jwt.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${Env.apiUrl}/users/${widget.officer['id']}');

    final payload = {
      "name": _nameController.text,
      "role": _selectedRole,
      "badgeNumber": _badgeNumberController.text,
      "phoneNumber": _phoneNumberController.text,
      "currentStationId": _selectedStationId,
      "isActive": _isActive,
      "joinedDate": _joiningDateController.text,
    };

    try {
      print('Sending request to: $url');
      print('Payload: $payload');
      print('Using token: ${authController.jwt.value}');

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authController.jwt.value}',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'The request timed out. Please check your internet connection and try again.',
              );
            },
          );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Officer updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You do not have permission to update this officer. Please check your role and permissions.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Officer not found. The officer may have been deleted.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ??
            'Invalid data provided. Please check your input.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } else if (response.statusCode >= 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error. Please try again later.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to update officer';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request timed out. Please check your internet connection and try again.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid response from server. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error updating officer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
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
      appBar: AppBar(
        title: Text('Edit Officer'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Delete Officer'),
                      content: Text(
                        'Are you sure you want to delete this officer?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() => _isLoading = true);
                            try {
                              final response = await http.delete(
                                Uri.parse(
                                  '${Env.apiUrl}/users/${widget.officer['id']}',
                                ),
                                headers: {
                                  'Authorization':
                                      'Bearer ${authController.jwt.value}',
                                },
                              );
                              if (response.statusCode == 200) {
                                Get.snackbar(
                                  'Success',
                                  'Officer deleted successfully',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                Navigator.pop(context, true);
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to delete officer',
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
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
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
              TextFormField(
                controller: _joiningDateController,
                decoration: InputDecoration(
                  labelText: 'Joining Date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a joining date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items:
                    _roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
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
                    items:
                        stations
                            .map(
                              (station) => DropdownMenuItem<String>(
                                value: station['id'].toString(),
                                child: Text(station['name']),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => _selectedStationId = value),
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
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Active Status'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
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
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Update Officer',
                            style: TextStyle(fontSize: 16),
                          ),
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
    _joiningDateController.dispose();
    super.dispose();
  }
}
