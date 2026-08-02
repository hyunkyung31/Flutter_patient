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
  });

  final int rewardPoint;
  final int specialSeedCount;

  final bool hasPinkFlowerPot;
  final bool isSpecialFlowerPlanted;

  final VoidCallback onBuyFlowerPot;
  final VoidCallback onPlantSpecialSeed;

  static const int flowerPotPrice = 50;

  bool get canBuyFlowerPot {
    return rewardPoint >= flowerPotPrice && !hasPinkFlowerPot;
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
            icon: Icons.yard_rounded,
            iconColor: const Color(0xFFE46A98),
            iconBackgroundColor: const Color(0xFFFFEAF1),
            title: '분홍 꽃 화분',
            description: '정원을 꾸밀 수 있는 새로운 화분이에요.',
            priceText: hasPinkFlowerPot
                ? '보유 중'
                : '${RewardShopCard.flowerPotPrice}P',
            buttonText: hasPinkFlowerPot
                ? '구매 완료'
                : canBuyFlowerPot
                ? '포인트로 교환'
                : '${RewardShopCard.flowerPotPrice - rewardPoint}P 부족',
            isEnabled: canBuyFlowerPot,
            onPressed: onBuyFlowerPot,
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
