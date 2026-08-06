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

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imagePath: 'assets/images/bomi_morning.png',
      badgeText: '나의 건강 동반자',
      title: '보미와 함께\n건강관리를 시작해요',
      description:
          '검사 결과부터 일상 속 건강 습관까지,\n'
          '보미가 쉽고 친절하게 안내해 드릴게요.',
      backgroundColor: Color(0xFFF3F8FF),
      circleColor: Color(0xFFDDEEFF),
      accentColor: Color(0xFF5B9CF6),
      icon: Icons.favorite_rounded,
    ),
    _OnboardingData(
      imagePath: 'assets/images/bomi_wink.png',
      badgeText: '쉬운 검사 결과 확인',
      title: '어려운 검사 결과도\n이해하기 쉽게 확인해요',
      description:
          '의료진이 승인한 AI 검사 결과를\n'
          '환자의 눈높이에 맞춰 쉽게 설명해 드려요.',
      backgroundColor: Color(0xFFFFF7F8),
      circleColor: Color(0xFFFFE6EB),
      accentColor: Color(0xFFD88798),
      icon: Icons.description_rounded,
    ),
    _OnboardingData(
      imagePath: 'assets/images/bomi_walking_cheer.png',
      badgeText: '꾸준한 건강 습관',
      title: '건강 미션을 실천하고\n보미의 정원을 키워보세요',
      description:
          '걸음 수와 일일 건강 미션을 달성하면\n'
          '포인트와 보상을 받고 정원도 성장해요.',
      backgroundColor: Color(0xFFF4FAF6),
      circleColor: Color(0xFFDFF2E5),
      accentColor: Color(0xFF55A66F),
      icon: Icons.eco_rounded,
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

    await OnboardingStorage.setCompleted();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _OnboardingData currentData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: currentData.backgroundColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: currentData.backgroundColor,
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 16, 0),
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
                onPressed: _skipOnboarding,
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
        final double imageAreaHeight = (constraints.maxHeight * 0.52).clamp(
          270.0,
          390.0,
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            children: [
              SizedBox(
                height: imageAreaHeight,
                child: Center(child: _buildBomiImage(data)),
              ),

              const SizedBox(height: 8),

              _buildBadge(data),

              const SizedBox(height: 18),

              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: Color(0xFF1D2939),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.65,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBomiImage(_OnboardingData data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 270,
          height: 270,
          decoration: BoxDecoration(
            color: data.circleColor,
            shape: BoxShape.circle,
          ),
        ),

        Positioned(
          top: 26,
          right: 28,
          child: _buildDecorationBubble(
            color: data.accentColor.withValues(alpha: 0.14),
            iconColor: data.accentColor,
            icon: data.icon,
            size: 48,
          ),
        ),

        Positioned(
          left: 24,
          bottom: 40,
          child: _buildDecorationBubble(
            color: Colors.white.withValues(alpha: 0.78),
            iconColor: data.accentColor,
            icon: Icons.auto_awesome_rounded,
            size: 38,
          ),
        ),

        Image.asset(
          data.imagePath,
          width: 245,
          height: 245,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.favorite_rounded,
              size: 100,
              color: data.accentColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDecorationBubble({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.48, color: iconColor),
    );
  }

  Widget _buildBadge(_OnboardingData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: data.accentColor.withValues(alpha: 0.11),
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

  Widget _buildBottomArea(_OnboardingData currentData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      decoration: BoxDecoration(color: currentData.backgroundColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageIndicator(currentData),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _isCompleting ? null : _goToNextPage,
              style: FilledButton.styleFrom(
                backgroundColor: currentData.accentColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: currentData.accentColor.withValues(
                  alpha: 0.55,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                elevation: 0,
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
    required this.imagePath,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.circleColor,
    required this.accentColor,
    required this.icon,
  });

  final String imagePath;
  final String badgeText;
  final String title;
  final String description;

  final Color backgroundColor;
  final Color circleColor;
  final Color accentColor;

  final IconData icon;
}
