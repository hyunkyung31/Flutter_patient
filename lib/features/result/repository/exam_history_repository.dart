import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../model/exam_item.dart';

class ExamHistoryRepository {
  /// GET /api/patients/{patientId}/ → examinations + ai_results 병합
  Future<List<ExamItem>> fetchMyExams({String? patientId}) async {
    final id = patientId ?? await SecureStorageService.getPatientId();
    if (id == null || id.isEmpty) {
      throw Exception('환자 ID가 없습니다. 다시 로그인해주세요.');
    }

    try {
      final res = await ApiClient.dio.get(ApiEndpoints.patientDetail(id));
      final data = res.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }

      final examsRaw = data['examinations'];
      final aiRaw = data['ai_results'];

      final aiByExam = <int, Map<String, dynamic>>{};
      if (aiRaw is List) {
        for (final item in aiRaw) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final examId = int.tryParse(map['exam_id']?.toString() ?? '');
          if (examId == null) continue;
          aiByExam[examId] = map;
        }
      }

      final result = <ExamItem>[];
      if (examsRaw is List) {
        for (final item in examsRaw) {
          if (item is! Map) continue;
          final exam = Map<String, dynamic>.from(item);
          final examId = int.tryParse(exam['exam_id']?.toString() ?? '') ?? 0;
          result.add(
            ExamItem.fromMaps(exam: exam, ai: aiByExam[examId]),
          );
        }
      }

      result.sort((a, b) => b.examId.compareTo(a.examId)); // 최신 먼저
      return result;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data;
      final msg = (detail is Map && detail['detail'] != null)
          ? detail['detail'].toString()
          : (e.message ?? e.type.toString());
      throw Exception('검사 이력 조회 실패${status != null ? ' ($status)' : ''}: $msg');
    }
  }
}
