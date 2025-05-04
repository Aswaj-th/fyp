import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddStationPage extends StatefulWidget {
  @override
  _AddStationPageState createState() => _AddStationPageState();
}

class _AddStationPageState extends State<AddStationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stationName = TextEditingController();
  // final TextEditingController _stationHead = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();
  final TextEditingController _contact = TextEditingController();

  DateTime? _selectedDate;

  String? _selectedOfficer;

  final List<String> _officerList = [
    'Esther Howard',
    'Ralph Edwards',
    'Wade Warren',
  ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('https://yourapi.com/api/add-station');

    final payload = {
      "station_name": _stationName.text,
      "station_head": _selectedOfficer,
      "address": _address.text,
      "city": _city.text,
      "state": _state.text,
      "country": _country.text,
      "pincode": _pincode.text,
      "latitude": _latitude.text,
      "longitude": _longitude.text,
      "contact_number": _contact.text,
      "timestamp": _selectedDate?.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Station added');
        Get.offAllNamed('/stations'); // redirect to list/dashboard
      } else {
        Get.snackbar('Error', 'Failed to add station');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Police Station")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Station ID", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                initialValue: "Autogen by backend",
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Station Name"),
              TextFormField(
                controller: _stationName,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Station Head"),
              DropdownButtonFormField<String>(
                value: _selectedOfficer,
                items:
                    _officerList
                        .map(
                          (officer) => DropdownMenuItem(
                            value: officer,
                            child: Text(officer),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedOfficer = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Address"),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("City"),
              TextFormField(
                controller: _city,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("State"),
              TextFormField(
                controller: _state,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Country"),
              TextFormField(
                controller: _country,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Pincode"),
              TextFormField(
                controller: _pincode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Coordinates"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      decoration: InputDecoration(labelText: "Latitude"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      decoration: InputDecoration(labelText: "Longitude"),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Optional: open a map picker
                  },
                  child: Text("Choose Coordinates"),
                ),
              ),
              SizedBox(height: 16),
              Text("Contact Number"),
              TextFormField(
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("Timestamp"),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text("Add Station", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
