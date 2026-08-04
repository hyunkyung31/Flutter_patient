import 'package:flutter/material.dart';

class RewardStatusCard extends StatelessWidget {
  const RewardStatusCard({
    super.key,
    required this.flowerStampCount,
    required this.requiredFlowerStampCount,
    required this.rewardPoint,
    required this.specialSeedCount,
    required this.areDailyMissionsCompleted,
    required this.isDailyStampClaimed,
    required this.onClaimStamp,
    required this.gifticonExchangeCount,
    required this.onExchangeGifticon,
  });

  final int flowerStampCount;
  final int requiredFlowerStampCount;
  final int rewardPoint;
  final int specialSeedCount;

  final bool areDailyMissionsCompleted;
  final bool isDailyStampClaimed;

  final int gifticonExchangeCount;

  final VoidCallback onClaimStamp;
  final VoidCallback onExchangeGifticon;

  bool get canClaimStamp {
    return areDailyMissionsCompleted && !isDailyStampClaimed;
  }

  bool get canExchangeGifticon {
    return flowerStampCount >= requiredFlowerStampCount;
  }

  int get remainingStampCount {
    final int remaining = requiredFlowerStampCount - flowerStampCount;

    return remaining < 0 ? 0 : remaining;
  }

  String get exchangeButtonText {
    if (canExchangeGifticon) {
      return '기프티콘 교환하기';
    }

    return '스탬프 $remainingStampCount개 더 필요해요';
  }

  String get buttonText {
    if (isDailyStampClaimed) {
      return '오늘의 스탬프 받기 완료';
    }

    if (!areDailyMissionsCompleted) {
      return '일일 미션을 모두 완료해 주세요';
    }

    return '꽃 스탬프 받기';
  }

  @override
  Widget build(BuildContext context) {
    final double stampProgress = requiredFlowerStampCount == 0
        ? 0
        : (flowerStampCount / requiredFlowerStampCount).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7FA), Color(0xFFF8F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14344054),
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
              Icon(Icons.card_giftcard_rounded, color: Color(0xFFE46A98)),
              SizedBox(width: 9),
              Text(
                '나의 건강 보상',
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
            '건강 미션으로 꽃과 보상을 모아보세요.',
            style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _RewardItem(
                  icon: Icons.local_florist_rounded,
                  title: '꽃 스탬프',
                  value:
                      '$flowerStampCount / '
                      '$requiredFlowerStampCount',
                  iconColor: const Color(0xFFE46A98),
                  backgroundColor: const Color(0xFFFFEAF1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RewardItem(
                  icon: Icons.paid_rounded,
                  title: '보유 포인트',
                  value: '${rewardPoint}P',
                  iconColor: const Color(0xFFE09A2D),
                  backgroundColor: const Color(0xFFFFF2D8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RewardItem(
                  icon: Icons.spa_rounded,
                  title: '특별 씨앗',
                  value: '$specialSeedCount개',
                  iconColor: const Color(0xFF7F67B5),
                  backgroundColor: const Color(0xFFF0EAFE),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '기프티콘 교환까지',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475467),
                ),
              ),
              Text(
                '$flowerStampCount/'
                '$requiredFlowerStampCount',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE46A98),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: stampProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1E5EA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE46A98),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.redeem_rounded,
                size: 16,
                color: Color(0xFF7F67B5),
              ),
              const SizedBox(width: 5),
              Text(
                '누적 교환 $gifticonExchangeCount회',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7F67B5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canClaimStamp ? onClaimStamp : null,
              icon: Icon(
                isDailyStampClaimed
                    ? Icons.check_rounded
                    : Icons.local_florist_rounded,
              ),
              label: Text(buttonText),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE46A98),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF0E4E9),
                disabledForegroundColor: const Color(0xFF98A2B3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canExchangeGifticon ? onExchangeGifticon : null,
              icon: const Icon(Icons.card_giftcard_rounded),
              label: Text(exchangeButtonText),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7F67B5),
                disabledForegroundColor: const Color(0xFF98A2B3),
                side: BorderSide(
                  color: canExchangeGifticon
                      ? const Color(0xFF7F67B5)
                      : const Color(0xFFD0D5DD),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  const _RewardItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D2939),
            ),
          ),
        ],
      ),
    );
  }
}
