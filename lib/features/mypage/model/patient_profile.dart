class PatientProfile {
  const PatientProfile({
    required this.patientId,
    required this.patientName,
    this.gender,
    this.age,
    this.primaryDoctorId,
    this.primaryDoctorName,
    this.chiefComplaint,
    this.ecgResult,
    this.ecgImageUrl,
    this.troponinTLevel,
    this.historyScore,
    this.riskFactorsCount,
    this.examCount = 0,
  });

  final String patientId;
  final String patientName;
  final String? gender;
  final int? age;
  final String? primaryDoctorId;
  final String? primaryDoctorName;
  final String? chiefComplaint;
  final String? ecgResult;
  final String? ecgImageUrl;
  final double? troponinTLevel;
  final int? historyScore;
  final int? riskFactorsCount;
  final int examCount;

  String get genderLabel {
    switch ((gender ?? '').toUpperCase()) {
      case 'M':
      case 'MALE':
        return '남성';
      case 'F':
      case 'FEMALE':
        return '여성';
      default:
        return (gender == null || gender!.isEmpty) ? '-' : gender!;
    }
  }

  factory PatientProfile.fromPatientMap(
    Map<String, dynamic> json, {
    String? doctorName,
    int examCount = 0,
  }) {
    return PatientProfile(
      patientId: (json['patient_id'] ?? json['patientId'] ?? '').toString(),
      patientName:
          (json['patient_name'] ?? json['patientName'] ?? '').toString(),
      gender: json['gender']?.toString(),
      age: int.tryParse(json['age']?.toString() ?? ''),
      primaryDoctorId:
          (json['primary_doctor_id'] ?? json['primaryDoctorId'])?.toString(),
      primaryDoctorName: doctorName,
      chiefComplaint:
          (json['chief_complaint'] ?? json['chiefComplaint'])?.toString(),
      ecgResult: (json['ecg_result'] ?? json['ecgResult'])?.toString(),
      ecgImageUrl: (json['ecg_image_url'] ?? json['ecgImageUrl'])?.toString(),
      troponinTLevel: double.tryParse(
        (json['troponin_t_level'] ?? json['troponinTLevel'])?.toString() ?? '',
      ),
      historyScore: int.tryParse(
        (json['history_score'] ?? json['historyScore'])?.toString() ?? '',
      ),
      riskFactorsCount: int.tryParse(
        (json['risk_factors_count'] ?? json['riskFactorsCount'])?.toString() ??
            '',
      ),
      examCount: examCount,
    );
  }
}
