import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/components/custom_app_bar.dart';
import 'package:fyp/get.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:fyp/services/fir_service.dart';
import 'package:intl/intl.dart';

class HCDashboardPage extends StatefulWidget {
  @override
  _HCDashboardPageState createState() => _HCDashboardPageState();
}

class _HCDashboardPageState extends State<HCDashboardPage> {
  final FirService _firService = FirService();
  List<Map<String, dynamic>> _firs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firs = await _firService.getAllFirs(
        createdById: 'current-user-id', // Replace with actual user ID
      );
      setState(() {
        _firs = firs;
        _isLoading = false;
      });
    } on NetworkException catch (e) {
      setState(() {
        _error = 'Network error: ${e.message}';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = 'API error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_actions;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'CLOSED':
        return Icons.lock;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _viewFirDetails(Map<String, dynamic> fir) {
    Get.toNamed('/fir-details', arguments: fir);
  }

  Future<void> _createNewFir() async {
    final result = await Get.toNamed('/create-fir');
    if (result == true) {
      _loadData(); // Refresh the list if a new FIR was created
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'HC Dashboard'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildCard(
                              'Total Cases',
                              _firs.length.toString(),
                              Icons.folder,
                              Colors.blue,
                            ),
                            _buildCard(
                              'Pending',
                              _firs
                                  .where((fir) =>
                                      fir['status'].toString().toUpperCase() ==
                                      'PENDING')
                                  .length
                                  .toString(),
                              Icons.pending_actions,
                              Colors.orange,
                            ),
                            _buildCard(
                              'Completed',
                              _firs
                                  .where((fir) =>
                                      fir['status'].toString().toUpperCase() ==
                                      'CLOSED')
                                  .length
                                  .toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildCard(
                              'SOS Alerts',
                              _firs
                                  .where((fir) =>
                                      fir['isSos'] == true &&
                                      fir['status'].toString().toUpperCase() !=
                                          'CLOSED')
                                  .length
                                  .toString(),
                              Icons.warning,
                              Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // FIR List
                        Text(
                          'Recent Cases',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 16),
                        Card(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Case ID')),
                                DataColumn(label: Text('Title')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: _firs.map((fir) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(fir['id'] ?? 'N/A')),
                                    DataCell(Text(fir['title'] ?? 'N/A')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(fir['status']),
                                            color: _getStatusColor(fir['status']),
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(fir['status'] ?? 'N/A'),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(
                                      DateFormat('dd/MM/yy').format(
                                        DateTime.parse(fir['createdAt']),
                                      ),
                                    )),
                                    DataCell(
                                      IconButton(
                                        icon: Icon(Icons.visibility),
                                        onPressed: () => _viewFirDetails(fir),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFir,
        child: Icon(Icons.add),
        tooltip: 'Create New FIR',
      ),
    );
  }
}
