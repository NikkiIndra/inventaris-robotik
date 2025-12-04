import 'package:flutter/material.dart';

class ExportDialog extends StatefulWidget {
  final String title;
  final Function(String format) onExport;

  const ExportDialog({
    Key? key,
    required this.title,
    required this.onExport,
  }) : super(key: key);

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedFormat = 'excel';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            title: Text("Excel (.xlsx)"),
            value: "excel",
            groupValue: _selectedFormat,
            onChanged: (val) => setState(() => _selectedFormat = val!),
          ),
          RadioListTile(
            title: Text("PDF (.pdf)"),
            value: "pdf",
            groupValue: _selectedFormat,
            onChanged: (val) => setState(() => _selectedFormat = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onExport(_selectedFormat);
          },
          child: Text("Export"),
        ),
      ],
    );
  }
}
