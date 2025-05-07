import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SICaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const SICaseDetailsScreen({
    Key? key,
    required this.caseData,
  }) : super(key: key);

  @override
  _SICaseDetailsScreenState createState() => _SICaseDetailsScreenState();
}

class _SICaseDetailsScreenState extends State<SICaseDetailsScreen> {
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationCard(Map<String, dynamic> investigation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investigation #${investigation['id']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(investigation['date'] ?? ''),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Officer', investigation['officer'] ?? ''),
            _buildDetailRow('Findings', investigation['findings'] ?? ''),
            if (investigation['evidence'] != null && investigation['evidence'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Evidence:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: (investigation['evidence'] as List).map((evidence) {
                      return Chip(
                        label: Text(evidence['type'] ?? ''),
                        avatar: const Icon(Icons.attachment, size: 16),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Case Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.caseData['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(widget.caseData['status'] ?? ''),
                            backgroundColor: Colors.blue[100],
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(widget.caseData['complaintType'] ?? ''),
                            backgroundColor: Colors.green[100],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  'Case Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow('Description', widget.caseData['description'] ?? ''),
                        _buildDetailRow('Incident Date', _formatDate(widget.caseData['incidentDate'] ?? '')),
                        _buildDetailRow('Incident Address', widget.caseData['incidentAddress'] ?? ''),
                        _buildDetailRow('Category', widget.caseData['category'] ?? ''),
                        _buildDetailRow('Assigned To', widget.caseData['assignedTo'] ?? ''),
                        _buildDetailRow('Assigned Date', _formatDate(widget.caseData['assignedDate'] ?? '')),
                        _buildDetailRow('Approved Date', _formatDate(widget.caseData['approvedDate'] ?? '')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text(
                  'Complainant Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow('Name', widget.caseData['complainantName'] ?? ''),
                        _buildDetailRow('Gender', widget.caseData['complainantGender'] ?? ''),
                        _buildDetailRow('Mobile', widget.caseData['complainantMobile'] ?? ''),
                        _buildDetailRow('Email', widget.caseData['complainantEmail'] ?? ''),
                        _buildDetailRow('Address', widget.caseData['complainantAddress'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text(
                  'Investigations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (widget.caseData['investigations'] != null &&
                            (widget.caseData['investigations'] as List).isNotEmpty)
                          ...(widget.caseData['investigations'] as List)
                              .map((investigation) => _buildInvestigationCard(investigation))
                              .toList()
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No investigations recorded yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text(
                  'Case Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow('Created At', _formatDate(widget.caseData['createdAt'] ?? '')),
                        if (widget.caseData['approvedDate'] != null)
                          _buildDetailRow('Approved At', _formatDate(widget.caseData['approvedDate'] ?? '')),
                        if (widget.caseData['closedDate'] != null)
                          _buildDetailRow('Closed At', _formatDate(widget.caseData['closedDate'] ?? '')),
                        if (widget.caseData['notes'] != null &&
                            widget.caseData['notes'].toString().isNotEmpty)
                          _buildDetailRow('Notes', widget.caseData['notes'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 