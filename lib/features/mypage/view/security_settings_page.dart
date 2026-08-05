import 'package:flutter/material.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/auth/data/local/biometric_service.dart';

/// 자동로그인 / 생체인증 설정
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _biometric = BiometricService();

  bool _loading = true;
  bool _autoLogin = true;
  bool _biometricEnabled = false;
  bool _deviceSupportsBio = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final autoLogin = await SecureStorageService.isAutoLoginEnabled();
    final bio = await SecureStorageService.isBiometricEnabled();
    final can = await _biometric.canCheckBiometrics();
    if (!mounted) return;
    setState(() {
      _autoLogin = autoLogin;
      _biometricEnabled = bio;
      _deviceSupportsBio = can;
      _loading = false;
    });
  }

  Future<void> _toggleAutoLogin(bool value) async {
    await SecureStorageService.setAutoLoginEnabled(value);
    if (!value) {
      // 자동로그인 끄면 생체도 함께 끔
      await SecureStorageService.setBiometricEnabled(false);
      if (mounted) {
        setState(() {
          _autoLogin = false;
          _biometricEnabled = false;
        });
      }
      return;
    }
    if (mounted) setState(() => _autoLogin = true);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      if (!_deviceSupportsBio) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 기기에서는 생체인증을 사용할 수 없습니다.')),
        );
        return;
      }
      final ok = await _biometric.authenticate(
        reason: '생체인증을 사용하려면 한 번 인증해주세요.',
      );
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('생체인증에 실패했습니다.')),
        );
        return;
      }
      // 생체 켜면 자동로그인도 함께 켬
      await SecureStorageService.setAutoLoginEnabled(true);
      await SecureStorageService.setBiometricEnabled(true);
      if (!mounted) return;
      setState(() {
        _autoLogin = true;
        _biometricEnabled = true;
      });
      return;
    }

    await SecureStorageService.setBiometricEnabled(false);
    if (mounted) setState(() => _biometricEnabled = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('생체인증 / 자동로그인'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBlue),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '자동로그인',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: const Text(
                          '앱 실행 시 저장된 로그인 정보로 바로 진입합니다.',
                        ),
                        value: _autoLogin,
                        activeThumbColor: AppColors.primary,
                        onChanged: _toggleAutoLogin,
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '생체인증 (지문/Face)',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          _deviceSupportsBio
                              ? '자동로그인 전에 생체인증을 한 번 더 확인합니다.'
                              : '이 기기는 생체인증을 지원하지 않습니다.',
                        ),
                        value: _biometricEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: _deviceSupportsBio ? _toggleBiometric : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '참고\n'
                  '· 로그아웃하면 토큰이 삭제되어 자동로그인이 동작하지 않습니다.\n'
                  '· 생체인증을 켜면 자동로그인도 함께 켜집니다.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}
