import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class QRVerificationResult {
  final String title;
  final String message;
  final bool isAuthorized;
  final String? details;
  final int? statusCode;

  QRVerificationResult({
    required this.title,
    required this.message,
    required this.isAuthorized,
    this.details,
    this.statusCode,
  });

  // Function to decode UTF-8 string
  static String _decodeUtf8(String text) {
    try {
      return utf8.decode(text.codeUnits);
    } catch (e) {
      return text; // Return original text if decoding fails
    }
  }

  factory QRVerificationResult.success(String message) {
    return QRVerificationResult(
      title: 'Access Granted',
      message: _decodeUtf8(message),
      isAuthorized: true,
      statusCode: 200,
    );
  }

  factory QRVerificationResult.networkError(String message, {String? details}) {
    return QRVerificationResult(
      title: 'Network Error',
      message: _decodeUtf8(message),
      isAuthorized: false,
      details: details != null ? _decodeUtf8(details) : null,
      statusCode: 503,
    );
  }

  factory QRVerificationResult.serverError(String message, int statusCode,
      {String? details}) {
    return QRVerificationResult(
      title: 'Server Error',
      message: _decodeUtf8(message),
      isAuthorized: false,
      details: details != null ? _decodeUtf8(details) : null,
      statusCode: statusCode,
    );
  }

  factory QRVerificationResult.accessDenied(String message, {String? details}) {
    return QRVerificationResult(
      title: 'Access Denied',
      message: _decodeUtf8(message),
      isAuthorized: false,
      details: details != null ? _decodeUtf8(details) : null,
      statusCode: 403,
    );
  }

  factory QRVerificationResult.invalidRequest(String message,
      {String? details}) {
    return QRVerificationResult(
      title: 'Invalid Request',
      message: _decodeUtf8(message),
      isAuthorized: false,
      details: details != null ? _decodeUtf8(details) : null,
      statusCode: 400,
    );
  }
}

class QRVerificationService {
  static const timeoutDuration = Duration(seconds: 30);

  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '10.42.0.1';
    final port = prefs.getString('port') ?? '5000';

    if (!_isValidIpAddress(ip)) {
      throw FormatException('Invalid IP address: $ip');
    }
    if (!_isValidPort(port)) {
      throw FormatException('Invalid port: $port');
    }

    return "http://$ip:$port";
  }

  bool _isValidIpAddress(String ip) {
    return InternetAddress.tryParse(ip) != null;
  }

  bool _isValidPort(String port) {
    try {
      final portNum = int.parse(port);
      return portNum > 0 && portNum < 65536;
    } catch (_) {
      return false;
    }
  }

  String _decodeResponseBody(String body) {
    try {
      return utf8.decode(body.codeUnits);
    } catch (e) {
      return body;
    }
  }

  Future<String> _getScanMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('scanMode') ?? 'both';
  }

  Future<QRVerificationResult> verifyQRCode(String qrData) async {
    return verifyQRCodeWithPhoto(qrData, null, scanMode: 'qr');
  }

  Future<QRVerificationResult> verifyPhoto(File photoFile) async {
    return verifyQRCodeWithPhoto('', photoFile, scanMode: 'photo');
  }

  Future<QRVerificationResult> verifyQRCodeWithPhoto(
      String qrData, File? photoFile,
      {String? scanMode}) async {
    try {
      final baseUrl = await _getBaseUrl();
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/validate_access'));

      final currentScanMode = scanMode ?? await _getScanMode();
      request.fields['scan_mode'] = currentScanMode;

      if (currentScanMode != 'photo') {
        request.fields['encrypted_data'] = qrData;
      }

      if (photoFile != null) {
        final mimeType = lookupMimeType(photoFile.path) ?? 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photoFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      final decodedBody = utf8.decode(response.bodyBytes);

      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(decodedBody);
          return QRVerificationResult.success(
              data['status'] ?? 'Access granted');

        case 400:
          final data = jsonDecode(decodedBody);
          return QRVerificationResult.invalidRequest(
            'Invalid QR data or photo',
            details: data['error'] ?? 'Incorrect data format',
          );

        case 401:
          return QRVerificationResult.accessDenied(
            'Authentication failed',
            details: 'Invalid credentials or photo mismatch',
          );

        case 403:
          final data = jsonDecode(decodedBody);
          return QRVerificationResult.accessDenied(
            'Unauthorized access',
            details: data['error'] ?? 'Photo or QR verification failed',
          );

        case 408:
          return QRVerificationResult.networkError(
            'Request timeout',
            details: 'The server took too long to respond',
          );

        default:
          return QRVerificationResult.serverError(
            'Unexpected server error',
            response.statusCode,
            details: 'Status: ${response.statusCode}, Response: $decodedBody',
          );
      }
    } on TimeoutException {
      return QRVerificationResult.networkError(
        'Server not responding',
        details: 'Request timed out after ${timeoutDuration.inSeconds} seconds',
      );
    } on SocketException catch (e) {
      return QRVerificationResult.networkError(
        'Network connection error',
        details: 'Unable to connect to server: ${e.message}',
      );
    } on FormatException catch (e) {
      return QRVerificationResult.invalidRequest(
        'Invalid configuration',
        details: e.message,
      );
    } catch (e) {
      return QRVerificationResult.serverError(
        'System error',
        500,
        details: e.toString(),
      );
    }
  }
}
