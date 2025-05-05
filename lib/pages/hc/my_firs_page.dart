import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/services/fir_service.dart';
import 'package:fyp/get.dart';
import 'package:intl/intl.dart';

class MyFirsPage extends StatefulWidget {
  @override
  _MyFirsPageState createState() => _MyFirsPageState();
}

class _MyFirsPageState extends State<MyFirsPage> {
  final FirService _firService = FirService();
  final AppController _authController = Get.find<AppController>();
  List<Map<String, dynamic>> _firs = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'ALL';
  String _selectedSortBy = 'DATE_DESC';
  String _searchQuery = '';

  final List<String> _statuses = ['ALL', 'PENDING', 'APPROVED', 'REJECTED', 'CLOSED'];
  final Map<String, String> _sortOptions = {
    'DATE_DESC': 'Newest First',
    'DATE_ASC': 'Oldest First',
    'TITLE_ASC': 'Title (A-Z)',
    'TITLE_DESC': 'Title (Z-A)',
    'STATUS_ASC': 'Status (A-Z)',
    'STATUS_DESC': 'Status (Z-A)',
  };

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
        createdById: _authController.userInfo['id'],
        status: _selectedStatus == 'ALL' ? null : _selectedStatus,
      );
      setState(() {
        _firs = _sortFirs(firs);
        _isLoading = false;
      });
    } on NetworkException catch (e) {
      setState(() {
        _error = 'Network error: ${e.message}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.message}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _error = 'API error: ${e.message}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API error: ${e.message}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _sortFirs(List<Map<String, dynamic>> firs) {
    final filteredFirs = _searchQuery.isEmpty
        ? firs
        : firs.where((fir) {
            final title = fir['title']?.toString().toLowerCase() ?? '';
            final description = fir['description']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || description.contains(query);
          }).toList();

    switch (_selectedSortBy) {
      case 'DATE_DESC':
        filteredFirs.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));
        break;
      case 'DATE_ASC':
        filteredFirs.sort((a, b) => DateTime.parse(a['createdAt'])
            .compareTo(DateTime.parse(b['createdAt'])));
        break;
      case 'TITLE_ASC':
        filteredFirs.sort((a, b) =>
            (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString()));
        break;
      case 'TITLE_DESC':
        filteredFirs.sort((a, b) =>
            (b['title'] ?? '').toString().compareTo((a['title'] ?? '').toString()));
        break;
      case 'STATUS_ASC':
        filteredFirs.sort((a, b) =>
            (a['status'] ?? '').toString().compareTo((b['status'] ?? '').toString()));
        break;
      case 'STATUS_DESC':
        filteredFirs.sort((a, b) =>
            (b['status'] ?? '').toString().compareTo((a['status'] ?? '').toString()));
        break;
    }

    return filteredFirs;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My FIRs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Get.toNamed('/create-fir');
              if (result == true) {
                _loadData();
              }
            },
            tooltip: 'Create New FIR',
          ),
        ],
      ),
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
              : Column(
                  children: [
                    // Search and Filter Bar
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search FIRs...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _firs = _sortFirs(_firs);
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _statuses.map((String status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedStatus = newValue;
                                      });
                                      _loadData();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSortBy,
                                  decoration: InputDecoration(
                                    labelText: 'Sort By',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _sortOptions.entries.map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedSortBy = newValue;
                                        _firs = _sortFirs(_firs);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // FIR List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: _firs.isEmpty
                            ? Center(
                                child: Text(
                                  'No FIRs found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _firs.length,
                                itemBuilder: (context, index) {
                                  final fir = _firs[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        fir['title'] ?? 'Untitled',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fir['description'] ?? 'No description',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                _getStatusIcon(fir['status']),
                                                color: _getStatusColor(fir['status']),
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(fir['status'] ?? 'N/A'),
                                              SizedBox(width: 16),
                                              Icon(Icons.calendar_today, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                DateFormat('dd/MM/yy').format(
                                                  DateTime.parse(fir['createdAt']),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.chevron_right),
                                        onPressed: () => _viewFirDetails(fir),
                                      ),
                                      onTap: () => _viewFirDetails(fir),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 