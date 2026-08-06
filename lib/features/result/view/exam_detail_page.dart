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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('기본 정보'),
                const SizedBox(height: 10),
                _kv('검사 ID', '${item.examId}'),
                _kv('환자 ID', item.patientId),
                _kv('혈관 유형', item.vesselType),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE6EDF5)),
                const SizedBox(height: 14),
                const _SectionTitle('AI 결과'),
                const SizedBox(height: 10),
                if (!item.hasAiResult)
                  const Expanded(
                    child: Center(
                      child: Text(
                        '아직 AI 결과가 없습니다.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
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
                  _kv('Heart Score', item.heartScore?.toString() ?? '-'),
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
                    const SizedBox(height: 6),
                    const Text(
                      '의사 소견',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          item.doctorOpinion!,
                          style: const TextStyle(
                            height: 1.45,
                            fontSize: 13.5,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                ],
              ],
            ),
          ),
        ),
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
            width: 96,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }
}
