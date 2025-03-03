import 'package:flutter/material.dart';
import 'package:iscan_qr/services/qr_verification.dart';

class QRResultWidget extends StatelessWidget {
  final QRVerificationResult result;
  final Animation<double> fadeAnimation;

  const QRResultWidget({
    Key? key,
    required this.result,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Grand cercle avec icône
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                // Message principal
                Text(
                  result.isAuthorized ? 'Accès Autorisé' : 'Accès Refusé',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 12),
                // Message de détail
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    if (result.isAuthorized) {
      return Colors.green;
    } else if (result.statusCode == 403) {
      return Colors.red;
    } else if (result.statusCode == 408 || result.statusCode == 503) {
      return Colors.orange;
    }
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (result.isAuthorized) {
      return Icons.check;
    } else if (result.statusCode == 408 || result.statusCode == 503) {
      return Icons.wifi_off;
    }
    return Icons.close;
  }
}
