// ignore_for_file: unused_field

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/components/alertdialog.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:flutter_railtech/services/unauthorized_alert.dart';
import 'package:flutter_railtech/utils/utils.dart';

class Workerrecordpage extends StatefulWidget {
  final String workerName;
  const Workerrecordpage({super.key, required this.workerName});

  @override
  State<Workerrecordpage> createState() => _WorkerrecordpageState();
}

class _WorkerrecordpageState extends State<Workerrecordpage> {
  final FirestoreOperations _firestoreService = FirestoreOperations();
  Timer? _timer;

  late UnauthorizedDetectionService detectionService;
  String _helmetID = '';
  String _intersection = '';
  String _zoneName = '';

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize the detection service and start monitoring
    detectionService = UnauthorizedDetectionService(
      context: context,
      onUnauthorizedDetected: (helmetID, intersection, zoneName) {
        setState(() {
          _helmetID = helmetID;
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
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
                      final alertKey = alerts.keys
                          .elementAt(index); // Get the unique ID for each alert
                      final alert =
                          alerts[alertKey]!; // Access the corresponding alert

                      // Return each alert as a CustomAlertWidget (or whatever widget you're using)
                      return CustomAlertWidget(
                        helmetID: alert['helmetID'],
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
          const SizedBox(height: 60),
          Center(
            child: Text(
              "${widget.workerName} Records",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 50),
          StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getWorkerRecords(widget.workerName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No records available',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  final records = snapshot.data!;

                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text(
                          'Name',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Helmet ID',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Intersection',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Approve Zones',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Book In Time',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Book Out Time',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                      ],
                      rows: records.map((doc) {
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
                                style: const TextStyle(fontSize: 15),
                              ),
                            )),

                            DataCell(Text(
                              data['helmetID'].toString(),
                              style: const TextStyle(fontSize: 15),
                            )),

                            // Approve Zones - Join array into a comma-separated string
                            DataCell(Text(
                              data['intersection'] != null &&
                                      data['intersection'] is List
                                  ? (data['intersection'] as List).join(', ')
                                  : 'N/A',
                              style: const TextStyle(fontSize: 15),
                            )),

                            // Approve Zones - Join array into a comma-separated string
                            DataCell(Text(
                              data['approveZones'] != null &&
                                      data['approveZones'] is List
                                  ? (data['approveZones'] as List).join(', ')
                                  : 'N/A',
                              style: const TextStyle(fontSize: 15),
                            )),

                            // Book In Time - Convert Timestamp to readable date
                            DataCell(Text(
                              bookInTime,
                              style: const TextStyle(fontSize: 15),
                            )),

                            // Book Out Time - Check if null, else convert to readable date
                            DataCell(Text(
                              bookOutTime,
                              style: const TextStyle(fontSize: 15),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
