import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/services/fir_service.dart';
import 'package:intl/intl.dart';

class FirDetailsPage extends StatefulWidget {
  @override
  _FirDetailsPageState createState() => _FirDetailsPageState();
}

class _FirDetailsPageState extends State<FirDetailsPage> {
  final FirService _firService = FirService();
  late Map<String, dynamic> fir;
  bool isLoading = true;
  bool showInvestigationForm = false;
  bool showSummaryForm = false;

  final _investigationFormKey = GlobalKey<FormState>();
  final _summaryFormKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _findingsController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _summaryController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _recommendationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fir = Get.arguments;
    _loadFirDetails();
  }

  Future<void> _loadFirDetails() async {
    try {
      final updatedFir = await _firService.getFirById(fir['id']);
      setState(() {
        fir = updatedFir;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load FIR details: $e')),
      );
    }
  }

  Future<void> _submitInvestigation() async {
    if (_investigationFormKey.currentState!.validate()) {
      try {
        await _firService.createInvestigation({
          'firId': fir['id'],
          'description': _descriptionController.text,
          'findings': _findingsController.text,
          'evidence': _evidenceController.text,
          'createdById': 'current-user-id', // Replace with actual user ID
        });
        setState(() {
          showInvestigationForm = false;
          _descriptionController.clear();
          _findingsController.clear();
          _evidenceController.clear();
        });
        _loadFirDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Investigation created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create investigation: $e')),
        );
      }
    }
  }

  Future<void> _submitSummary() async {
    if (_summaryFormKey.currentState!.validate()) {
      try {
        await _firService.createFirSummary({
          'firId': fir['id'],
          'summary': _summaryController.text,
          'conclusion': _conclusionController.text,
          'recommendations': _recommendationsController.text,
          'createdById': 'current-user-id', // Replace with actual user ID
        });
        setState(() {
          showSummaryForm = false;
          _summaryController.clear();
          _conclusionController.clear();
          _recommendationsController.clear();
        });
        _loadFirDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Summary created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create summary: $e')),
        );
      }
    }
  }

  Future<void> _closeFir() async {
    try {
      await _firService.closeFir(fir['id'], 'current-user-id'); // Replace with actual user ID
      _loadFirDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FIR closed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to close FIR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('FIR Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('FIR Details'),
        actions: [
          if (fir['status'] == 'APPROVED' && !showInvestigationForm && !showSummaryForm)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  showInvestigationForm = true;
                });
              },
              tooltip: 'Add Investigation',
            ),
          if (fir['status'] == 'APPROVED' && fir['investigations']?.isNotEmpty == true && !showSummaryForm)
            IconButton(
              icon: Icon(Icons.summarize),
              onPressed: () {
                setState(() {
                  showSummaryForm = true;
                });
              },
              tooltip: 'Add Summary',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIR Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fir['title'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text('Status: ${fir['status']}'),
                    Text('Created: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(fir['createdAt']))}'),
                    Text('Description: ${fir['description']}'),
                    Text('Complainant: ${fir['complainantName']}'),
                    Text('Address: ${fir['address']}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Investigation Form
            if (showInvestigationForm)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _investigationFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Investigation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter a description' : null,
                        ),
                        TextFormField(
                          controller: _findingsController,
                          decoration: InputDecoration(labelText: 'Findings'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter findings' : null,
                        ),
                        TextFormField(
                          controller: _evidenceController,
                          decoration: InputDecoration(labelText: 'Evidence'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter evidence' : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showInvestigationForm = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _submitInvestigation,
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Summary Form
            if (showSummaryForm)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _summaryFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _summaryController,
                          decoration: InputDecoration(labelText: 'Summary'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter a summary' : null,
                        ),
                        TextFormField(
                          controller: _conclusionController,
                          decoration: InputDecoration(labelText: 'Conclusion'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter a conclusion' : null,
                        ),
                        TextFormField(
                          controller: _recommendationsController,
                          decoration: InputDecoration(labelText: 'Recommendations'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter recommendations' : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showSummaryForm = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _submitSummary,
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Investigations List
            if (fir['investigations']?.isNotEmpty ?? false) ...[
              Text(
                'Investigations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              ...fir['investigations'].map<Widget>((investigation) => Card(
                    child: ListTile(
                      title: Text(investigation['description']),
                      subtitle: Text('Status: ${investigation['status']}'),
                      trailing: Text(
                        DateFormat('dd/MM/yy').format(
                          DateTime.parse(investigation['createdAt']),
                        ),
                      ),
                    ),
                  )),
            ],

            // Summary
            if (fir['summary'] != null) ...[
              SizedBox(height: 16),
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Summary: ${fir['summary']['summary']}'),
                      Text('Conclusion: ${fir['summary']['conclusion']}'),
                      Text('Recommendations: ${fir['summary']['recommendations']}'),
                    ],
                  ),
                ),
              ),
            ],

            // Close FIR Button
            if (fir['status'] == 'APPROVED' && fir['summary'] != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _closeFir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Close FIR'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _findingsController.dispose();
    _evidenceController.dispose();
    _summaryController.dispose();
    _conclusionController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }
} 