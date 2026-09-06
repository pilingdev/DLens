import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scan_record.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<ScanRecord> _records = [];
  Box? _historyBox;
  static const int _maxRecords = 12;

  List<ScanRecord> get records => List.unmodifiable(_records);

  Future<void> init() async {
    _historyBox = await Hive.openBox('historyBox');
    _loadFromBox();
  }

  void _loadFromBox() {
    if (_historyBox == null) return;

    _records.clear();
    for (var key in _historyBox!.keys) {
      final json = _historyBox!.get(key) as Map;
      _records.add(ScanRecord.fromJson(json));
    }

    // Sort by date descending (newest first)
    _records.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addRecord(ScanRecord record) async {
    if (_historyBox == null) return;

    File? savedImage;
    if (record.imageFile != null && await record.imageFile!.exists()) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final ext = record.imageFile!.path.split('.').last;
        final newPath = '${directory.path}/scan_${record.id}.$ext';
        savedImage = await record.imageFile!.copy(newPath);
      } catch (e) {
        debugPrint('Error saving image: $e');
        savedImage =
            record.imageFile; // fallback to original path if copy fails
      }
    }

    // Create a new record with the saved image path
    final recordToSave = ScanRecord(
      id: record.id,
      mosquitoType: record.mosquitoType,
      result: record.result,
      confidence: record.confidence,
      date: record.date,
      imageFile: savedImage,
      symptoms: record.symptoms,
      riskScore: record.riskScore,
      location: record.location,
      detectionCount: record.detectionCount,
      detections: record.detections,
      imageWidth: record.imageWidth,
      imageHeight: record.imageHeight,
    );

    _records.insert(0, recordToSave);
    await _historyBox!.put(recordToSave.id, recordToSave.toJson());

    // Enforce max records limit
    if (_records.length > _maxRecords) {
      final recordsToDelete = _records.sublist(_maxRecords);
      for (var r in recordsToDelete) {
        await _historyBox!.delete(r.id);
        if (r.imageFile != null && await r.imageFile!.exists()) {
          try {
            await r.imageFile!.delete();
          } catch (e) {
            debugPrint('Error deleting old image: $e');
          }
        }
      }
      _records.removeRange(_maxRecords, _records.length);
    }
  }

  /// Deletes a single scan record by [id] from local storage and memory.
  ///
  /// Also deletes the associated image file from the app documents directory
  /// if it exists, to prevent orphaned storage.
  Future<void> deleteRecord(String id) async {
    if (_historyBox == null) return;

    // Find the record in memory first so we can clean up the image.
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx == -1) return; // already gone

    final record = _records[idx];

    // Delete the image file if it exists.
    if (record.imageFile != null && await record.imageFile!.exists()) {
      try {
        await record.imageFile!.delete();
      } catch (e) {
        debugPrint('Error deleting image for record $id: $e');
      }
    }

    // Remove from Hive and in-memory list.
    await _historyBox!.delete(id);
    _records.removeAt(idx);
  }

  Future<void> clearHistory() async {
    if (_historyBox != null) {
      await _historyBox!.clear();
    }
    for (var r in _records) {
      if (r.imageFile != null && await r.imageFile!.exists()) {
        try {
          await r.imageFile!.delete();
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }
    }
    _records.clear();
  }
}
