// custom_widgets.dart
import 'package:flutter/material.dart';

// Method to build a rounded button with a specific color and label
Widget buildRoundedButton({
  required double width,
  required Color color,
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      ),
      onPressed: () {
        onPressed();
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ),
  );
}
