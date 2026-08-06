import 'package:flutter/material.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/auth/data/local/biometric_service.dart';

/// 자동로그인 / 앱 잠금(지문·PIN) 설정
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage>
    with WidgetsBindingObserver {
  final _biometric = BiometricService();

  bool _loading = true;
  bool _autoLogin = true;
  bool _biometricEnabled = false;
  BiometricCapability _capability = const BiometricCapability(
    deviceSupported: false,
    canCheckBiometrics: false,
    availableTypes: [],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 설정 앱에서 PIN/지문 등록 후 돌아올 때 다시 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(soft: true);
    }
  }

  Future<void> _load({bool soft = false}) async {
    if (!soft) {
      setState(() => _loading = true);
    }
    final autoLogin = await SecureStorageService.isAutoLoginEnabled();
    final bio = await SecureStorageService.isBiometricEnabled();
    final cap = await _biometric.getCapability();

    // 기기에서 잠금을 못 쓰게 됐으면 설정값도 끔
    if (!cap.canUseAppLock && bio) {
      await SecureStorageService.setBiometricEnabled(false);
    }

    if (!mounted) return;
    setState(() {
      _autoLogin = autoLogin;
      _biometricEnabled = cap.canUseAppLock && bio;
      _capability = cap;
      _loading = false;
    });
  }

  Future<void> _toggleAutoLogin(bool value) async {
    await SecureStorageService.setAutoLoginEnabled(value);
    if (!value) {
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
      // 최신 상태 재확인 (에뮬에서 PIN 막 등록한 경우)
      final cap = await _biometric.getCapability();
      if (!mounted) return;
      setState(() => _capability = cap);

      if (!cap.canUseAppLock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '먼저 기기에 PIN/패턴 또는 지문을 등록해주세요.',
            ),
          ),
        );
        return;
      }

      final ok = await _biometric.authenticate(
        reason: '앱 잠금을 사용하려면 한 번 인증해주세요.',
      );
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증에 실패했습니다. 다시 시도해주세요.')),
        );
        return;
      }

      await SecureStorageService.setAutoLoginEnabled(true);
      await SecureStorageService.setBiometricEnabled(true);
      if (!mounted) return;
      setState(() {
        _autoLogin = true;
        _biometricEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 잠금이 켜졌습니다.')),
      );
      return;
    }

    await SecureStorageService.setBiometricEnabled(false);
    if (mounted) setState(() => _biometricEnabled = false);
  }

  @override
  Widget build(BuildContext context) {
    final canLock = _capability.canUseAppLock;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('생체인증 / 자동로그인'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '다시 확인',
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
                          '앱 잠금 (지문/Face/PIN)',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(_capability.summaryLabel),
                        value: _biometricEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: canLock ? _toggleBiometric : null,
                      ),
                    ],
                  ),
                ),
                if (!canLock) ...[
                  const SizedBox(height: 12),
                  _SetupGuideCard(onRecheck: () => _load()),
                ],
                const SizedBox(height: 16),
                Text(
                  canLock
                      ? '참고\n'
                          '· 카카오 로그인 성공 시 자동로그인이 기본으로 켜집니다.\n'
                          '· 앱 잠금을 켜면 재실행 시 지문/Face 또는 PIN 확인 후 홈으로 갑니다.\n'
                          '· 로그아웃해도 자동로그인·잠금 설정은 유지되고, 토큰만 삭제됩니다.\n'
                          '· 에뮬레이터: 우측 ... → Fingerprint 에서 가상 지문을 등록하세요.'
                      : '참고\n'
                          '· 에뮬레이터/실기기 모두 화면 잠금(PIN) 또는 지문이 있어야 합니다.\n'
                          '· 등록 후 오른쪽 위 새로고침(또는 앱 재진입)을 눌러주세요.',
                  style: const TextStyle(
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

class _SetupGuideCard extends StatelessWidget {
  const _SetupGuideCard({required this.onRecheck});

  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '잠금을 쓰려면 먼저 등록이 필요해요',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9A3412),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '【에뮬레이터】\n'
            '1) 기기 설정 → Security → Screen lock 에서 PIN 설정\n'
            '2) 에뮬 우측 ... (Extended controls) → Fingerprint\n'
            '3) Fingerprint 1 → TOUCH THE SENSOR\n'
            '4) 아래 버튼으로 다시 확인\n\n'
            '【실제 폰】\n'
            '설정 → 보안 → 화면 잠금/지문 등록 후 다시 확인',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF9A3412),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRecheck,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('등록했는지 다시 확인'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9A3412),
                side: const BorderSide(color: Color(0xFFFDBA74)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
