/// 의사 앱에서 전달된 환자용 임상 보고서
final class ClinicalReport {
  const ClinicalReport({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.department,
    required this.finalResult,
    required this.aiSummary,
    required this.xaiExplanation,
    required this.reportReady,
    required this.emrTransmitted,
    this.reportUrl,
    this.reportGeneratedAt,
    this.transmittedAt,
    this.examId,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String department;
  final String finalResult;
  final String aiSummary;
  final String xaiExplanation;
  final bool reportReady;
  final bool emrTransmitted;
  final String? reportUrl;
  final DateTime? reportGeneratedAt;
  final DateTime? transmittedAt;
  final int? examId;
  final DateTime? createdAt;

  bool get isVisibleToPatient => emrTransmitted || reportReady;

  String get title {
    if (department.trim().isNotEmpty) {
      return '$department 임상 보고서';
    }
    return '임상 보고서';
  }

  factory ClinicalReport.fromJson(Map<String, dynamic> json) {
    final aiResult = json['ai_result'];
    int? examId;
    if (aiResult is Map) {
      examId = int.tryParse(aiResult['exam_id']?.toString() ?? '');
    }
    examId ??= int.tryParse(json['exam_id']?.toString() ?? '');

    return ClinicalReport(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ??
          json['patientId']?.toString() ??
          '',
      doctorId: json['doctor_id']?.toString() ??
          json['doctorId']?.toString() ??
          '',
      doctorName: json['doctor_name']?.toString() ??
          json['doctorName']?.toString() ??
          '',
      department: json['department']?.toString() ?? '',
      finalResult: json['final_result']?.toString() ??
          json['finalResult']?.toString() ??
          '',
      aiSummary: json['ai_summary']?.toString() ?? '',
      xaiExplanation: json['xai_explanation']?.toString() ?? '',
      reportReady: _boolValue(json['report_ready'] ?? json['reportReady']),
      emrTransmitted:
          _boolValue(json['emr_transmitted'] ?? json['emrTransmitted']),
      reportUrl: _nullable(json['report_url'] ?? json['reportUrl']),
      reportGeneratedAt: _date(
        json['report_generated_at'] ?? json['reportGeneratedAt'],
      ),
      transmittedAt: _date(json['transmitted_at'] ?? json['transmittedAt']),
      examId: examId,
      createdAt: _date(json['created_at'] ?? json['createdAt']),
    );
  }

  static String? _nullable(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static bool _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime? _date(Object? value) {
    final text = _nullable(value);
    if (text == null) return null;
    return DateTime.tryParse(text)?.toLocal();
  }
}
