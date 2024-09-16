import 'package:flutter/material.dart';

class Errorpage extends StatelessWidget {
  const Errorpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "MRT Maintanance Monitoring System",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('404 - Page Not Found. Refresh The Application.',
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
