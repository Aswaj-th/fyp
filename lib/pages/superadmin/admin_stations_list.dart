import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/get.dart';
import 'package:fyp/config/env.dart';
import 'package:fyp/pages/superadmin/admin_edit_station.dart';

class AdminStationsList extends StatefulWidget {
  @override
  _AdminStationsListState createState() => _AdminStationsListState();
}

class _AdminStationsListState extends State<AdminStationsList> {
  final authController = Get.find<AppController>();
  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;
  String error = '';
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  void _showMessage(String message, {bool isError = false}) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> fetchStations() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      print('Fetching stations from: ${Env.apiUrl}/police-stations');
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/police-stations'),
        headers: {
          'Authorization': 'Bearer ${authController.jwt.value}',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stations = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
        _showMessage('Stations loaded successfully');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load stations';
        setState(() {
          error = errorMessage;
          isLoading = false;
        });
        _showMessage(errorMessage, isError: true);
      }
    } on TimeoutException {
      setState(() {
        error = 'Connection timed out. Please check your internet connection and try again.';
        isLoading = false;
      });
      _showMessage('Connection timed out. Please try again.', isError: true);
    } catch (e) {
      print('Error fetching stations: $e');
      setState(() {
        error = 'Error loading stations: $e';
        isLoading = false;
      });
      _showMessage('Error loading stations: $e', isError: true);
    }
  }

  List<Map<String, dynamic>> get filteredStations {
    if (searchController.text.isEmpty) {
      return stations;
    }
    final searchTerm = searchController.text.toLowerCase();
    return stations.where((station) {
      return station['name'].toString().toLowerCase().contains(searchTerm) ||
          station['city'].toString().toLowerCase().contains(searchTerm) ||
          station['state'].toString().toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Police Stations'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchStations,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search stations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(error),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchStations,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredStations.isEmpty
                        ? Center(child: Text('No stations found'))
                        : RefreshIndicator(
                            onRefresh: fetchStations,
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: filteredStations.length,
                              itemBuilder: (context, index) {
                                final station = filteredStations[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        station['name'][0].toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      station['name'] ?? 'Unnamed Station',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${station['address']}, ${station['city']}, ${station['state']}',
                                                style: TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              station['contactNumber'] ?? 'N/A',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Station Head: ${station['stationHead']?['name'] ?? 'Not Assigned'}',
                                                style: TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.edit),
                                                title: Text('Edit Station'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditStationPage(
                                                            station: station,
                                                          ),
                                                    ),
                                                  ).then((updated) {
                                                    if (updated == true) {
                                                      fetchStations();
                                                    }
                                                  });
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                title: Text(
                                                  'Delete Station',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: Text('Delete Station'),
                                                      content: Text(
                                                        'Are you sure you want to delete this station?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(context);
                                                            try {
                                                              final response =
                                                                  await http.delete(
                                                                Uri.parse(
                                                                  '${Env.apiUrl}/police-stations/${station['id']}',
                                                                ),
                                                                headers: {
                                                                  'Authorization':
                                                                      'Bearer ${authController.jwt.value}',
                                                                },
                                                              );
                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                _showMessage(
                                                                  'Station deleted successfully',
                                                                );
                                                                fetchStations();
                                                              } else {
                                                                final errorData =
                                                                    jsonDecode(
                                                                        response
                                                                            .body);
                                                                _showMessage(
                                                                  errorData['message'] ??
                                                                      'Failed to delete station',
                                                                  isError: true,
                                                                );
                                                              }
                                                            } catch (e) {
                                                              _showMessage(
                                                                'Error deleting station: $e',
                                                                isError: true,
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/addstation').then((_) {
            fetchStations();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
