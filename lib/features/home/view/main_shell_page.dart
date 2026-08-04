import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../mypage/view/my_page.dart';
import '../../reservation/view/reservation_page.dart';
import '../../result/view/exam_history_page.dart';
import '../../wayfinding/view/wayfinding_page.dart';
import 'home_page.dart';

/// 환자앱 메인 뼈대 (하단 탭 5개)
class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    this.patientName,
    this.initialIndex = 0,
  });

  final String? patientName;
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        patientName: widget.patientName,
        onOpenTab: _goToTab,
      ),
      const ReservationPage(),
      const ExamHistoryPage(),
      const WayfindingPage(),
      MyPage(patientName: widget.patientName),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
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
            selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: '예약',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: '검사',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: '길찾기',
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
