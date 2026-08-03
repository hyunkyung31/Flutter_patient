import 'package:flutter/material.dart';

class KakaoLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const KakaoLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0x99FEE500),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                "카카오로 시작하기",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}
