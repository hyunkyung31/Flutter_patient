import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/exam_item.dart';
import '../repository/exam_history_repository.dart';
import 'exam_detail_page.dart';

/// 검사 이력 목록 (서버 연동)
class ExamHistoryPage extends StatefulWidget {
  const ExamHistoryPage({super.key, this.patientId});

  final String? patientId;

  @override
  State<ExamHistoryPage> createState() => _ExamHistoryPageState();
}

class _ExamHistoryPageState extends State<ExamHistoryPage> {
  final _repo = ExamHistoryRepository();
  late Future<List<ExamItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMyExams(patientId: widget.patientId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.fetchMyExams(patientId: widget.patientId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              '검사 이력',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '최근 검사와 AI 결과 요약입니다.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<ExamItem>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _ErrorView(
                    message: snap.error.toString(),
                    onRetry: _reload,
                  );
                }
                final items = snap.data ?? const <ExamItem>[];
                if (items.isEmpty) {
                  return const _EmptyView();
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _ExamCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExamDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.item, required this.onTap});

  final ExamItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final confirmed = item.isConfirmed == true;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBlue),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.biotech_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검사 #${item.examId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '혈관: ${item.vesselType}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.hasAiResult
                        ? 'AI: ${item.severityLabel}'
                            '${item.confidenceScore != null ? ' · ${(item.confidenceScore! * 100).toStringAsFixed(0)}%' : ''}'
                        : 'AI 결과 없음',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: item.hasAiResult
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  confirmed ? Icons.verified_rounded : Icons.chevron_right_rounded,
                  color: confirmed ? const Color(0xFF059669) : AppColors.textSecondary,
                ),
                if (confirmed)
                  const Text(
                    '확정',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascot/bomi_think.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.assignment_rounded,
                size: 72,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 등록된 검사 이력이 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
