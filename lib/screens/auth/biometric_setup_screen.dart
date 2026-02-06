import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _isAvailable = false;
  String _biometricType = 'Biometric';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService.canCheckBiometrics();
    final type = await BiometricService.getBiometricTypeName();
    setState(() {
      _isAvailable = available;
      _biometricType = type;
      _isLoading = false;
    });
  }

  Future<void> _enableBiometric() async {
    final authenticated = await BiometricService.authenticate(
      'Enable $_biometricType for VB Bank',
    );

    if (authenticated && mounted) {
      await context.read<AuthProvider>().toggleBiometric(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_biometricType enabled successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _biometricType == 'Face ID'
                        ? Icons.face
                        : Icons.fingerprint,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isAvailable
                        ? 'Enable $_biometricType'
                        : '$_biometricType Not Available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isAvailable
                        ? 'Use $_biometricType to quickly and securely log in to your VB Bank account.'
                        : 'Your device does not support biometric authentication. You can still use your username and password to log in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_isAvailable)
                    CustomButton(
                      text: 'Enable $_biometricType',
                      onPressed: _enableBiometric,
                      icon: Icons.fingerprint,
                    ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: _isAvailable ? 'Skip for Now' : 'Go Back',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                ],
              ),
      ),
    );
  }
}
