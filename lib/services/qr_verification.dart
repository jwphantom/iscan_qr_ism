import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRVerificationResult {
  final String name;
  final String function;
  final bool isAuthorized;

  QRVerificationResult({
    required this.name,
    required this.function,
    required this.isAuthorized,
  });
}

class QRVerificationService {
  static const timeoutDuration = Duration(seconds: 30);

  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '10.42.0.1';
    final port = prefs.getString('port') ?? '5000';

    final baseUrl = "http://${ip}:${port}";

    if (baseUrl.contains(':$port')) {
      return baseUrl;
    }

    final cleanBaseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$cleanBaseUrl:$port';
  }

  Future<QRVerificationResult> verifyQRCode(String qrData) async {
    try {
      final baseUrl = await _getBaseUrl();
      print('URL de base utilisée: $baseUrl');
      print('Données QR reçues: $qrData');

      final response = await http
          .post(
        Uri.parse('$baseUrl/validate_access'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'encrypted_data': qrData,
        }),
      )
          .timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Le serveur met trop de temps à répondre');
        },
      );

      print('Status code: ${response.statusCode}');
      print('Réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QRVerificationResult(
          name: 'Accès Accepté',
          function: data['status'] ?? 'Status inconnu',
          isAuthorized: true,
        );
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return QRVerificationResult(
          name: 'Accès Refusé',
          function: data['error'] ?? 'Non autorisé',
          isAuthorized: false,
        );
      } else {
        print('Erreur serveur: ${response.body}');
        return QRVerificationResult(
          name: 'Erreur',
          function: 'Erreur système',
          isAuthorized: false,
        );
      }
    } on TimeoutException {
      print('Erreur: Timeout de la requête');
      return QRVerificationResult(
        name: 'Erreur réseau',
        function: 'Le serveur ne répond pas',
        isAuthorized: false,
      );
    } catch (e) {
      print('Erreur lors de la vérification: $e');
      return QRVerificationResult(
        name: 'Erreur',
        function: 'Erreur de connexion',
        isAuthorized: false,
      );
    }
  }
}
