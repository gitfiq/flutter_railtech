// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_railtech/components/alertdialog.dart';
import 'package:flutter_railtech/components/drawer.dart';
import 'package:flutter_railtech/components/mrt_line_button_homepage.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:flutter_railtech/services/unauthorized_alert.dart';
import 'package:flutter_railtech/utils/utils.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  late DateTime now;
  late String formattedTime;
  String _displayText = 'East-West Line'; // Initial text
  List<Map<String, dynamic>> documents = [];
  final FirestoreOperations _firestoreService = FirestoreOperations();
  late Stream<List<Map<String, dynamic>>> _stream;
  Timer? _timer;

  late UnauthorizedDetectionService detectionService;
  String _helmetID = '';
  String _intersection = '';
  String _zoneName = '';

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    formattedTime = DateFormat('dd/MM/yyyy, HH:mm').format(now);
    updateText('EW-Line');
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
        _stream = _firestoreService
            .getMRTStationsStream(_displayTextToCollection(_displayText));
        detectionService.monitorUnauthorizedEntries();
      });
    });
  }

  void updateText(String text) async {
    // Update the stream to listen to real-time changes
    setState(() {
      _stream = _firestoreService.getMRTStationsStream(text);
      _displayText = _mapLineToDisplayText(text);
    });
  }

  String _displayTextToCollection(String displayText) {
    switch (displayText) {
      case 'East-West Line':
        return 'EW-Line';
      case 'North-South Line':
        return 'NS-Line';
      case 'North-East Line':
        return 'NE-Line';
      case 'Circle Line':
        return 'C-Line';
      case 'Downtown Line':
        return 'D-Line';
      case 'Thomson-East Coast Line':
        return 'TEC-Line';
      default:
        return 'EW-Line';
    }
  }

  String _mapLineToDisplayText(String line) {
    switch (line) {
      case 'EW-Line':
        return 'East-West Line';
      case 'NS-Line':
        return 'North-South Line';
      case 'NE-Line':
        return 'North-East Line';
      case 'C-Line':
        return 'Circle Line';
      case 'D-Line':
        return 'Downtown Line';
      default:
        return 'Thomson-East Coast Line';
    }
  }

  String getOverallStatus(List<Map<String, dynamic>> documents) {
    // Check if any document has a numberOfWorkers greater than 0
    bool isReady = documents.every((doc) {
      final data = doc['data'] as Map<String, dynamic>;
      final int numOfPeople = data['numberOfWorkers'] ?? 0;
      return numOfPeople == 0;
    });

    return isReady ? 'Ready' : 'Not Ready';
  }

  Color getStatusColor(String status) {
    return status == 'Ready' ? Colors.green : Colors.red;
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
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
                    // final latestAlert = alerts.values.first;
                    // return CustomAlertWidget(
                    //   helmetID: latestAlert['helmetID'],
                    //   intersection: latestAlert['intersection'],
                    //   zoneName: latestAlert['zoneName'],
                    // );

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
                  showEnlargedImage(context, 'images/mrtmap.jpg');
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.60,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Container(
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: const DecorationImage(
                      image: AssetImage('images/mrtmap.jpg'),
                      fit: BoxFit
                          .fitHeight, // Ensures the image covers the container
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Singapore MRT Map",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildRoundedButton(
                      width: MediaQuery.of(context).size.width * 0.14,
                      color: Colors.green,
                      label: 'East-West Line',
                      onPressed: () => updateText('EW-Line')),
                  buildRoundedButton(
                      width: MediaQuery.of(context).size.width * 0.14,
                      color: Colors.red,
                      label: 'North-South Line',
                      onPressed: () => updateText('NS-Line')),
                  buildRoundedButton(
                      width: MediaQuery.of(context).size.width * 0.14,
                      color: Colors.purple,
                      label: 'North-East Line',
                      onPressed: () => updateText('NE-Line')),
                  buildRoundedButton(
                      width: MediaQuery.of(context).size.width * 0.14,
                      color: Colors.orange,
                      label: 'Circle Line',
                      onPressed: () => updateText('C-Line')),
                  buildRoundedButton(
                      width: MediaQuery.of(context).size.width * 0.14,
                      color: Colors.blue,
                      label: 'Downtown Line',
                      onPressed: () => updateText('D-Line')),
                  buildRoundedButton(
                    width: MediaQuery.of(context).size.width * 0.14,
                    color: Colors.brown,
                    label: 'Thomson-East Coast Line',
                    onPressed: () => updateText('TEC-Line'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _displayText,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ));
                } else {
                  final status = getOverallStatus(snapshot.data!);
                  final statusColor = getStatusColor(status);

                  return Column(
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: statusColor),
                      ),
                      const SizedBox(height: 25),
                      DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Station Name",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                              label: Text(
                            "Number Of People",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Status",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Last Updated",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))
                        ],
                        rows: snapshot.data!.map((doc) {
                          final data = doc['data'] as Map<String, dynamic>;

                          final String formattedDate =
                              DateFormat('HH:mm, dd/MM/yyyy')
                                  .format(DateTime.now());

                          // Determine the status based on the number of people
                          final int numOfPeople = data['numberOfWorkers'] ?? 0;
                          final String statusText =
                              numOfPeople > 0 ? 'Not Ready' : 'Ready';
                          final Color statusColor =
                              numOfPeople > 0 ? Colors.red : Colors.green;

                          return DataRow(cells: [
                            DataCell(InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: {
                                    'stationName': doc['documentName']
                                  },
                                );
                              },
                              child: Text(
                                removePrefix(doc['documentName']),
                                style: const TextStyle(fontSize: 15),
                              ),
                            )), // Document ID
                            DataCell(Text(
                              numOfPeople.toString(),
                              style: const TextStyle(fontSize: 15),
                            )),
                            DataCell(
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 15),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ],
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
