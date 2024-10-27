import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinDialog extends StatefulWidget {
  final bool isSetup;
  const PinDialog({Key? key, this.isSetup = false}) : super(key: key);

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _errorText;

  Future<void> _validatePin() async {
    final prefs = await SharedPreferences.getInstance();
    if (widget.isSetup) {
      if (_pinController.text.length != 4) {
        setState(() => _errorText = 'Le PIN doit contenir 4 chiffres');
        return;
      }
      if (_pinController.text != _confirmPinController.text) {
        setState(() => _errorText = 'Les PINs ne correspondent pas');
        return;
      }
      await prefs.setString('settings_pin', _pinController.text);
      Navigator.of(context).pop(true);
    } else {
      final savedPin = prefs.getString('settings_pin');
      if (savedPin == _pinController.text) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorText = 'PIN incorrect');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isSetup ? 'Définir le PIN' : 'Entrer le PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
            ),
          ),
          if (widget.isSetup) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le PIN',
              ),
            ),
          ],
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _validatePin,
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
