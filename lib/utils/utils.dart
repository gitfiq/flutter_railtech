import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String removePrefix(String name) {
  // List of possible prefixes to remove
  final prefixes = ['EW-', 'NS-', 'NE-', 'C-', 'D-', 'TEC-'];

  for (var prefix in prefixes) {
    if (name.startsWith(prefix)) {
      return name.replaceFirst(prefix, '');
    }
  }
  return name;
}

void showEnlargedImage(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    },
  );
}

String formatTimestamp(dynamic timestamp) {
  if (timestamp == null) {
    return 'N/A';
  }

  // Convert Timestamp to DateTime
  final DateTime dateTime = (timestamp is Timestamp)
      ? timestamp.toDate()
      : (timestamp is DateTime)
          ? timestamp
          : DateTime.now();

  // Define the specific placeholder date/time to check
  final DateTime placeholderDateTime = DateTime(1988, 3, 12, 0, 0);

  // Check if the dateTime is equal to the placeholderDateTime
  if (dateTime.year == placeholderDateTime.year &&
      dateTime.month == placeholderDateTime.month &&
      dateTime.day == placeholderDateTime.day &&
      dateTime.hour == placeholderDateTime.hour &&
      dateTime.minute == placeholderDateTime.minute) {
    return 'N/A';
  }

  // Format the DateTime
  final DateFormat formatter = DateFormat('HH:mm, dd/MM/yyyy');
  return formatter.format(dateTime);
}
