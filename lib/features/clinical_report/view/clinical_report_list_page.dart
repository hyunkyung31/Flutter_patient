import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/clinical_report.dart';
import '../repository/clinical_report_repository.dart';
import 'clinical_report_detail_page.dart';

/// 의사에게 전달받은 임상 보고서 목록
class ClinicalReportListPage extends StatefulWidget {
  const ClinicalReportListPage({super.key});

  @override
  State<ClinicalReportListPage> createState() => _ClinicalReportListPageState();
}

class _ClinicalReportListPageState extends State<ClinicalReportListPage> {
  final _repo = ClinicalReportRepository();
  late Future<List<ClinicalReport>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMyReports();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.fetchMyReports();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('임상 보고서'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: FutureBuilder<List<ClinicalReport>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: '보고서를 불러오지 못했습니다',
              message: snap.error.toString().replaceFirst('Exception: ', ''),
              actionLabel: '다시 시도',
              onAction: _reload,
            );
          }

          final items = snap.data ?? const <ClinicalReport>[];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  _MessageState(
                    icon: Icons.description_outlined,
                    title: '아직 전달된 보고서가 없습니다',
                    message:
                        '의사 앱 SIGN OFF 상세에서 「환자에게 보고서 전달」까지 완료되어야 여기에 표시됩니다.\n'
                        '또 서버에 /api/emr-signoffs/me/ 가 필요할 수 있습니다.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ReportCard(
                  report: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClinicalReportDetailPage(report: item),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final ClinicalReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final when = report.transmittedAt ??
        report.reportGeneratedAt ??
        report.createdAt;
    final whenText = when == null
        ? '일시 정보 없음'
        : DateFormat('yyyy.MM.dd HH:mm').format(when);

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBlue),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      report.emrTransmitted ? '전달됨' : '확인 가능',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (report.doctorName.trim().isNotEmpty)
                    report.doctorName
                  else if (report.doctorId.trim().isNotEmpty)
                    report.doctorId,
                  whenText,
                ].where((e) => e.trim().isNotEmpty).join(' · '),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (report.finalResult.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  report.finalResult,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => onAction!(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
