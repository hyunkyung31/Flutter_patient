import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/exam_item.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({super.key, required this.item});

  final ExamItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('검사 #${item.examId}'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: '기본 정보',
            children: [
              _kv('검사 ID', '${item.examId}'),
              _kv('환자 ID', item.patientId),
              _kv('혈관 유형', item.vesselType),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'AI 결과',
            children: [
              if (!item.hasAiResult)
                const Text(
                  '아직 AI 결과가 없습니다.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else ...[
                _kv('판정', item.severityLabel),
                _kv(
                  '병변',
                  item.hasLesion == null
                      ? '-'
                      : (item.hasLesion! ? '있음' : '없음'),
                ),
                _kv(
                  '신뢰도',
                  item.confidenceScore == null
                      ? '-'
                      : '${(item.confidenceScore! * 100).toStringAsFixed(1)}%',
                ),
                _kv(
                  'Heart Score',
                  item.heartScore?.toString() ?? '-',
                ),
                _kv(
                  'MACE 위험도',
                  item.maceRiskPercent == null
                      ? '-'
                      : '${item.maceRiskPercent!.toStringAsFixed(1)}%',
                ),
                _kv(
                  '의사 확정',
                  item.isConfirmed == true ? '확정됨' : '미확정',
                ),
                if (item.doctorOpinion != null &&
                    item.doctorOpinion!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '의사 소견',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.doctorOpinion!,
                    style: const TextStyle(
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (item.gradcamUrl != null && item.gradcamUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Grad-CAM',
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.gradcamUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          '이미지를 불러오지 못했습니다.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.keyFrameUrl != null && item.keyFrameUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Key Frame',
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.keyFrameUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          '이미지를 불러오지 못했습니다.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
