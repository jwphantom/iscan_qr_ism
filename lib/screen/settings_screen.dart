import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  String _selectedTime = '1h';
  bool _isFormValid = false;
  bool _isLoading = false;
  String _selectedScanMode = 'both';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _baseUrlController.addListener(_checkFormValidity);
    _portController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _baseUrlController.removeListener(_checkFormValidity);
    _portController.removeListener(_checkFormValidity);
    _baseUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    if (!mounted) return;

    setState(() {
      _isFormValid = _isIpValid(_baseUrlController.text) &&
          _isPortValid(_portController.text);
    });
  }

  bool _isIpValid(String ip) {
    if (ip.isEmpty) return false;

    final ipRegex = RegExp(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipRegex.hasMatch(ip.trim());
  }

  bool _isPortValid(String port) {
    if (port.isEmpty) return false;

    try {
      final portNum = int.parse(port.trim());
      return portNum > 0 && portNum <= 65535;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _baseUrlController.text = prefs.getString('ip') ?? '';
        _portController.text = prefs.getString('port') ?? '';
        _selectedTime = prefs.getString('timeSleep') ?? '1h';
        _selectedScanMode = prefs.getString('scanMode') ?? 'both';
      });

      _checkFormValidity();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ip', _baseUrlController.text.trim());
      await prefs.setString('port', _portController.text.trim());
      await prefs.setString('timeSleep', _selectedTime);
      await prefs.setString('scanMode', _selectedScanMode);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres sauvegardés avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde des paramètres'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildIpField(),
                    const SizedBox(height: 24),
                    _buildPortField(),
                    const SizedBox(height: 24),
                    _buildTimeField(),
                    const SizedBox(height: 24),
                    _buildScanModeField()
                  ],
                ),
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildIpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse IP',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _baseUrlController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: '10.42.0.1',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'adresse IP est requise';
            }
            if (!_isIpValid(value)) {
              return 'Format d\'IP invalide (ex: 192.168.1.1)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPortField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Port',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _portController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '5000',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le port est requis';
            }
            if (!_isPortValid(value)) {
              return 'Port invalide (1-65535)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temps d\'inactivité',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTime,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: ['1h', '2h', '3h'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedTime = newValue);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildScanModeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de scan',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedScanMode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'qr', child: Text('QR Code uniquement')),
            DropdownMenuItem(value: 'photo', child: Text('Photo uniquement')),
            DropdownMenuItem(value: 'both', child: Text('QR Code et Photo')),
          ],
          onChanged: _isLoading
              ? null
              : (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedScanMode = value;
                    });
                  }
                },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading || !_isFormValid ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
