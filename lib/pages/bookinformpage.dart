// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_railtech/services/auth_service.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:flutter_railtech/utils/utils.dart';

class Logincredentialpage extends StatefulWidget {
  final String email;

  const Logincredentialpage({super.key, required this.email});

  @override
  State<Logincredentialpage> createState() => _LogincredentialpageState();
}

class _LogincredentialpageState extends State<Logincredentialpage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirestoreOperations _firestoreService = FirestoreOperations();

  // Variables to hold selected values
  String? selectedLine;
  //String? selectedStation;
  String? selectedIntersection;
  String? selectedZone;
  String? helmetID;
  String? workerName;
  bool isLoading = true;
  bool bookIn = false; // Track bookIn status
  Map<String, dynamic>? workerData;

  List<String> lines = [
    'EW-Line',
    'NS-Line',
    'NE-Line',
    'C-Line',
    'D-Line',
    'TEC-Line',
  ];

  //List<String> stations = [];
  List<String> zones = [];
  List<String> intersections = [];

  // List to store selected zones and intersections
  List<String> selectedZones = [];
  List<String> selectedIntersections = [];

  // Approve table to store selected zones and intersections
  List<String> approvedZones = [];
  List<String> approvedIntersections = [];

  @override
  void initState() {
    super.initState();
    _checkBookInStatus();
  }

  Future<void> _checkBookInStatus() async {
    workerData = (await _firestoreService.getUserData(widget.email))
        as Map<String, dynamic>?;
    if (workerData != null && workerData!['bookIn'] == true) {
      setState(() {
        bookIn = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void bookOut() async {
    try {
      await _firestoreService.bookOutWorker(
        email: widget.email,
        userData: workerData!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully booked out!')),
      );

      setState(() {
        bookIn = false; // Update UI after book out
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking out: $e')),
      );
    }
  }

  void addZone() {
    if (selectedZone != null && !approvedZones.contains(selectedZone)) {
      setState(() {
        approvedZones.add(selectedZone!.trim());
        selectedZones.add(selectedZone!.trim());
      });
    }
  }

  void removeZone(String zone) {
    setState(() {
      approvedZones.remove(zone);
      selectedZones.remove(zone); // Remove from array
    });
  }

  void addIntersection() {
    if (selectedIntersection != null &&
        !approvedIntersections.contains(selectedIntersection)) {
      setState(() {
        approvedIntersections.add(selectedIntersection!.trim());
        selectedIntersections.add(selectedIntersection!.trim());
      });
    }
  }

  void removeIntersection(String intersection) {
    setState(() {
      approvedIntersections.remove(intersection);
      selectedIntersections.remove(intersection);
    });
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if at least one intersection and one zone are added
      if (approvedIntersections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Please add at least one intersection!',
                style: TextStyle(color: Colors.white),
              )),
        );
        return;
      }

      if (approvedZones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Please add at least one zone!',
                  style: TextStyle(color: Colors.white))),
        );
        return;
      }

      _formKey.currentState!.save();

      try {
        await _firestoreService.saveWorkerData(
          email: widget.email,
          approveZones: approvedZones,
          approveIntersections: approvedIntersections,
          helmetID: int.parse(helmetID!),
          name: workerName!,
        );

        await _firestoreService.updateHelmetID(
          approveZones: approvedZones,
          approveIntersections: approvedIntersections,
          helmetID: int.parse(helmetID!),
          name: workerName!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );

        setState(() {
          _checkBookInStatus();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 145, 232),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Personnel Entry Form",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await AuthService().signout(context: context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.60,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: bookIn ? _buildBookOutUI() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookOutUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            'Personnel Name: ${workerData!['name']}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(
            'Helmet ID: ${workerData!['helmetID']}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(
            'Entry Time: ${formatTimestamp(workerData!['entryTime'])}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),

          // Display intersections in a table
          if (workerData!['intersection'] != null &&
              (workerData!['intersection'] as List).isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Intersection',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                  rows: (workerData!['intersection'] as List<dynamic>)
                      .map((intersection) {
                    return DataRow(cells: [
                      DataCell(Text(
                        intersection as String,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      )),
                    ]);
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),

          // Display zones in a table
          if (workerData!['approveZones'] != null &&
              (workerData!['approveZones'] as List).isNotEmpty)
            Column(
              children: [
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Zone',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                  rows: (workerData!['approveZones'] as List<dynamic>)
                      .map((zone) {
                    return DataRow(cells: [
                      DataCell(Text(
                        zone as String,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      )),
                    ]);
                  }).toList(),
                ),
                const SizedBox(height: 50),
              ],
            ),

          //Book out button
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.15,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              ),
              onPressed: bookOut,
              child: const Text('Book Out',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // First dropdown for lines
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Line',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            value: selectedLine,
            items: lines.map((line) {
              return DropdownMenuItem(
                value: line,
                child: Text(line),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLine = value;
                _firestoreService
                    .fetchIntersections(value!)
                    .then((intersectionList) {
                  setState(() {
                    intersections = intersectionList;
                    selectedIntersection = null;
                    selectedZone = null;
                    zones = [];
                  });
                });
              });
            },
            validator: (value) {
              if (value == null) return 'Please select a line';
              return null;
            },
          ),
          const SizedBox(height: 40),

          // Second dropdown for stations
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Intersection',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            value: selectedIntersection,
            items: intersections.map((intersection) {
              return DropdownMenuItem(
                value: intersection,
                child: Text(intersection),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedIntersection = value;
                _firestoreService
                    .fetchZones(selectedLine!, value!)
                    .then((zoneList) {
                  setState(() {
                    zones = zoneList;
                    selectedZone = null;
                  });
                });
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a intersection';
              }
              return null;
            },
          ),
          const SizedBox(height: 35),

          // Button to add intersection to the list
          Center(
            child: SizedBox(
              height: 50,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 129, 196, 229),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                ),
                onPressed: addIntersection,
                child: const Text('Add Intersection to Approve Table',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Display approved intersections
          if (approvedIntersections.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Approved Intersections:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...approvedIntersections.map((intersection) {
                  return ListTile(
                    title: Text(intersection),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => removeIntersection(intersection),
                    ),
                  );
                }),
              ],
            ),
          const SizedBox(height: 40),

          // Third dropdown for zones
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Zone',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            value: selectedZone,
            items: zones.map((zone) {
              return DropdownMenuItem(
                value: zone,
                child: Text(zone),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedZone = value;
              });
            },
            validator: (value) {
              if (value == null) return 'Please select a zone';
              return null;
            },
          ),
          const SizedBox(height: 35),
          Center(
            child: SizedBox(
              height: 50,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 129, 196, 229),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                ),
                onPressed: addZone,
                child: const Text('Add Zone to Approve Table',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Display approved zones
          if (approvedZones.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Approved Zones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...approvedZones.map((zone) {
                return ListTile(
                  title: Text(zone),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => removeZone(zone),
                  ),
                );
              }),
            ]),
          const SizedBox(height: 40),

          // Input field for helmet ID
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Helmet ID',
              labelStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onSaved: (value) => helmetID = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Helmet ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // Input field for worker name
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Personnel Name',
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            onSaved: (value) => workerName = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // Submit button
          Center(
            child: SizedBox(
              height: 50,
              width: 170,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                ),
                onPressed: submitForm,
                child: const Text('Submit',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
