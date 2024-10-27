import 'dart:convert';
import 'package:iscan_qr/model/badge_scan.dart';
import 'package:iscan_qr/services/qr_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeStorageService {
  static const String _storageKey = 'badge_scans';
  final SharedPreferences _prefs;

  BadgeStorageService(this._prefs);

  static Future<BadgeStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return BadgeStorageService(prefs);
  }

  Future<void> saveBadgeScan(QRVerificationResult result) async {
    final badgeScan = BadgeScan(
      name: result.name,
      function: result.function,
      isAuthorized: result.isAuthorized,
      scanTime: DateTime.now(),
    );

    // Récupérer les scans existants
    final List<String> existingScans = _prefs.getStringList(_storageKey) ?? [];

    // Ajouter le nouveau scan
    existingScans.add(jsonEncode(badgeScan.toJson()));

    // Sauvegarder la liste mise à jour
    await _prefs.setStringList(_storageKey, existingScans);
  }

  List<BadgeScan> getAllBadgeScans() {
    final List<String> scansJson = _prefs.getStringList(_storageKey) ?? [];
    return scansJson.map((scan) {
      final Map<String, dynamic> scanMap = jsonDecode(scan);
      return BadgeScan.fromJson(scanMap);
    }).toList();
  }

  Future<void> clearAllScans() async {
    await _prefs.remove(_storageKey);
  }

  List<BadgeScan> getBadgeScansForDate(DateTime date) {
    return getAllBadgeScans().where((scan) {
      return scan.scanTime.year == date.year &&
          scan.scanTime.month == date.month &&
          scan.scanTime.day == date.day;
    }).toList();
  }

  List<BadgeScan> getBadgeScansForPerson(String name) {
    return getAllBadgeScans()
        .where((scan) => scan.name.toLowerCase() == name.toLowerCase())
        .toList();
  }

  List<BadgeScan> getBadgeScansForDateRange(
      DateTime startDate, DateTime endDate) {
    // Normaliser les dates pour ignorer les heures
    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return getAllBadgeScans().where((scan) {
      // Normaliser la date du scan pour la comparaison
      final scanDate = scan.scanTime;

      // Vérifier si la date du scan est dans la plage
      return scanDate
              .isAfter(normalizedStartDate.subtract(Duration(seconds: 1))) &&
          scanDate.isBefore(normalizedEndDate.add(Duration(seconds: 1)));
    }).toList()
      ..sort((a, b) => a.scanTime.compareTo(b.scanTime)); // Trier par date
  }
}
