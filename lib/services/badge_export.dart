import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:iscan_qr/model/badge_scan.dart';
import 'package:iscan_qr/services/badge_storage.dart';

class BadgeExportService {
  final BadgeStorageService _storageService;

  BadgeExportService(this._storageService);

  Map<String, DateTime> _getCurrentMonthRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return {
      'start': firstDayOfMonth,
      'end': lastDayOfMonth,
    };
  }

  String _generateCsvHeader() {
    return 'Date,Heure,Nom,Fonction,Statut\n';
  }

  String _scanToCsvLine(BadgeScan scan) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return '${dateFormat.format(scan.scanTime)},'
        '${timeFormat.format(scan.scanTime)},'
        '"${scan.name}",'
        '"${scan.function}",'
        '${scan.isAuthorized ? "Autorisé" : "Refusé"}\n';
  }

  Future<String> exportMonthlyReport() async {
    try {
      final monthRange = _getCurrentMonthRange();
      final scans = _storageService.getBadgeScansForDateRange(
          monthRange['start']!, monthRange['end']!);

      String csvContent = _generateCsvHeader();
      for (var scan in scans) {
        csvContent += _scanToCsvLine(scan);
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      final now = DateTime.now();
      final fileName =
          'badges_${now.year}_${now.month.toString().padLeft(2, '0')}.csv';
      final file = File('${directory!.path}/$fileName');

      await file.writeAsString(csvContent);

      return file.path;
    } catch (e) {
      throw Exception('Erreur lors de l\'export: $e');
    }
  }
}
