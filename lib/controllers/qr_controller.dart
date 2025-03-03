import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iscan_qr/services/audio_service.dart';
import 'package:iscan_qr/services/camera_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:iscan_qr/services/qr_verification.dart';
import 'package:iscan_qr/services/badge_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRController {
  final QRVerificationService _verificationService;
  final BadgeStorageService _storageService;
  final Function(QRVerificationResult) onResultReceived;
  final VoidCallback onProcessingStart;
  final VoidCallback onProcessingEnd;

  QRController({
    required this.onResultReceived,
    required this.onProcessingStart,
    required this.onProcessingEnd,
    required QRVerificationService verificationService,
    required BadgeStorageService storageService,
  })  : _verificationService = verificationService,
        _storageService = storageService;

  Future<String> _getScanMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('scanMode') ?? 'both';
  }

  void _showPhotoResult(BuildContext context, QRVerificationResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.isAuthorized ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> handleQRCodeWithPhoto(BuildContext context, Barcode? scanData,
      QRViewController? controller, File? photoFile) async {
    onProcessingStart();

    try {
      await CameraService.pauseCamera(controller);
      final scanMode = await _getScanMode();

      QRVerificationResult result;
      if (scanMode == 'photo') {
        // Mode photo uniquement
        if (photoFile == null) {
          throw Exception('Photo required for this scan mode');
        }
        result = await _verificationService.verifyQRCodeWithPhoto(
          'photo_only',
          photoFile,
          scanMode: scanMode,
        );

        // Pour le mode photo, on reprend la caméra après le résultat
        if (context.mounted) {
          _showPhotoResult(context, result);
        }

        if (controller != null) {
          await CameraService.resumeCamera(controller);
        }
      } else if (scanMode == 'qr') {
        // Mode QR uniquement
        if (scanData == null) {
          throw Exception('QR data required for this scan mode');
        }
        result =
            await _verificationService.verifyQRCode(scanData.code ?? "INVALID");
      } else {
        // Mode both
        if (scanData == null || photoFile == null) {
          throw Exception('Both QR and photo required for this scan mode');
        }
        result = await _verificationService.verifyQRCodeWithPhoto(
          scanData.code ?? "INVALID",
          photoFile,
          scanMode: scanMode,
        );
      }

      await _storageService.saveBadgeScan(result);
      await AudioService.playSound(result.isAuthorized);

      // Ne pas afficher le résultat si on est en mode photo
      if (scanMode != 'photo') {
        onResultReceived(result);
      }
    } catch (e) {
      print("Error during QR processing: $e");
      if (controller != null) {
        await CameraService.resumeCamera(controller);
      }
    } finally {
      onProcessingEnd();
    }
  }
}
