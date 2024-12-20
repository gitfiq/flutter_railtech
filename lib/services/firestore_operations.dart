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
          // Safeguard by checking if data is not null
          return {
            'documentName': doc.id,
            'data': doc.data(),
          };
        }).toList();
      });
    }

    // Filter users by line prefix in their "intersection" field
    return usersCollection.orderBy('intersection').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
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
}
