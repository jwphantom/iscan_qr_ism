import 'package:flutter/material.dart';
import 'package:iscan_qr/services/settings.dart';
import 'package:iscan_qr/services/navigation_service.dart';
import 'package:iscan_qr/helpers/dialog_helper.dart';

class SettingsController {
  static Future<void> handleSettingsNavigation(BuildContext context) async {
    final hasPin = await SettingsService.hasPin();
    final pinResult = await DialogHelper.showPinVerification(context, !hasPin);

    if (pinResult == true && context.mounted) {
      await NavigationService.navigateToSettings(context);
    }
  }

  static Future<bool> checkAndHandleSettings(BuildContext context) async {
    if (!await SettingsService.hasValidSettings()) {
      final shouldConfigure =
          await DialogHelper.showSettingsConfigurationDialog(context);

      if (shouldConfigure == true && context.mounted) {
        await handleSettingsNavigation(context);
        return await SettingsService.hasValidSettings();
      }
      return false;
    }
    return true;
  }
}
