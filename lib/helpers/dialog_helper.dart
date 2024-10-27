import 'package:flutter/material.dart';
import 'package:iscan_qr/widget/dialog/pin_dialog.dart';

class DialogHelper {
  static Future<bool?> showPinVerification(
      BuildContext context, bool isSetup) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(isSetup: isSetup),
    );
  }

  static Future<bool?> showSettingsConfigurationDialog(
      BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuration requise'),
          content: const Text(
              'Les paramètres de l\'IP serveur et port ne sont pas configurés. Voulez-vous les configurer maintenant ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Configurer',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}
