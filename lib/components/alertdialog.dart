import 'package:flutter/material.dart';

class CustomAlertWidget extends StatelessWidget {
  final String helmetID;
  final String intersection;
  final String zoneName;

  const CustomAlertWidget({
    super.key,
    required this.helmetID,
    required this.intersection,
    required this.zoneName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: const Text('Unauthorized Entry Detected'),
        subtitle: Text(
          'Helmet ID: $helmetID\nIntersection: $intersection\nZone: $zoneName',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        tileColor: Colors.red[100],
      ),
    );
  }
}
