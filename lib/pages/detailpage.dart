// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_railtech/components/alertdialog.dart';
import 'package:flutter_railtech/components/mrt_line_button_homepage.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:flutter_railtech/services/unauthorized_alert.dart';
import 'package:flutter_railtech/utils/utils.dart';

class Detailpage extends StatefulWidget {
  final String stationName;

  const Detailpage({super.key, required this.stationName});

  @override
  State<Detailpage> createState() => DetailpageState();
}

class DetailpageState extends State<Detailpage> {
  final FirestoreOperations _firestoreService = FirestoreOperations();
  bool showOnTrack = true;
  String? selectedZone;
  Timer? _timer;

  late UnauthorizedDetectionService detectionService;
  String _helmetID = '';
  String _intersection = '';
  String _zoneName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaultZone();
    });
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

  String _getImagePath(String stationName) {
    final String prefix = stationName.substring(0, 2);
    switch (prefix) {
      case 'EW':
        return 'images/eastwest.jpg';
      case 'NS':
        return 'images/northsouth.jpg';
      case 'NE':
        return 'images/northeast.jpg';
      case 'C':
        return 'images/circle.jpg';
      case 'D':
        return 'images/downtown.jpg';
      case 'TEC':
        return 'images/thomsoneastcoast.jpg';
      default:
        return 'images/imagenotfound.jpg';
    }
  }

  void _initializeDefaultZone() async {
    // Fetch zone names
    final zones =
        await _firestoreService.getZoneNames(widget.stationName).first;

    if (zones.isNotEmpty) {
      setState(() {
        selectedZone = zones.first;
      });
    }
  }

  void _selectZone(String zone) {
    setState(() {
      selectedZone = zone;
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
      body: SingleChildScrollView(
        child: Column(
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
                        final alertKey = alerts.keys.elementAt(
                            index); // Get the unique ID for each alert
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
              child: GestureDetector(
                onTap: () {
                  showEnlargedImage(context, _getImagePath(widget.stationName));
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: Container(
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: AssetImage(_getImagePath(widget.stationName)),
                      fit: BoxFit
                          .fitHeight, // Ensures the image covers the container
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                removePrefix(widget.stationName),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
            StreamBuilder<List<String>>(
              stream: _firestoreService.getZoneNames(widget.stationName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No zones available',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                } else {
                  final List<String> zones = snapshot.data!;

                  // If no zone is selected, set the first zone as the default
                  if (selectedZone == null && zones.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        selectedZone = zones.first;
                      });
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: zones.map((zone) {
                        return SizedBox(
                          height: 60,
                          child: buildRoundedButton(
                            width: MediaQuery.of(context).size.width * 0.14,
                            color: Colors.black,
                            label: zone, // Use zone name as label
                            onPressed: () {
                              _selectZone(zone);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Text(
              selectedZone ?? 'Select a Zone',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              showOnTrack ? 'On the Track' : 'Not On the Track',
              style: TextStyle(
                fontSize: 25,
                color: showOnTrack ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                    ),
                    onPressed: () {
                      setState(() {
                        showOnTrack = true;
                      });
                    },
                    child: const Text(
                      'On Track',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                    ),
                    onPressed: () {
                      setState(() {
                        showOnTrack = false;
                      });
                    },
                    child: const Text(
                      'Not On Track',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: selectedZone != null
                  ? _firestoreService.getUsersDetected(
                      widget.stationName, selectedZone!, showOnTrack)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    'No users detected in this zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ));
                } else {
                  final document = snapshot.data!;

                  return DataTable(
                    columns: const [
                      DataColumn(
                          label: Text(
                        'Helmet ID',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Entry Time',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Exit Time',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: document.map((doc) {
                      final data = doc['data'] as Map<String, dynamic>;
                      // Convert Timestamp to DateTime and format it
                      final entryTime = formatTimestamp(data['entryTime']);
                      final exitTime = formatTimestamp(data['exitTime']);

                      return DataRow(cells: [
                        DataCell(Text(
                          doc['documentName'],
                          style: const TextStyle(fontSize: 15),
                        )),
                        DataCell(Text(
                          entryTime,
                          style: const TextStyle(fontSize: 15),
                        )),
                        DataCell(Text(
                          exitTime,
                          style: const TextStyle(fontSize: 15),
                        )),
                      ]);
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
