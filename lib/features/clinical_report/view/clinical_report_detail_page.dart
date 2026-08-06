import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/clinical_report.dart';
import '../repository/clinical_report_repository.dart';

class ClinicalReportDetailPage extends StatefulWidget {
  const ClinicalReportDetailPage({super.key, required this.report});

  final ClinicalReport report;

  @override
  State<ClinicalReportDetailPage> createState() =>
      _ClinicalReportDetailPageState();
}

class _ClinicalReportDetailPageState extends State<ClinicalReportDetailPage> {
  final _repo = ClinicalReportRepository();
  late ClinicalReport _report;
  bool _loadingDetail = false;
  bool _loadingPdf = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final id = int.tryParse(_report.id);
    if (id == null) return;

    setState(() => _loadingDetail = true);
    try {
      final latest = await _repo.fetchReport(id);
      if (!mounted) return;
      setState(() => _report = latest);
    } catch (_) {
      // 목록 데이터로 표시 유지
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _downloadPdf() async {
    final id = int.tryParse(_report.id);
    if (id == null) {
      _toast('보고서 ID가 올바르지 않습니다.');
      return;
    }

    setState(() => _loadingPdf = true);
    try {
      final bytes = await _repo.downloadPdf(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PdfPreviewPage(
            title: _report.title,
            bytes: bytes,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingPdf = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '정보 없음';
    return DateFormat('yyyy.MM.dd HH:mm').format(value);
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
        actions: [
          if (_loadingDetail)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _SectionCard(
            title: '보고서 정보',
            children: [
              _Row(label: '제목', value: _report.title),
              _Row(
                label: '담당의',
                value: _report.doctorName.trim().isEmpty
                    ? (_report.doctorId.isEmpty ? '정보 없음' : _report.doctorId)
                    : _report.doctorName,
              ),
              if (_report.examId != null)
                _Row(label: '검사 ID', value: '${_report.examId}'),
              _Row(
                label: '생성 시각',
                value: _formatDate(_report.reportGeneratedAt),
              ),
              _Row(
                label: '전달 시각',
                value: _formatDate(_report.transmittedAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'AI 보조 분석 결과',
            children: [
              SelectableText(
                _report.aiSummary.trim().isEmpty
                    ? '등록된 AI 분석 결과가 없습니다.'
                    : _report.aiSummary,
                style: const TextStyle(height: 1.55, color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'AI 분석에 대한 안내',
            children: [
              SelectableText(
                _report.xaiExplanation.trim().isEmpty
                    ? '등록된 안내가 없습니다.'
                    : _report.xaiExplanation,
                style: const TextStyle(height: 1.55, color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '최종 의료진 소견',
            children: [
              SelectableText(
                _report.finalResult.trim().isEmpty
                    ? '등록된 최종 소견이 없습니다.'
                    : _report.finalResult,
                style: const TextStyle(
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _loadingPdf ? null : _downloadPdf,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _loadingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _loadingPdf ? 'PDF 불러오는 중...' : 'PDF로 보기',
                style: const TextStyle(fontWeight: FontWeight.w800),
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
              fontWeight: FontWeight.w800,
              fontSize: 15,
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PDF 바이트를 단순 안내 + 용량 표시로 보여준다.
/// (별도 PDF 뷰어 패키지 없이 수신 확인용)
class _PdfPreviewPage extends StatelessWidget {
  const _PdfPreviewPage({required this.title, required this.bytes});

  final String title;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final kb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PDF 수신 확인'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.picture_as_pdf_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'PDF 파일을 성공적으로 받았습니다.\n크기: $kb KB',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '앱 내 PDF 뷰어는 다음 단계에서 연결할 수 있습니다.\n'
                '지금은 보고서 본문과 PDF 수신 여부를 확인할 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
