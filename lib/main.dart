import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/health_rewards/view/health_mission_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.lightBlue,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const SplashPage(),
      routes: {'/health-rewards': (context) => const HealthMissionView()},
    );
  }
}
