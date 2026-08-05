import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../model/patient_profile.dart';

class PatientProfileRepository {
  /// GET /api/patients/{id}/ 의 patient 객체 + 담당의 이름 보강
  Future<PatientProfile> fetchMyProfile({String? patientId}) async {
    final id = (patientId ?? await SecureStorageService.getPatientId())?.trim();
    if (id == null || id.isEmpty) {
      throw Exception('환자 ID가 없습니다. 다시 로그인해주세요.');
    }

    try {
      final res = await ApiClient.dio.get(ApiEndpoints.patientDetail(id));
      final data = res.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }

      final patientRaw = data['patient'];
      final Map<String, dynamic> patientMap;
      if (patientRaw is Map) {
        patientMap = Map<String, dynamic>.from(patientRaw);
      } else {
        // 혹시 patient 래핑 없이 오는 경우
        patientMap = Map<String, dynamic>.from(data);
      }

      final exams = data['examinations'];
      final examCount = exams is List ? exams.length : 0;

      final doctorId =
          (patientMap['primary_doctor_id'] ?? patientMap['primaryDoctorId'])
              ?.toString();
      final doctorName = await _resolveDoctorName(doctorId);

      final profile = PatientProfile.fromPatientMap(
        patientMap,
        doctorName: doctorName,
        examCount: examCount,
      );

      // 로컬 캐시 갱신
      if (profile.patientName.isNotEmpty) {
        await SecureStorageService.savePatientProfile(
          patientId: profile.patientId.isNotEmpty ? profile.patientId : id,
          patientName: profile.patientName,
        );
      }

      return profile;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data;
      final msg = (detail is Map && detail['detail'] != null)
          ? detail['detail'].toString()
          : (e.message ?? e.type.toString());
      throw Exception(
        '내 정보 조회 실패${status != null ? ' ($status)' : ''}: $msg',
      );
    }
  }

  Future<String?> _resolveDoctorName(String? doctorId) async {
    if (doctorId == null || doctorId.isEmpty) return null;
    try {
      final res = await ApiClient.dio.get(ApiEndpoints.doctors);
      final data = res.data;
      if (data is! List) return null;
      for (final item in data) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = (map['doctor_id'] ?? map['doctorId'])?.toString();
        if (id == doctorId) {
          return (map['doctor_name'] ?? map['doctorName'])?.toString();
        }
      }
    } catch (_) {
      // 의사 이름 조회 실패해도 프로필은 표시
    }
    return null;
  }
}
