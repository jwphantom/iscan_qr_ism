import 'package:flutter/material.dart';
import 'package:iscan_qr/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null).then((_) => runApp(MyApp()));

  final prefs = await SharedPreferences.getInstance();

  // prefs.remove('baseUrl');
  // prefs.remove('ip');
  // prefs.remove('port');
  // prefs.remove('timeSleep');
  // prefs.remove('settings_pin');
  //prefs.remove('badge_scans');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen());
  }
}
