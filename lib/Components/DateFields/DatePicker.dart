import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime>? onDateSelected;

  const DatePickerField({
    super.key,
    required this.label,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateSelected,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = _clampToRange(widget.initialDate);
  }

  DateTime _clampToRange(DateTime date) {
    if (date.isBefore(widget.firstDate)) return widget.firstDate;
    if (date.isAfter(widget.lastDate)) return widget.lastDate;
    return date;
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampToRange(selectedDate),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: widget.label,
                suffixIcon: const Icon(Icons.calendar_month),
                filled: true,
                fillColor: Colors.grey.shade900,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade900, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade900, width: 2),
                ),
              ),
              child: Text(
                formatDate(selectedDate),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
