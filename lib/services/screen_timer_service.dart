// lib/services/screen_timer_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimerService {
  static Timer? _inactivityTimer;
  static Timer? _keepScreenOnTimer;
  static const keepScreenCheckInterval = Duration(minutes: 1);
  static const defaultInactivityTimeout = Duration(hours: 1);

  static Future<Duration> _getInactivityTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('timeSleep') ?? '1h';

    // Convertir la chaîne en heures
    final hours = int.parse(timeString.replaceAll('h', ''));
    return Duration(hours: hours);
  }

  static Future<void> startInactivityTimer(BuildContext context) async {
    _inactivityTimer?.cancel();

    final timeout = await _getInactivityTimeout();
    _inactivityTimer = Timer(timeout, () {
      Navigator.of(context).pop();
    });
  }

  static Future<void> resetInactivityTimer(BuildContext context) async {
    await startInactivityTimer(context);
  }

  static void startKeepScreenOn() {
    try {
      _keepScreenOnTimer?.cancel();
      _keepScreenOnTimer =
          Timer.periodic(keepScreenCheckInterval, (timer) async {});
    } catch (e) {
      print("Erreur lors du maintien de l'écran allumé: $e");
    }
  }

  static void dispose() {
    _inactivityTimer?.cancel();
    _keepScreenOnTimer?.cancel();
  }
}
