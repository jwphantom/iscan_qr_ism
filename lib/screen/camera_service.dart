import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraService {
  static Future<void> resumeCamera(QRViewController? controller) async {
    if (controller != null) {
      try {
        await controller.resumeCamera();
      } catch (e) {
        print("Error resuming camera: $e");
      }
    }
  }

  static Future<void> pauseCamera(QRViewController? controller) async {
    if (controller != null) {
      try {
        await controller.pauseCamera();
      } catch (e) {
        print("Error pausing camera: $e");
      }
    }
  }

  static Future<void> flipCamera(QRViewController? controller) async {
    await controller?.flipCamera();
  }

  static Future<void> toggleFlash(QRViewController? controller) async {
    await controller?.toggleFlash();
  }
}
