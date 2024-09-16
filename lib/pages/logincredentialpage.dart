import 'package:flutter/material.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';

class Logincredentialpage extends StatefulWidget {
  const Logincredentialpage({super.key});

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

  void addZone() {
    if (selectedZone != null && !approvedZones.contains(selectedZone)) {
      setState(() {
        approvedZones.add(selectedZone!);
        selectedZones.add(selectedZone!);
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
        approvedIntersections.add(selectedIntersection!);
        selectedIntersections.add(selectedIntersection!);
      });
    }
  }

  void removeIntersection(String intersection) {
    setState(() {
      approvedIntersections.remove(intersection);
      selectedIntersections.remove(intersection);
    });
  }

  void submitForm() {
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

      // Perform Firestore operations here, like adding the worker entry to Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Worker Entry Form",
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
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                );
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
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      // First dropdown for lines
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Select Line'),
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
                            labelText: 'Select Intersection'),
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
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                            ),
                            onPressed: addIntersection,
                            child: const Text(
                                'Add Intersection to Approve Table',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
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
                                  onPressed: () =>
                                      removeIntersection(intersection),
                                ),
                              );
                            }),
                          ],
                        ),
                      const SizedBox(height: 40),

                      // Third dropdown for zones
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Select Zone'),
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
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                            ),
                            onPressed: addZone,
                            child: const Text('Add Zone to Approve Table',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Display approved zones
                      if (approvedZones.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Approved Zones:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              ...approvedZones.map((zone) {
                                return ListTile(
                                  title: Text(zone),
                                  trailing: IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => removeZone(zone),
                                  ),
                                );
                              }),
                            ]),
                      const SizedBox(height: 40),

                      // Input field for helmet ID
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Helmet ID'),
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
                        decoration:
                            const InputDecoration(labelText: 'Worker Name'),
                        onSaved: (value) => workerName = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Worker Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Submit button
                      Center(
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                            ),
                            onPressed: submitForm,
                            child: const Text('Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
