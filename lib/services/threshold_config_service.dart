import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/threshold_config.dart';

class ThresholdConfigService {
  ThresholdConfigService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _documentRef => _firestore
      .collection(ThresholdConfig.collectionName)
      .doc(ThresholdConfig.documentId);

  Stream<ThresholdConfig?> watchThresholdConfig() {
    return _documentRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return ThresholdConfig.fromDocument(snapshot);
    });
  }

  Future<ThresholdConfig?> readThresholdConfig() async {
    final snapshot = await _documentRef.get();
    if (!snapshot.exists) {
      return null;
    }

    return ThresholdConfig.fromDocument(snapshot);
  }

  Future<void> createThresholdConfig(ThresholdConfig config) async {
    _validate(config);

    try {
      await _documentRef.set(config.toCreateMap());
    } on FirebaseException catch (error) {
      debugPrint('Create threshold config failed: $error');
      rethrow;
    }
  }

  Future<void> updateThresholdConfig(ThresholdConfig config) async {
    _validate(config);

    try {
      await _documentRef.set(config.toUpdateMap(), SetOptions(merge: true));
    } on FirebaseException catch (error) {
      debugPrint('Update threshold config failed: $error');
      rethrow;
    }
  }

  Future<void> saveThresholdConfig(ThresholdConfig config) async {
    final snapshot = await _documentRef.get();
    if (snapshot.exists) {
      await updateThresholdConfig(config);
    } else {
      await createThresholdConfig(config);
    }
  }

  Future<void> deleteThresholdConfig() async {
    try {
      await _documentRef.delete();
    } on FirebaseException catch (error) {
      debugPrint('Delete threshold config failed: $error');
      rethrow;
    }
  }

  Future<void> resetToDefaults() {
    return createThresholdConfig(ThresholdConfig.defaults());
  }

  void _validate(ThresholdConfig config) {
    final validationError = config.validate();
    if (validationError != null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-argument',
        message: validationError,
      );
    }
  }
}
