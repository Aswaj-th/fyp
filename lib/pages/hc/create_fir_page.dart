import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/services/fir_service.dart';
import 'package:fyp/get.dart';
import 'package:intl/intl.dart';

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
  String? _selectedSubCategory;
  DateTime? _incidentDate;

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];
  final List<String> _complaintTypes = [
    'CRIMINAL',
    'CIVIL',
    'TRAFFIC',
    'OTHER',
  ];

  // Updated to match backend expectations
  final Map<String, Map<String, String>> _categoriesWithIds = {
    'CRIMINAL': {
      'THEFT': '550e8400-e29b-41d4-a716-446655440000',
      'ASSAULT': '550e8400-e29b-41d4-a716-446655440001',
      'FRAUD': '550e8400-e29b-41d4-a716-446655440002',
      'OTHER': '550e8400-e29b-41d4-a716-446655440003',
    },
    'CIVIL': {
      'PROPERTY_DISPUTE': '550e8400-e29b-41d4-a716-446655440004',
      'CONTRACT_DISPUTE': '550e8400-e29b-41d4-a716-446655440005',
      'OTHER': '550e8400-e29b-41d4-a716-446655440006',
    },
    'TRAFFIC': {
      'ACCIDENT': '550e8400-e29b-41d4-a716-446655440007',
      'VIOLATION': '550e8400-e29b-41d4-a716-446655440008',
      'OTHER': '550e8400-e29b-41d4-a716-446655440009',
    },
    'OTHER': {'OTHER': '550e8400-e29b-41d4-a716-446655440010'},
  };

  // Map with subcategories
  final Map<String, Map<String, String>> _subCategoriesWithIds = {
    'THEFT': {
      'VEHICLE_THEFT': '550e8400-e29b-41d4-a716-446655440011',
      'HOME_BURGLARY': '550e8400-e29b-41d4-a716-446655440012',
      'PICKPOCKETING': '550e8400-e29b-41d4-a716-446655440013',
    },
    'ASSAULT': {
      'PHYSICAL_ASSAULT': '550e8400-e29b-41d4-a716-446655440014',
      'VERBAL_ASSAULT': '550e8400-e29b-41d4-a716-446655440015',
    },
    // Add additional subcategories as needed
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
      // Get the category ID
      final categoryId =
          _categoriesWithIds[_selectedComplaintType]?[_selectedCategory] ?? '';

      // Get the subcategory ID if selected
      String? subcategoryId;
      if (_selectedSubCategory != null &&
          _subCategoriesWithIds.containsKey(_selectedCategory)) {
        subcategoryId =
            _subCategoriesWithIds[_selectedCategory]?[_selectedSubCategory];
      }

      final firData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'incidentDate':
            _incidentDate!.toIso8601String(), // ISO format as per API spec
        'address': _addressController.text,
        'complainantName': _complainantNameController.text,
        'complainantGender': _selectedGender,
        'complainantMobile': _complainantMobileController.text,
        'complainantEmail':
            _complainantEmailController.text.isNotEmpty
                ? _complainantEmailController.text
                : null,
        'complainantAddress': _complainantAddressController.text,
        'complaintType': _selectedComplaintType,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'actionRequired': _actionRequiredController.text,
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
      appBar: AppBar(title: Text('Create New FIR'), elevation: 2),
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
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Incident Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.title),
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
                                  prefixIcon: Icon(Icons.description),
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
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _incidentDate == null
                                        ? 'Select Date'
                                        : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_incidentDate!),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Incident Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an address';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complainant Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _complainantNameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
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
                                  prefixIcon: Icon(Icons.people),
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
                                  labelText: 'Mobile Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
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
                                  labelText: 'Email (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !GetUtils.isEmail(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _complainantAddressController,
                                decoration: InputDecoration(
                                  labelText: 'Complainant Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.home),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complaint Classification',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedComplaintType,
                                decoration: InputDecoration(
                                  labelText: 'Complaint Type',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
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
                                      _selectedCategory =
                                          _categoriesWithIds[newValue]!
                                              .keys
                                              .first;
                                      _selectedSubCategory = null;
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
                                  prefixIcon: Icon(Icons.label),
                                ),
                                items:
                                    _categoriesWithIds[_selectedComplaintType]!
                                        .keys
                                        .map((String category) {
                                          return DropdownMenuItem<String>(
                                            value: category,
                                            child: Text(category),
                                          );
                                        })
                                        .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                      _selectedSubCategory = null;
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: 16),
                              // Only show subcategory if available
                              if (_subCategoriesWithIds.containsKey(
                                _selectedCategory,
                              ))
                                DropdownButtonFormField<String?>(
                                  value: _selectedSubCategory,
                                  decoration: InputDecoration(
                                    labelText: 'Subcategory (Optional)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.label_outline),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text("None"),
                                    ),
                                    ..._subCategoriesWithIds[_selectedCategory]!
                                        .keys
                                        .map((String subcategory) {
                                          return DropdownMenuItem<String>(
                                            value: subcategory,
                                            child: Text(subcategory),
                                          );
                                        })
                                        .toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSubCategory = newValue;
                                    });
                                  },
                                ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _actionRequiredController,
                                decoration: InputDecoration(
                                  labelText: 'Action Required',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.assignment),
                                ),
                                maxLines: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter required action';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.send),
                          label: Text(
                            'Submit FIR',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
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
