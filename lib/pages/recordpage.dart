// ignore_for_file: unused_field

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/components/alertdialog.dart';
import 'package:flutter_railtech/components/drawer.dart';
import 'package:flutter_railtech/components/mrt_line_button_homepage.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:flutter_railtech/services/unauthorized_alert.dart';
import 'package:flutter_railtech/utils/utils.dart';

class Recordpage extends StatefulWidget {
  const Recordpage({super.key});

  @override
  State<Recordpage> createState() => _RecordpageState();
}

class _RecordpageState extends State<Recordpage> {
  String? selectedPrefix;
  final FirestoreOperations _firestoreService = FirestoreOperations();
  Timer? _timer;

  late UnauthorizedDetectionService detectionService;
  String _helmetID = '';
  String _name = '';
  String _intersection = '';
  String _zoneName = '';

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize the detection service and start monitoring
    detectionService = UnauthorizedDetectionService(
      context: context,
      onUnauthorizedDetected: (helmetID, name, intersection, zoneName) {
        setState(() {
          _helmetID = helmetID;
          _name = name;
          _intersection = intersection;
          _zoneName = zoneName;
        });
      },
    );
    detectionService.monitorUnauthorizedEntries();
  }

  @override
  void dispose() {
    _timer?.cancel();
    detectionService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      setState(() {
        detectionService.monitorUnauthorizedEntries();
      });
    });
  }

  Widget _buildFilterButtons() {
    const lines = [
      {
        "label": "All",
        "prefix": null,
        "color": Color.fromARGB(255, 241, 62, 214)
      },
      {
        "label": "East-West Line",
        "prefix": "EW",
        "color": Color.fromARGB(255, 5, 135, 9)
      },
      {"label": "North-South Line", "prefix": "NS", "color": Colors.red},
      {"label": "North-East Line", "prefix": "NE", "color": Colors.purple},
      {"label": "Circle Line", "prefix": "C", "color": Colors.orange},
      {"label": "Downtown Line", "prefix": "D", "color": Colors.blue},
      {
        "label": "Thomson-East Coast Line",
        "prefix": "T",
        "color": Colors.brown
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: lines.map((line) {
        return SizedBox(
          height: 60,
          child: buildRoundedButton(
              width: MediaQuery.of(context).size.width * 0.10,
              color: line['color'] as Color,
              label: line['label'] as String,
              onPressed: () {
                setState(() {
                  selectedPrefix = line['prefix'] as String?;
                });
              },
              fontsize: 18),
        );
      }).toList(),
    );
  }

  String getBookInStatus(List<Map<String, dynamic>> documents) {
    // Check if any document has a numberOfWorkers greater than 0
    bool isBookIn = documents.every((doc) {
      final data = doc['data'] as Map<String, dynamic>;
      final bool bookInStatus = data['bookIn'] ?? false;
      return bookInStatus == false;
    });

    return isBookIn ? 'Book Out' : 'Book In';
  }

  Color getBookInStatusColor(String status) {
    return status == 'Book In'
        ? const Color.fromARGB(255, 5, 135, 9)
        : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 145, 232),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "TrackSafe System",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                );
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            StreamBuilder<Map<String, dynamic>>(
              stream: detectionService.unauthorizedStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final alerts = snapshot.data!;
                  if (alerts.isEmpty) {
                    return Container(); // No active alerts
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alertKey = alerts.keys.elementAt(
                            index); // Get the unique ID for each alert
                        final alert =
                            alerts[alertKey]!; // Access the corresponding alert

                        // Return each alert as a CustomAlertWidget (or whatever widget you're using)
                        return CustomAlertWidget(
                          helmetID: alert['helmetID'],
                          name: alert['name'],
                          intersection: alert['intersection'],
                          zoneName: alert['zoneName'],
                        );
                      },
                    );
                  }
                } else {
                  return Container();
                }
              },
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Personnel Record (Book-In/ Book-Out)",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            _buildFilterButtons(),
            const SizedBox(height: 40),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getWorkersByLine(selectedPrefix),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Column(
                    children: [
                      SizedBox(height: 150),
                      Center(
                          child: Text(
                        "No data available.",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                    ],
                  );
                } else {
                  final workers = snapshot.data!;
                  final bookInStatus = getBookInStatus(snapshot.data!);
                  final bookInStatusColor = getBookInStatusColor(bookInStatus);

                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text(
                          'Personnel',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Helmet ID',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Intersection',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Approved Zones',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Time-In',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Time-Out',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ],
                      rows: workers.map((doc) {
                        final data = doc['data'] ?? {};

                        final bookInTime =
                            formatTimestamp(data['entryTime'] as Timestamp?);
                        final bookOutTime =
                            formatTimestamp(data['exitTime'] as Timestamp?);

                        return DataRow(
                          cells: [
                            DataCell(InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/workersrecord',
                                  arguments: {
                                    'workerName': doc['documentName']
                                  },
                                );
                              },
                              child: Text(
                                data['name'] ?? 'N/A',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            )),

                            DataCell(Text(
                              data['helmetID'].toString(),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            )),

                            DataCell(Text(
                              data['intersection'] != null &&
                                      data['intersection'] is List
                                  ? (data['intersection'] as List).join(', ')
                                  : 'N/A',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            )),

                            // Approve Zones - Join array into a comma-separated string
                            DataCell(ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 300,
                              ),
                              child: Text(
                                data['approveZones'] != null &&
                                        data['approveZones'] is List
                                    ? (data['approveZones'] as List).join(', ')
                                    : 'N/A',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            )),

                            // Book In Status
                            DataCell(Text(
                              bookInStatus,
                              style: TextStyle(
                                  fontSize: 18, color: bookInStatusColor),
                            )),

                            // Book In Time - Convert Timestamp to readable date
                            DataCell(ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 100,
                              ),
                              child: Text(
                                bookInTime,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            )),

                            // Book Out Time - Check if null, else convert to readable date
                            // Book In Time - Convert Timestamp to readable date
                            DataCell(ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 100,
                              ),
                              child: Text(
                                bookInStatus == 'Book In' ? 'N/A' : bookOutTime,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
