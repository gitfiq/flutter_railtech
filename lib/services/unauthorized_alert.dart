import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_railtech/services/firestore_operations.dart';
import 'package:uuid/uuid.dart';

class UnauthorizedDetectionService {
  final FirestoreOperations _firestoreService = FirestoreOperations();
  final StreamController<Map<String, dynamic>> _unauthorizedStreamController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get unauthorizedStream =>
      _unauthorizedStreamController.stream;
  StreamSubscription? _subscription;

  final BuildContext context;
  final Function(String, String, String) onUnauthorizedDetected;

  UnauthorizedDetectionService({
    required this.context,
    required this.onUnauthorizedDetected,
  }) {
    monitorUnauthorizedEntries();
  }

  bool isZoneAuthorized(String detectedZone, List<String> approvedZones) {
    final cleanedDetectedZone = detectedZone.trim();
    return approvedZones.contains(cleanedDetectedZone);
  }

  void monitorUnauthorizedEntries() {
    _subscription =
        _firestoreService.detectUsersOnTrack().listen((detectedUsers) async {
      final Map<String, Map<String, dynamic>> currentAlerts = {};

      for (var userDoc in detectedUsers) {
        final helmetID = userDoc.id;
        final detectedZone = userDoc['zone'];
        final intersection = userDoc['intersection'];

        // Fetch worker details asynchronously
        final workerDoc = await _firestoreService.getWorkerDetails(helmetID);
        final approvedZones = List<String>.from(workerDoc['approveZones']);

        if (!isZoneAuthorized(detectedZone, approvedZones)) {
          final alertId = const Uuid().v4();
          currentAlerts[alertId] = {
            'helmetID': helmetID,
            'intersection': intersection,
            'zoneName': detectedZone,
          };
          onUnauthorizedDetected(helmetID, intersection, detectedZone);
        }

        // _firestoreService.getWorkerDetails(helmetID).then((workerDoc) {
        //   final approvedZones = List<String>.from(workerDoc['approveZones']);
        //   if (!isZoneAuthorized(detectedZone, approvedZones)) {
        //     currentAlerts[helmetID] = {
        //       'helmetID': helmetID,
        //       'intersection': intersection,
        //       'zoneName': detectedZone,
        //     };
        //     onUnauthorizedDetected(helmetID, intersection, detectedZone);
        //   }
        // });
      }

      // Notify stream with current active alerts
      _unauthorizedStreamController.add(currentAlerts);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _unauthorizedStreamController.close();
  }
}
