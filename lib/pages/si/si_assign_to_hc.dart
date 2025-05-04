import 'package:flutter/material.dart';

class SIAssignToHCScreen extends StatefulWidget {
  @override
  _AssignHCScreenState createState() => _AssignHCScreenState();
}

class _AssignHCScreenState extends State<SIAssignToHCScreen> {
  int? selectedHCIndex;

  final List<Map<String, dynamic>> hcs = [
    {"name": "HC Prakash Sharma", "available": true, "cases": 2},
    {"name": "HC Anjali Verma", "available": false, "cases": 4},
    {"name": "HC Romesh Patil", "available": true, "cases": 1},
    {"name": "HC Sita Reddy", "available": true, "cases": 3},
    {"name": "HC Arun Joshi", "available": false, "cases": 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTable(),
            const SizedBox(height: 20),
            _buildHCTable(),
            const SizedBox(height: 16),
            _buildDeadlineField(),
            const SizedBox(height: 16),
            _buildInstructionField(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    final info = {
      "Title": '"Burglary at Green Street"',
      "Complaint ID": "CMP-10245",
      "Type": "Property Theft",
      "Filed Date": "2025-04-21",
      "Approved Date": "2025-04-22",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Complaint Info"),
        Table(
          border: TableBorder.all(),
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFD9E6FF)),
              children: [
                Padding(padding: EdgeInsets.all(8), child: Text("Field")),
                Padding(padding: EdgeInsets.all(8), child: Text("Data")),
              ],
            ),
            ...info.entries.map(
              (e) => TableRow(children: [_cell(e.key), _cell(e.value)]),
            ),
            TableRow(
              children: [
                _cell("Status"),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHCTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Select HC's"),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFD9E6FF)),
              children: [
                Padding(padding: EdgeInsets.all(8), child: Text("HC Name")),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Availability"),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Current Investigations"),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Select Option"),
                ),
              ],
            ),
            ...hcs.asMap().entries.map((entry) {
              final i = entry.key;
              final hc = entry.value;
              return TableRow(
                children: [
                  _cell(hc['name']),
                  Center(
                    child: Icon(
                      hc['available'] ? Icons.check_circle : Icons.cancel,
                      color: hc['available'] ? Colors.green : Colors.red,
                    ),
                  ),
                  _cell("${hc['cases']} Cases"),
                  Center(
                    child: Checkbox(
                      value: selectedHCIndex == i,
                      onChanged: (_) {
                        setState(() => selectedHCIndex = i);
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    return TextFormField(
      initialValue: "2025-05-05",
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Deadline",
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildInstructionField() {
    return const TextField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Instruction",
        hintText: "Prioritize forensic evidence collection.",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: selectedHCIndex == null ? null : () {},
          child: const Text("Assign"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Cancel"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _cell(String text) =>
      Padding(padding: const EdgeInsets.all(8), child: Text(text));

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
