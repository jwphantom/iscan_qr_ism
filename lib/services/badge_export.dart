import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:iscan_qr/model/badge_scan.dart';
import 'package:iscan_qr/services/badge_storage.dart';
import 'package:path_provider/path_provider.dart';

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
    return 'Date,Heure,Titre,Message,Details,Statut,isAuthorized\n';
  }

  String _escapeCsvField(String field) {
    // Remplacer les guillemets doubles par deux guillemets doubles
    field = field.replaceAll('"', '""');
    // Entourer le champ de guillemets s'il contient des virgules, des sauts de ligne ou des guillemets
    if (field.contains(',') || field.contains('\n') || field.contains('"')) {
      field = '"$field"';
    }
    return field;
  }

  String _scanToCsvLine(BadgeScan scan) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    final fields = [
      dateFormat.format(scan.scanTime),
      timeFormat.format(scan.scanTime),
      _escapeCsvField(scan.titre),
      _escapeCsvField(scan.message),
      _escapeCsvField(scan.details ?? ""),
      (scan.statusCode),
      scan.isAuthorized ? "Autorisé" : "Refusé"
    ];

    return '${fields.join(",")}\n';
  }

  Future<String> exportMonthlyReport() async {
    try {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception("Permission refusée");
      }

      final monthRange = _getCurrentMonthRange();
      final scans = _storageService.getBadgeScansForDateRange(
          monthRange['start']!, monthRange['end']!);

      // Préparer le contenu CSV
      final StringBuffer buffer = StringBuffer();

      // Ajouter le BOM UTF-8
      buffer.writeCharCode(0xFEFF);

      // Ajouter l'en-tête et les données
      buffer.write(_generateCsvHeader());
      for (var scan in scans) {
        buffer.write(_scanToCsvLine(scan));
      }

      final now = DateTime.now();
      final fileName =
          'badges_${now.year}_${now.month.toString().padLeft(2, '0')}.csv';

      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        final file = File('${directory.path}/$fileName');

        // Écrire avec l'encodage UTF-8
        await file.writeAsBytes(utf8.encode(buffer.toString()));
        return file.path;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');

        // Écrire avec l'encodage UTF-8
        await file.writeAsBytes(utf8.encode(buffer.toString()));
        return file.path;
      }
    } catch (e) {
      print("Erreur lors de l'export: $e");
      throw Exception('Erreur lors de l\'export: $e');
    }
  }
}
