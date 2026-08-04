class ExamItem {
  final int examId;
  final String patientId;
  final String vesselType;
  final String? keyFrameUrl;
  final String? videoUrl;
  final String? keyFramePath;
  final String? videoPath;

  /// AI 결과 (없을 수 있음)
  final bool? hasLesion;
  final String? severityClass;
  final double? confidenceScore;
  final String? gradcamUrl;
  final int? heartScore;
  final double? maceRiskPercent;
  final String? doctorOpinion;
  final bool? isConfirmed;

  const ExamItem({
    required this.examId,
    required this.patientId,
    required this.vesselType,
    this.keyFrameUrl,
    this.videoUrl,
    this.keyFramePath,
    this.videoPath,
    this.hasLesion,
    this.severityClass,
    this.confidenceScore,
    this.gradcamUrl,
    this.heartScore,
    this.maceRiskPercent,
    this.doctorOpinion,
    this.isConfirmed,
  });

  bool get hasAiResult => severityClass != null || hasLesion != null;

  String get severityLabel {
    final raw = (severityClass ?? '').trim();
    if (raw.isEmpty) return '결과 대기';
    switch (raw.toLowerCase()) {
      case 'normal':
      case '정상':
        return '정상';
      case 'mild':
        return '경증';
      case 'moderate':
        return '중등도';
      case 'severe':
        return '중증';
      default:
        return raw;
    }
  }

  factory ExamItem.fromMaps({
    required Map<String, dynamic> exam,
    Map<String, dynamic>? ai,
  }) {
    return ExamItem(
      examId: _asInt(exam['exam_id']) ?? 0,
      patientId: exam['patient_id']?.toString() ?? '',
      vesselType: exam['vessel_type']?.toString() ?? '-',
      keyFrameUrl: exam['key_frame_url']?.toString(),
      videoUrl: exam['video_url']?.toString(),
      keyFramePath: exam['key_frame_path']?.toString(),
      videoPath: exam['video_path']?.toString(),
      hasLesion: ai == null ? null : ai['has_lesion'] == true,
      severityClass: ai?['severity_class']?.toString(),
      confidenceScore: _asDouble(ai?['confidence_score']),
      gradcamUrl: ai?['gradcam_url']?.toString(),
      heartScore: _asInt(ai?['heart_score']),
      maceRiskPercent: _asDouble(ai?['mace_risk_percent']),
      doctorOpinion: ai?['doctor_opinion']?.toString(),
      isConfirmed: ai == null ? null : ai['is_confirmed'] == true,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
