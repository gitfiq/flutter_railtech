import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreOperations {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a real-time stream of MRT stations on the lines
  Stream<List<Map<String, dynamic>>> getMRTStationsStream(
      String collectionPath) {
    return _db
        .collection(collectionPath)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> stationData = [];

      for (var doc in snapshot.docs) {
        String stationName = doc.id;
        int workerCount = await getTotalWorkersOnTrack(stationName);

        stationData.add({
          'documentName': stationName,
          'data': {
            'numberOfWorkers': workerCount,
          },
        });
      }
      return stationData;
    });
  }

  // Count workers with onTrack == true in the Users Detected collection for each station
  Future<int> getTotalWorkersOnTrack(String stationName) async {
    int totalCount = 0;

    QuerySnapshot zoneSnapshot = await _db
        .collection('EW-Line')
        .doc(stationName)
        .collection('zones')
        .get();

    for (var zoneDoc in zoneSnapshot.docs) {
      QuerySnapshot userSnapshot = await zoneDoc.reference
          .collection('Users Detected')
          .where('onTrack', isEqualTo: true)
          .get();

      totalCount += userSnapshot.docs.length;
    }

    return totalCount;
  }

  // Fetch zone names from the Firestore structure
  Stream<List<String>> getZoneNames(String stationName) {
    // Reference the correct path based on stationName
    return _db
        .collection('EW-Line')
        .doc(stationName)
        .collection('zones')
        .snapshots()
        .map((snapshot) {
      // Return the document IDs (zone names)
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Get users detected based on selected zone and track status
  Stream<List<Map<String, dynamic>>> getUsersDetected(
      String stationName, String selectedZone, bool onTrack) {
    return _db
        .collection('EW-Line')
        .doc(stationName)
        .collection('zones')
        .doc(selectedZone)
        .collection('Users Detected')
        .where('onTrack', isEqualTo: onTrack)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'documentName': doc.id,
          'data': doc.data(),
        };
      }).toList();
    });
  }

  // Stream<List<Map<String, dynamic>>> getWorkersByLine(String? linePrefix) {
  //   // Reference the "Users" collection
  //   CollectionReference usersCollection = _db.collection('Users');

  //   // If no linePrefix is provided (for "All" button), return all workers
  //   if (linePrefix == null) {
  //     return usersCollection
  //         .orderBy('entryTime', descending: true)
  //         .snapshots()
  //         .map((snapshot) {
  //       return snapshot.docs.map((doc) {
  //         // Safeguard by checking if data is not null
  //         return {
  //           'documentName': doc.id,
  //           'data': doc.data(),
  //         };
  //       }).toList();
  //     });
  //   }

  //   // Filter users by line prefix in their "intersection" field
  //   return usersCollection.orderBy('intersection').snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return {
  //         'documentName': doc.id,
  //         'data': doc.data(),
  //       };
  //     }).toList();
  //   });
  // }

  // Get a stream of worker documents filtered by MRT line prefix
  Stream<List<Map<String, dynamic>>> getWorkersByLine(String? linePrefix) {
    // Reference the "Users" collection
    CollectionReference usersCollection = _db.collection('Users');

    // If no linePrefix is provided (for "All" button), return all workers
    if (linePrefix == null) {
      return usersCollection
          .orderBy('entryTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'documentName': doc.id,
            'data': doc.data(),
          };
        }).toList();
      });
    }

    // Get the workers and filter them based on the line prefix
    return usersCollection
        .orderBy('entryTime', descending: true) // You can order as needed
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        // Ensure 'intersection' is treated as a list
        List<dynamic> intersections = doc['intersection'];

        // Check if any intersection starts with the linePrefix
        return intersections.any(
            (intersection) => intersection.toString().startsWith(linePrefix));
      }).map((doc) {
        return {
          'documentName': doc.id,
          'data': doc.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getWorkerRecords(String workerName) {
    return _db
        .collection('Users')
        .doc(workerName)
        .collection('Records')
        .orderBy("entryTime", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'documentName': doc.id,
          'data': doc.data(),
        };
      }).toList();
    });
  }

  // Fetch stations based on the selected line
  Future<List<String>> fetchIntersections(String line) async {
    QuerySnapshot querySnapshot = await _db.collection(line).get();
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  // Fetch zones based on the selected station
  Future<List<String>> fetchZones(String line, String station) async {
    QuerySnapshot querySnapshot =
        await _db.collection(line).doc(station).collection('zones').get();
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  //Used for alerts
  Stream<List<DocumentSnapshot>> detectUsersOnTrack() {
    return FirebaseFirestore.instance
        .collection('EW-Line') // Start with the MRT line
        .snapshots() // Stream of MRT stations
        .asyncMap((stationsSnapshot) async {
      List<DocumentSnapshot> detectedUsers = [];

      // Fetch zones for all stations concurrently
      await Future.wait(stationsSnapshot.docs.map((stationDoc) async {
        var zonesSnapshot =
            await stationDoc.reference.collection('zones').get();

        // Fetch detected users concurrently for all zones
        await Future.wait(zonesSnapshot.docs.map((zoneDoc) async {
          var usersDetectedSnapshot = await zoneDoc.reference
              .collection('Users Detected')
              .where('onTrack', isEqualTo: true)
              .get();
          detectedUsers.addAll(usersDetectedSnapshot.docs);
        }));
      }));

      return detectedUsers; // Return all detected users on track
    });
  }

  //Used for alerts
  Future<DocumentSnapshot> getWorkerDetails(String helmetID) async {
    return await FirebaseFirestore.instance
        .collection('HelmetID')
        .doc(helmetID)
        .get();
  }

  // Fetch user data to check bookIn status
  Future<Object?> getUserData(String email) async {
    DocumentSnapshot snapshot = await _db.collection('Users').doc(email).get();
    return snapshot.exists ? snapshot.data() : null;
  }

  //Saves workers book in
  Future<void> saveWorkerData({
    required String email,
    required List<String> approveZones,
    required List<String> approveIntersections,
    required int helmetID,
    required String name,
  }) async {
    try {
      await _db.collection('Users').doc(email).set({
        'approveZones': approveZones,
        'helmetID': helmetID,
        'intersection': approveIntersections,
        'name': name,
        'entryTime': FieldValue.serverTimestamp(),
        'bookIn': true,
      });
    } catch (e) {
      throw Exception('Failed to save worker data: $e');
    }
  }

  //HelmetID update
  Future<void> updateHelmetID({
    required List<String> approveZones,
    required List<String> approveIntersections,
    required int helmetID,
    required String name,
  }) async {
    try {
      await _db.collection('HelmetID').doc(helmetID.toString()).set({
        'approveZones': approveZones,
        'intersection': approveIntersections,
        'name': name,
      });
    } catch (e) {
      throw Exception('Failed to save worker data: $e');
    }
  }

  // Update the user's bookIn status and save record in 'Records'
  Future<void> bookOutWorker({
    required String email,
    required Map<String, dynamic> userData,
  }) async {
    String uniqueId = _db.collection('Users').doc().id; // Generate unique ID
    DateTime exitTime = DateTime.now(); // Current time as exit time

    // Add the exitTime to userData before saving it to the 'Records' collection
    userData['exitTime'] = exitTime;

    // Save the current data in 'Records' with exitTime
    await _db
        .collection('Users')
        .doc(email)
        .collection('Records')
        .doc(uniqueId)
        .set(userData);

    // Update bookIn to false and add exitTime to the user's document
    await _db.collection('Users').doc(email).update({
      'bookIn': false,
      'exitTime': exitTime,
    });
  }
}
