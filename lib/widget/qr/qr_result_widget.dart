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
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                SizedBox(height: 16),
                _buildInfoRow(Icons.person, result.name),
                SizedBox(height: 8),
                _buildInfoRow(Icons.work, result.function),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: result.isAuthorized ? Colors.green : Colors.red,
          ),
          child: Icon(
            result.isAuthorized ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Text(
          result.isAuthorized ? 'Autorisé' : 'Refusé',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: result.isAuthorized ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
