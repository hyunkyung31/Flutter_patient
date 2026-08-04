import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../auth/presentation/pages/login_page.dart';
import 'package:patient_app/core/storage/secure_storage.dart';

/// 임시 홈 화면 (로그인/회원가입 성공 후 진입)
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.patientName});

  final String? patientName;

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VENA'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '로그아웃',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, $name님',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '카카오 로그인에 성공했습니다.\n홈 화면은 이후 기능 화면으로 연결됩니다.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBlue),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인 상태',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '토큰이 기기에 안전하게 저장되었습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
