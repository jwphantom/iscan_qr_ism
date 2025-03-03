import 'package:flutter/material.dart';
import 'package:iscan_qr/controllers/settings_controller.dart';
import 'package:iscan_qr/screen/badge_history_screen.dart';
import 'package:iscan_qr/screen/qr_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 500;
    final double buttonHeight = size.width < 600 ? 50.0 : 60.0;
    final double iconSize = size.width < 600 ? 80.0 : 100.0;
    final double horizontalPadding = size.width < 600 ? 8.0 : 16.0;

    // Calculer la taille du logo en fonction de la largeur de l'écran
    final double logoSize =
        size.width < 600 ? size.width * 0.5 : size.width * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                SettingsController.handleSettingsNavigation(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logo container avec position absolute
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: logoSize,
                      width: logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            // Contenu central
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: iconSize,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: size.width < 600 ? 20 : 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Click on Scan to start scanning QR codes',
                    style: TextStyle(
                      fontSize: size.width < 600 ? 14 : 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Boutons
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: horizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: horizontalPadding / 2),
                      height: buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () async {
                          final settingsOk =
                              await SettingsController.checkAndHandleSettings(
                                  context);
                          if (settingsOk && context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QRViewScreen(),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner,
                                color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isLargeScreen ? 'Start Session Scan' : 'Scan',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: horizontalPadding / 2),
                      height: buttonHeight,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BadgeHistoryPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              isLargeScreen ? 'View History Scan' : 'History',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
