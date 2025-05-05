import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/services/fir_service.dart';
import 'package:fyp/get.dart';

class CreateFirPage extends StatefulWidget {
  @override
  _CreateFirPageState createState() => _CreateFirPageState();
}

class _CreateFirPageState extends State<CreateFirPage> {
  final _formKey = GlobalKey<FormState>();
  final _firService = FirService();
  final _authController = Get.find<AppController>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _complainantNameController = TextEditingController();
  final _complainantMobileController = TextEditingController();
  final _complainantEmailController = TextEditingController();
  final _complainantAddressController = TextEditingController();
  final _actionRequiredController = TextEditingController();

  String _selectedGender = 'MALE';
  String _selectedComplaintType = 'CRIMINAL';
  String _selectedCategory = 'THEFT';
  String _selectedSubCategory = 'VEHICLE_THEFT';
  DateTime? _incidentDate;

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];
  final List<String> _complaintTypes = [
    'CRIMINAL',
    'CIVIL',
    'TRAFFIC',
    'OTHER',
  ];
  final Map<String, List<String>> _categories = {
    'CRIMINAL': ['THEFT', 'ASSAULT', 'FRAUD', 'OTHER'],
    'CIVIL': ['PROPERTY_DISPUTE', 'CONTRACT_DISPUTE', 'OTHER'],
    'TRAFFIC': ['ACCIDENT', 'VIOLATION', 'OTHER'],
    'OTHER': ['OTHER'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _complainantNameController.dispose();
    _complainantMobileController.dispose();
    _complainantEmailController.dispose();
    _complainantAddressController.dispose();
    _actionRequiredController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _incidentDate) {
      setState(() {
        _incidentDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select incident date'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'incidentDate': _incidentDate!.toIso8601String(),
        'address': _addressController.text,
        'complainantName': _complainantNameController.text,
        'complainantGender': _selectedGender,
        'complainantMobile': _complainantMobileController.text,
        'complainantEmail': _complainantEmailController.text,
        'complainantAddress': _complainantAddressController.text,
        'complaintType': _selectedComplaintType,
        'categoryId': _selectedCategory,
        'subcategoryId':
            _selectedSubCategory == _selectedCategory
                ? null
                : _selectedSubCategory,
        'actionRequired': _actionRequiredController.text,
        'createdById': _authController.userInfo['id'],
        'stationId': _authController.userInfo['stationId'],
        'originStationId': _authController.userInfo['stationId'],
      };

      await _firService.createFir(firData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FIR created successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Get.back(result: true);
    } catch (e) {
      print('Error creating FIR: $e');
      String errorMessage = 'Failed to create FIR';

      if (e.toString().contains('No internet connection')) {
        errorMessage =
            'No internet connection. Please check your network settings and ensure the server is running.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. The server might be unresponsive.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      // Show a dialog with more detailed error information
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error Creating FIR'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('There was an error while trying to create the FIR:'),
                  SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Troubleshooting tips:'),
                  SizedBox(height: 8),
                  Text('1. Make sure your server is running'),
                  Text('2. Check your network connection'),
                  Text('3. Verify the API URL in env.dart is correct'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
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
      appBar: AppBar(title: Text('Create New FIR')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Incident Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _incidentDate == null
                                ? 'Select Date'
                                : '${_incidentDate!.day}/${_incidentDate!.month}/${_incidentDate!.year}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Complainant Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _complainantNameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter complainant name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _genders.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _complainantMobileController,
                        decoration: InputDecoration(
                          labelText: 'Mobile',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _complainantEmailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _complainantAddressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Complaint Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedComplaintType,
                        decoration: InputDecoration(
                          labelText: 'Complaint Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _complaintTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedComplaintType = newValue;
                              _selectedCategory = _categories[newValue]![0];
                              _selectedSubCategory = _categories[newValue]![0];
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _categories[_selectedComplaintType]!.map((
                              String category,
                            ) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _selectedSubCategory = newValue;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _actionRequiredController,
                        decoration: InputDecoration(
                          labelText: 'Action Required',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter required action';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Create FIR'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
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
