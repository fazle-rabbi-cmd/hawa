// DateSelectionScreen.dart

import 'package:flutter/material.dart';

class DateSelectionScreen extends StatelessWidget {
  const DateSelectionScreen({super.key, required this.onDateSelected});

  final Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show date picker
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ).then((selectedDate) {
              if (selectedDate != null) {
                // Pass selected date back to the home screen
                onDateSelected(selectedDate);
              }
            });
          },
          child: Text('Pick a Date'),
        ),
      ),
    );
  }
}
