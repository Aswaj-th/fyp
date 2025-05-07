import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/get.dart';
import 'package:fyp/config/env.dart';
import 'package:fyp/pages/superadmin/admin_edit_officer.dart';

class AdminUsersList extends StatefulWidget {
  @override
  _AdminUsersListState createState() => _AdminUsersListState();
}

class _AdminUsersListState extends State<AdminUsersList> {
  final authController = Get.find<AppController>();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String error = '';
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    fetchUsers();
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

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/users'),
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
          users = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
        _showMessage('Users loaded successfully');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load users';
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
    } catch (e, stackTrace) {
      print('Exception occurred: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
      _showMessage('Failed to load users: $e', isError: true);
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchController.text.isEmpty) {
      return users;
    }
    final searchTerm = searchController.text.toLowerCase();
    return users.where((user) {
      return user['name'].toString().toLowerCase().contains(searchTerm) ||
          user['badgeNumber'].toString().toLowerCase().contains(searchTerm) ||
          user['role'].toString().toLowerCase().contains(searchTerm) ||
          (user['station']?['name'] ?? '').toString().toLowerCase().contains(
            searchTerm,
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Police Officers'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: fetchUsers)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search officers...',
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
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : error.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(error),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchUsers,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : filteredUsers.isEmpty
                    ? Center(child: Text('No officers found'))
                    : RefreshIndicator(
                      onRefresh: fetchUsers,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getRoleColor(user['role']),
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                user['name'] ?? 'Unnamed Officer',
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
                                        Icons.badge,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Badge: ${user['badgeNumber'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Role: ${user['role'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
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
                                          'Station: ${user['currentStation']?['name'] ?? 'Not Assigned'}',
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
                                        user['phoneNumber'] ?? 'N/A',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 16,
                                        color:
                                            user['isActive'] == true
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        user['isActive'] == true
                                            ? 'Active'
                                            : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              user['isActive'] == true
                                                  ? Colors.green
                                                  : Colors.red,
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
                                    builder:
                                        (context) => Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit Officer'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            EditOfficerPage(
                                                              officer: user,
                                                            ),
                                                  ),
                                                ).then((updated) {
                                                  if (updated == true) {
                                                    fetchUsers();
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
                                                'Delete Officer',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onTap: () {
                                                // TODO: Implement delete functionality
                                                Navigator.pop(context);
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
          Navigator.pushNamed(context, '/admin/addofficer').then((_) {
            fetchUsers(); // Refresh the list when returning from add officer
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'SUPERADMIN':
        return Colors.purple;
      case 'SI':
        return Colors.blue;
      case 'HC':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
