import 'package:flutter/material.dart';
import 'package:iscan_qr/screen/settings_screen.dart';

class NavigationService {
  static Future<void> navigateToSettings(BuildContext context) async {
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    }
  }
}
