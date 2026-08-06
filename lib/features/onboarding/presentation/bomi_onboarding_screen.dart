import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/presentation/pages/login_page.dart';
import '../data/onboarding_storage.dart';

class BomiOnboardingScreen extends StatefulWidget {
  const BomiOnboardingScreen({super.key});

  @override
  State<BomiOnboardingScreen> createState() => _BomiOnboardingScreenState();
}

class _BomiOnboardingScreenState extends State<BomiOnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isCompleting = false;

  static const Color _mainButtonColor = Color(0xFF526F91);
  static const Color _backgroundColor = Color(0xFFF7F8FC);

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      screenImagePath: 'assets/images/onboarding_ai_report.png',
      badgeText: '쉬운 AI 결과 확인',
      title: '검사 결과와 건강 변화를\n쉽게 이해할 수 있어요',
      description:
          '의료진이 확인한 검사 결과와 이전 검사 비교를\n'
          '환자의 눈높이에 맞춰 안내해 드려요.',
      accentColor: Color(0xFFD887A2),
      badgeBackgroundColor: Color(0xFFFFEAF0),
      icon: Icons.description_rounded,
      imageScale: 1.12,
    ),
    _OnboardingData(
      screenImagePath: 'assets/images/onboarding_reservation.png',
      badgeText: '간편한 진료 예약',
      title: '필요한 진료를\n편리하게 예약해요',
      description:
          '진료 일정과 의료진 정보를 확인하고\n'
          '원하는 날짜와 시간을 선택할 수 있어요.',
      accentColor: Color(0xFF6688B3),
      badgeBackgroundColor: Color(0xFFEAF2FC),
      icon: Icons.calendar_month_rounded,
      imageScale: 1.10,
    ),
    _OnboardingData(
      screenImagePath: 'assets/images/onboarding_chatbot.png',
      badgeText: '언제든 편리한 건강상담',
      title: '궁금한 건강 정보를\n보미에게 물어보세요',
      description:
          '검사 결과와 건강관리에 관한 궁금한 내용을\n'
          '보미가 이해하기 쉽게 안내해 드려요.',
      accentColor: Color(0xFF8878B8),
      badgeBackgroundColor: Color(0xFFF1EDFC),
      icon: Icons.chat_bubble_rounded,
      imageScale: 1.05,
    ),
    _OnboardingData(
      screenImagePath: 'assets/images/onboarding_health_garden.png',
      badgeText: '꾸준한 건강 습관',
      title: '건강 미션을 실천하고\n보미의 정원을 키워보세요',
      description:
          '매일 건강 미션을 완료하고\n'
          '꽃 스탬프와 다양한 보상을 모아보세요.',
      accentColor: Color(0xFF64A879),
      badgeBackgroundColor: Color(0xFFEAF7EE),
      icon: Icons.eco_rounded,
      imageScale: 0.95,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToNextPage() async {
    if (_isLastPage) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      await OnboardingStorage.setCompleted();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('온보딩 완료 정보를 저장하지 못했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _OnboardingData currentData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(data: _pages[index]);
                },
              ),
            ),

            _buildBottomArea(currentData),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 16, 2),
      child: Row(
        children: [
          const Text(
            'VENA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: Color(0xFF344054),
            ),
          ),

          const Spacer(),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isLastPage ? 0 : 1,
            child: IgnorePointer(
              ignoring: _isLastPage,
              child: TextButton(
                onPressed: _isCompleting ? null : _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF667085),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({required _OnboardingData data}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double previewHeight = (constraints.maxHeight * 0.58).clamp(
          310.0,
          440.0,
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
          child: Column(
            children: [
              _buildBadge(data),

              const SizedBox(height: 16),

              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.3,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: Color(0xFF1D2939),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: previewHeight,
                width: double.infinity,
                child: _buildFeaturePreview(data),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(_OnboardingData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: data.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 15, color: data.accentColor),

          const SizedBox(width: 6),

          Text(
            data.badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: data.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(_OnboardingData data) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 20,
          left: 16,
          child: _buildDecorationCircle(
            size: 72,
            color: data.badgeBackgroundColor,
          ),
        ),
        Positioned(
          right: 10,
          bottom: 34,
          child: _buildDecorationCircle(
            size: 50,
            color: data.badgeBackgroundColor,
          ),
        ),
        Positioned(
          right: 25,
          top: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(data.icon, size: 20, color: data.accentColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Transform.scale(
              scale: data.imageScale,
              child: Image.asset(
                data.screenImagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageError(data);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorationCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.72),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildImageError(_OnboardingData data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: data.badgeBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 32, color: data.accentColor),
          ),

          const SizedBox(height: 16),

          const Text(
            '기능 화면 이미지를 불러올 수 없습니다.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475467),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            data.screenImagePath,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea(_OnboardingData currentData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      decoration: const BoxDecoration(color: _backgroundColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageIndicator(currentData),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _isCompleting ? null : _goToNextPage,
              style: FilledButton.styleFrom(
                backgroundColor: _mainButtonColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _mainButtonColor.withValues(
                  alpha: 0.55,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: _isCompleting
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLastPage ? '베나 시작하기' : '다음',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Icon(
                          _isLastPage
                              ? Icons.favorite_rounded
                              : Icons.arrow_forward_rounded,
                          size: 19,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '건강 정보 안내를 위한 서비스이며 의료진의 진단을 대체하지 않습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color: Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(_OnboardingData currentData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final bool isSelected = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected
                ? currentData.accentColor
                : const Color(0xFFD0D5DD),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.screenImagePath,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.badgeBackgroundColor,
    required this.icon,
    this.imageScale = 1.0,
  });

  final String screenImagePath;

  final String badgeText;
  final String title;
  final String description;

  final Color accentColor;
  final Color badgeBackgroundColor;

  final IconData icon;

  final double imageScale;
}
