import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:iscan_qr/services/qr_verification.dart';
import 'package:iscan_qr/widget/qr/qr_result_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:iscan_qr/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final String qrContent;
  const PhotoCaptureScreen({Key? key, required this.qrContent})
      : super(key: key);

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  late AnimationController _animController;
  QRVerificationResult? _verificationResult;
  late Animation<double> fadeAnimation;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animController.forward();

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<String> _getScanMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('scanMode') ?? 'both';
  }

  Future<void> _capture() async {
    final scanMode = await _getScanMode();

    if (!_isCameraInitialized || _isCapturing || !mounted) return;
    setState(() => _isCapturing = true);

    try {
      final image = await _cameraController!.takePicture();

      if (mounted) {
        setState(() => _isCapturing = false);

        if (scanMode == 'both') {
          Navigator.pop(context, {
            'imagePath': image.path,
          });
        }

        // Vérification du QR code avec la photo
        final verificationResult =
            await QRVerificationService().verifyPhoto(File(image.path));

        if (mounted) {
          setState(() {
            _verificationResult = verificationResult;
            showResult = true; // ✅ Afficher le résultat temporairement
          });

          await AudioService.playSound(verificationResult.isAuthorized);

          // ✅ Lancer l'animation + disparition après 5 secondes
          _animController.forward(from: 0.0);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                showResult = false;
                _verificationResult = null;
              });
            }
          });
        }
      }
    } catch (e) {
      print("Capture error: $e");
      setState(() => _isCapturing = false);
    }
  }

// Redémarrer la caméra après la vérification
  void _restartCamera() async {
    if (!_isCameraInitialized) return;
    await _cameraController!.initialize();
    setState(() {});
  }

// Ne pas disposer la caméra lors de la navigation
  Future<void> _cleanupAndPop() async {
    try {
      await _animController.reverse();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Cleanup error: $e");
    }
  }

  Widget _buildResult() {
    if (_verificationResult == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: QRResultWidget(
        result: _verificationResult!,
        fadeAnimation: fadeAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final scale = 1 / (deviceRatio * _cameraController!.value.aspectRatio);

    return WillPopScope(
      onWillPop: () async {
        await _cleanupAndPop();
        return false;
      },
      child: FadeTransition(
        opacity: _animController,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Transform.scale(
                scale: scale,
                child: Center(
                  child: CameraPreview(_cameraController!),
                ),
              ),
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Text(
                  'Position your face in the circle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "back",
                      onPressed: _cleanupAndPop,
                      backgroundColor: Colors.white54,
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: _isCapturing ? null : _capture,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isCapturing ? Colors.grey : Colors.white,
                        ),
                        child: _isCapturing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Container(
                                margin: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
              ),
              if (_verificationResult != null) _buildResult(), // ✅ AJOUT ICI
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
