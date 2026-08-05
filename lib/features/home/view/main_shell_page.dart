import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../chat/chat_navigation.dart';
import '../../health_rewards/view/health_mission_view.dart';
import '../../mypage/view/my_page.dart';
import '../../reservation/view/reservation_page.dart';
import '../../result/view/exam_history_page.dart';
import 'home_page.dart';

/// 하단탭: 홈 / 예약 / 검사 / 건강정원 / 마이
class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    this.patientName,
    this.patientId,
    this.initialIndex = 0,
  });

  final String? patientName;
  final String? patientId;
  final int initialIndex;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  void _goToTab(int index) {
    setState(() => _index = index.clamp(0, 4));
  }

  void _openChatbot() {
    openChatbot(context);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        patientName: widget.patientName,
        onOpenTab: _goToTab,
      ),
      const ReservationPage(),
      ExamHistoryPage(patientId: widget.patientId),
      const HealthMissionView(),
      MyPage(
        patientName: widget.patientName,
        patientId: widget.patientId,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChatbot,
        backgroundColor: AppColors.accent,
        elevation: 4,
        child: ClipOval(
          child: Image.asset(
            'assets/images/bomi_wink.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/bomi_cheer.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightBlue,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: '예약',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon:
                Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: '검사',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon:
                Icon(Icons.local_florist_rounded, color: AppColors.primary),
            label: '건강정원',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
