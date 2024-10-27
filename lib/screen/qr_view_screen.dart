// lib/screens/qr_view_screen.dart
import 'package:flutter/material.dart';
import 'package:iscan_qr/screen/audio_service.dart';
import 'package:iscan_qr/screen/camera_service.dart';
import 'package:iscan_qr/services/screen_timer_service.dart';
import 'package:iscan_qr/widget/qr/qr_result_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:iscan_qr/services/qr_verification.dart';
import 'package:iscan_qr/services/badge_storage.dart';
import 'package:iscan_qr/controllers/qr_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class QRViewScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  late QRController _qrController;
  late BadgeStorageService _storageService;
  bool isFrontCamera = true;
  bool isAnalyzing = false;
  bool showResult = false;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> countdownAnimation;
  QRVerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();
    WakelockPlus.toggle(enable: true);
    _initializeServices();
    _setupAnimations();
    _setupScreenManagement();
  }

  Future<void> _initializeServices() async {
    _storageService = await BadgeStorageService.create();
    _qrController = QRController(
      verificationService: QRVerificationService(),
      storageService: _storageService,
      onResultReceived: _handleQRResult,
      onProcessingStart: () => setState(() => isAnalyzing = true),
      onProcessingEnd: () => setState(() => isAnalyzing = false),
    );
  }

  void _setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
      ),
    );

    countdownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );

    animationController.addStatusListener(_handleAnimationStatus);
  }

  void _setupScreenManagement() {
    ScreenTimerService.startInactivityTimer(context);
    ScreenTimerService.startKeepScreenOn();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        showResult = false;
        _verificationResult = null;
      });
      CameraService.resumeCamera(controller);
    }
  }

  void _handleQRResult(QRVerificationResult result) {
    setState(() {
      _verificationResult = result;
      showResult = true;
    });
    ScreenTimerService.resetInactivityTimer(context);
    animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQRView(),
          _buildAppBar(),
          if (isAnalyzing) _buildLoadingIndicator(),
          if (showResult) _buildResult(),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      cameraFacing: CameraFacing.front,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
        overlayColor: const Color.fromARGB(208, 0, 0, 0),
      ),
    );
  }

  Widget _buildAppBar() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  _buildCameraFlipButton(),
                  _buildFlashButton(),
                ],
              ),
            ],
          ),
        ),
        if (showResult) _buildCountdown(),
      ],
    );
  }

  Widget _buildCameraFlipButton() {
    return IconButton(
      icon: Icon(Icons.flip_camera_ios, color: Colors.white),
      onPressed: () async {
        await CameraService.flipCamera(controller);
        setState(() => isFrontCamera = !isFrontCamera);
      },
    );
  }

  Widget _buildFlashButton() {
    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.flash_on, color: Colors.white),
          if (isFrontCamera)
            Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 2,
                height: 30,
                color: Colors.red,
              ),
            ),
        ],
      ),
      onPressed:
          isFrontCamera ? null : () => CameraService.toggleFlash(controller),
    );
  }

  Widget _buildCountdown() {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: countdownAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                ),
                Text(
                  '${(countdownAnimation.value * 5).ceil()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Veuillez patienter pendant l\'analyse...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isAnalyzing && !showResult && mounted) {
        _qrController.handleQRCode(scanData, controller);
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.toggle(enable: false);
    ScreenTimerService.dispose();
    AudioService.dispose();
    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }
}
