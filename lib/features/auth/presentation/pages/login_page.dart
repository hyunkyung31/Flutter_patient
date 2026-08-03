import 'package:flutter/material.dart';

import '../widgets/kakao_login_button.dart';
import '../../data/datasource/kakao_auth_service.dart';
import 'package:patient_app/core/storage/secure_storage.dart';

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
                onPressed: () async {
                  debugPrint("버튼클릭");
                  try {
                    final result = await KakaoAuthService().loginWithKakao();

                    if (!context.mounted) return;

                    // 신규 회원
                    if (result.isNewUser) {
                      debugPrint("신규 회원");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("신규 회원입니다. 회원가입을 진행해주세요."),
                        ),
                      );

                      // TODO
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const SignupPage(),
                      //   ),
                      // );

                      return;
                    }

                    // 기존 회원
                    debugPrint("기존 회원 로그인");

                    await SecureStorageService.saveToken(
                      access: result.access,
                      refresh: result.refresh,
                    );

                    debugPrint("로그인 성공");

                    debugPrint("Access Token : ${result.access}");
                    debugPrint("Refresh Token : ${result.refresh}");
                    debugPrint("Patient ID : ${result.patientId}");
                    debugPrint("Patient Name : ${result.patientName}");

                    if (!context.mounted) return;

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const HomePage(),
                    //   ),
                    // );
                  } catch (e) {
                    debugPrint("로그인 실패 : $e");

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("로그인 실패\n$e")));
                  }
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
