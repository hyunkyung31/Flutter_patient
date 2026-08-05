import 'package:flutter/material.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../auth/presentation/pages/login_page.dart';
import 'security_settings_page.dart';

/// 마이페이지 탭 (내정보 / 생체·자동로그인 / 알림설정)
class MyPage extends StatelessWidget {
  const MyPage({super.key, this.patientName, this.patientId});

  final String? patientName;
  final String? patientId;

  Future<void> _logout(BuildContext context) async {
    await SecureStorageService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (patientName == null || patientName!.isEmpty)
        ? '환자'
        : patientName!;
    final idText =
        (patientId == null || patientId!.isEmpty) ? '-' : patientId!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '마이페이지',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mascot/bomi_default.png',
                  width: 64,
                  height: 64,
                  errorBuilder: (_, __, ___) => const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.lightBlue,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '환자 ID: $idText',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.badge_outlined,
            title: '내 정보',
            onTap: () => _soon(context, '내 정보'),
          ),
          _MenuTile(
            icon: Icons.fingerprint_rounded,
            title: '생체인증 / 자동로그인',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SecuritySettingsPage(),
                ),
              );
            },
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            onTap: () => _soon(context, '알림 설정'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => _logout(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label 기능은 다음 단계에서 구현합니다.')),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.lightBlue),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
