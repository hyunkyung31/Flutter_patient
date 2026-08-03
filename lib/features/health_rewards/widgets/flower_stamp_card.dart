import 'package:flutter/material.dart';

class FlowerStampCard extends StatelessWidget {
  const FlowerStampCard({
    super.key,
    required this.stampCount,
    required this.requiredStampCount,
    required this.specialSeedCount,
    required this.gifticonExchangeCount,
    required this.isDailyStampClaimed,
    required this.canClaimDailyStamp,
    required this.onClaimStampPressed,
    required this.onExchangePressed,
  });

  final int stampCount;
  final int requiredStampCount;

  final int specialSeedCount;
  final int gifticonExchangeCount;

  final bool isDailyStampClaimed;
  final bool canClaimDailyStamp;

  final VoidCallback onClaimStampPressed;
  final VoidCallback onExchangePressed;

  @override
  Widget build(BuildContext context) {
    final int displayedStampCount = stampCount.clamp(0, requiredStampCount);

    final int remainingStampCount = requiredStampCount - displayedStampCount;

    final bool canExchange = displayedStampCount >= requiredStampCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1DCE5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.loyalty_rounded, color: Color(0xFFE96F9B)),
              SizedBox(width: 8),
              Text(
                '꽃 스탬프 & 보상',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            canExchange
                ? '꽃 스탬프를 모두 모았어요!'
                : '꽃 $remainingStampCount개를 더 모으면 '
                      '기프티콘으로 교환할 수 있어요.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requiredStampCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final bool isStamped = index < displayedStampCount;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isStamped
                      ? const Color(0xFFFFE8F0)
                      : const Color(0xFFF5F6F8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isStamped
                        ? const Color(0xFFF4A0BE)
                        : const Color(0xFFE1E5EA),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isStamped ? Icons.local_florist_rounded : Icons.add_rounded,
                  size: 23,
                  color: isStamped
                      ? const Color(0xFFE96F9B)
                      : const Color(0xFFC4CAD3),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                '$displayedStampCount / $requiredStampCount',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE96F9B),
                ),
              ),
              const Spacer(),
              Text(
                canExchange ? '교환 가능' : '$remainingStampCount개 남음',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF98A2B3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRewardItem(
                    icon: Icons.spa_rounded,
                    label: '특별 씨앗',
                    value: '$specialSeedCount개',
                  ),
                ),
                Container(width: 1, height: 42, color: const Color(0xFFF0DDE6)),
                Expanded(
                  child: _buildRewardItem(
                    icon: Icons.card_giftcard_rounded,
                    label: '누적 교환',
                    value: '$gifticonExchangeCount회',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canClaimDailyStamp ? onClaimStampPressed : null,
              icon: Icon(
                isDailyStampClaimed
                    ? Icons.check_rounded
                    : Icons.local_florist_rounded,
              ),
              label: Text(
                isDailyStampClaimed
                    ? '오늘의 스탬프 받기 완료'
                    : canClaimDailyStamp
                    ? '오늘의 꽃 스탬프 받기'
                    : '일일 미션을 먼저 완료해 주세요',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE96F9B),
                disabledBackgroundColor: const Color(0xFFF1E5EA),
                disabledForegroundColor: const Color(0xFFAAB2BE),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: canExchange
                ? FilledButton.icon(
                    onPressed: onExchangePressed,
                    icon: const Icon(Icons.card_giftcard_rounded),
                    label: const Text('기프티콘 교환하기'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8057B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.card_giftcard_rounded),
                    label: Text('스탬프 $remainingStampCount개 더 필요해요'),
                    style: OutlinedButton.styleFrom(
                      disabledForegroundColor: const Color(0xFFAAB2BE),
                      side: const BorderSide(color: Color(0xFFE1E5EA)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF8057B5)),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF344054),
          ),
        ),
      ],
    );
  }
}
