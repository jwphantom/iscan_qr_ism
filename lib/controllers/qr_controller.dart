import 'package:flutter/material.dart';
import 'package:iscan_qr/screen/audio_service.dart';
import 'package:iscan_qr/screen/camera_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:iscan_qr/services/qr_verification.dart';
import 'package:iscan_qr/services/badge_storage.dart';

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

  Future<void> handleQRCode(
      Barcode scanData, QRViewController? controller) async {
    onProcessingStart();

    try {
      await CameraService.pauseCamera(controller);

      String? qrContent = scanData.code;
      print('Contenu du QR Code: $qrContent');

      final result =
          await _verificationService.verifyQRCode(qrContent ?? "INVALID");
      await _storageService.saveBadgeScan(result);

      await AudioService.playSound(result.isAuthorized);
      onResultReceived(result);
    } catch (e) {
      print("Error during QR processing: $e");
      await CameraService.resumeCamera(controller);
    } finally {
      onProcessingEnd();
    }
  }
}
