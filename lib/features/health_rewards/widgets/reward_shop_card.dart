import 'package:flutter/material.dart';

class RewardShopCard extends StatelessWidget {
  const RewardShopCard({
    super.key,
    required this.rewardPoint,
    required this.specialSeedCount,
    required this.hasPinkFlowerPot,
    required this.isSpecialFlowerPlanted,
    required this.onBuyFlowerPot,
    required this.onPlantSpecialSeed,
    required this.isButterflyDecorationEnabled,
    required this.onToggleButterflyDecoration,
    required this.onGoToGarden,
    required this.hasSpringGardenBackground,
    required this.isSpringGardenBackgroundEnabled,
    required this.onBuySpringGardenBackground,
    required this.onToggleSpringGardenBackground,
  });

  final int rewardPoint;
  final int specialSeedCount;

  final bool hasPinkFlowerPot;
  final bool isSpecialFlowerPlanted;
  final bool isButterflyDecorationEnabled;
  final bool hasSpringGardenBackground;
  final bool isSpringGardenBackgroundEnabled;

  final VoidCallback onToggleButterflyDecoration;
  final VoidCallback onBuyFlowerPot;
  final VoidCallback onPlantSpecialSeed;
  final VoidCallback onBuySpringGardenBackground;
  final VoidCallback onToggleSpringGardenBackground;
  final VoidCallback onGoToGarden;

  static const int flowerPotPrice = 50;
  static const int springGardenBackgroundPrice = 100;

  bool get canBuyFlowerPot {
    return !hasPinkFlowerPot && rewardPoint >= flowerPotPrice;
  }

  bool get canBuySpringGardenBackground {
    return !hasSpringGardenBackground &&
        rewardPoint >= springGardenBackgroundPrice;
  }

  bool get canPlantSpecialSeed {
    return specialSeedCount >= 1 && !isSpecialFlowerPlanted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12344054),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_rounded, color: Color(0xFF7F67B5)),
              SizedBox(width: 9),
              Text(
                '보미의 보상 상점',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '건강 미션으로 모은 보상을 정원에서 사용해 보세요.',
            style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
          ),
          const SizedBox(height: 20),

          _ShopItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFE985A8),
            iconBackgroundColor: const Color(0xFFFFEAF1),
            title: '정원 나비 장식',
            description: hasPinkFlowerPot
                ? isButterflyDecorationEnabled
                      ? '현재 건강 정원에 나비 장식이 적용되어 있어요.'
                      : '구매한 나비 장식을 다시 정원에 적용할 수 있어요.'
                : '건강 정원에 작은 나비들이 찾아와요.',

            priceText: hasPinkFlowerPot
                ? isButterflyDecorationEnabled
                      ? '사용 중'
                      : '보유 중'
                : '${RewardShopCard.flowerPotPrice}P',

            buttonText: hasPinkFlowerPot
                ? isButterflyDecorationEnabled
                      ? '장식 숨기기'
                      : '정원에 적용하기'
                : rewardPoint >= RewardShopCard.flowerPotPrice
                ? '포인트로 교환'
                : '${RewardShopCard.flowerPotPrice - rewardPoint}P 부족',

            // 구매한 뒤에는 포인트와 상관없이 숨기기·적용하기 버튼 활성화
            isEnabled: hasPinkFlowerPot ? true : canBuyFlowerPot,

            // 구매 전에는 구매 메서드, 구매 후에는 표시 상태 변경 메서드 실행
            onPressed: hasPinkFlowerPot
                ? onToggleButterflyDecoration
                : onBuyFlowerPot,
          ),

          const SizedBox(height: 12),

          // 봄꽃 배경
          _ShopItem(
            icon: Icons.landscape_rounded,
            iconColor: const Color(0xFF5FA77A),
            iconBackgroundColor: const Color(0xFFE7F6EC),
            title: '봄꽃 정원 배경',
            description: hasSpringGardenBackground
                ? isSpringGardenBackgroundEnabled
                      ? '현재 건강 정원에 봄꽃 배경이 적용되어 있어요.'
                      : '구매한 봄꽃 배경을 다시 정원에 적용할 수 있어요.'
                : '화사한 꽃과 나무가 가득한 봄 정원으로 꾸며요.',
            priceText: hasSpringGardenBackground
                ? isSpringGardenBackgroundEnabled
                      ? '사용 중'
                      : '보유 중'
                : '${RewardShopCard.springGardenBackgroundPrice}P',
            buttonText: hasSpringGardenBackground
                ? isSpringGardenBackgroundEnabled
                      ? '기본 배경으로 변경'
                      : '봄꽃 배경 적용'
                : rewardPoint >= RewardShopCard.springGardenBackgroundPrice
                ? '포인트로 교환'
                : '${RewardShopCard.springGardenBackgroundPrice - rewardPoint}P 부족',
            isEnabled: hasSpringGardenBackground
                ? true
                : canBuySpringGardenBackground,
            onPressed: hasSpringGardenBackground
                ? onToggleSpringGardenBackground
                : onBuySpringGardenBackground,
          ),

          const SizedBox(height: 12),

          _ShopItem(
            icon: Icons.local_florist_rounded,
            iconColor: const Color(0xFF7F67B5),
            iconBackgroundColor: const Color(0xFFF0EAFE),
            title: '특별 씨앗 심기',
            description: '병원 미션에서 받은 씨앗으로 희귀 꽃을 키워요.',
            priceText: isSpecialFlowerPlanted ? '성장 중' : '씨앗 1개',
            buttonText: isSpecialFlowerPlanted
                ? '심기 완료'
                : canPlantSpecialSeed
                ? '특별 씨앗 심기'
                : '특별 씨앗이 필요해요',
            isEnabled: canPlantSpecialSeed,
            onPressed: onPlantSpecialSeed,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGoToGarden,
              icon: const Icon(Icons.park_rounded, size: 21),
              label: const Text(
                '정원으로 가기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7F67B5),
                side: const BorderSide(color: Color(0xFFBBA9DE), width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.description,
    required this.priceText,
    required this.buttonText,
    required this.isEnabled,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  final String title;
  final String description;
  final String priceText;
  final String buttonText;

  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                        ),
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isEnabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFECEEF2),
                disabledForegroundColor: const Color(0xFF98A2B3),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
