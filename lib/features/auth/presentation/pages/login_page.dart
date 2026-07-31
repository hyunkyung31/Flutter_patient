import 'package:flutter/material.dart';
import '../widgets/kakao_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.favorite, size: 90, color: Colors.red),
              const SizedBox(height: 20),

              const Text(
                "AI 기반 심혈관 건강관리",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 80),

              KakaoLoginButton(
                onPressed: () {
                  debugPrint("카카오 로그인");
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
