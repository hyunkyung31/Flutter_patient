import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../model/chat_models.dart';

class ChatService {
  /// GPT 응답이 길어질 수 있어 별도 타임아웃
  static const Duration _chatTimeout = Duration(seconds: 90);

  Future<ChatReply> sendMessage({
    required String message,
    int? sessionId,
    int? examId,
    String? patientId,
  }) async {
    final id = (patientId ?? await SecureStorageService.getPatientId())?.trim();
    if (id == null || id.isEmpty) {
      throw Exception('환자 ID가 없습니다. 다시 로그인해주세요.');
    }

    try {
      final res = await ApiClient.dio.post(
        ApiEndpoints.chat,
        data: {
          'patient_id': id,
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
          if (examId != null) 'exam_id': examId,
        },
        options: Options(
          sendTimeout: _chatTimeout,
          receiveTimeout: _chatTimeout,
        ),
      );
      final data = res.data;
      if (data is! Map) {
        throw Exception('챗봇 응답 형식이 올바르지 않습니다.');
      }
      final reply = ChatReply.fromJson(Map<String, dynamic>.from(data));
      if (reply.answer.isEmpty) {
        throw Exception('챗봇 답변이 비어 있습니다.');
      }
      return reply;
    } on DioException catch (e) {
      throw Exception(_mapError(e, fallback: '챗봇 응답을 받지 못했습니다.'));
    }
  }

  Future<List<ChatSessionItem>> fetchSessions({int limit = 20}) async {
    try {
      final res = await ApiClient.dio.get(
        ApiEndpoints.chatbotSessions,
        queryParameters: {'limit': limit},
      );
      final data = res.data;
      if (data is! Map) return [];
      final results = data['results'];
      if (results is! List) return [];
      return results
          .whereType<Map>()
          .map((e) => ChatSessionItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id > 0)
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e, fallback: '상담 기록을 불러오지 못했습니다.'));
    }
  }

  Future<List<ChatMessageItem>> fetchSessionMessages(int sessionId) async {
    try {
      final res = await ApiClient.dio.get(
        ApiEndpoints.chatbotSessionDetail(sessionId),
      );
      final data = res.data;
      if (data is! Map) return [];
      final messages = data['messages'];
      if (messages is! List) return [];
      return messages
          .whereType<Map>()
          .map((e) => ChatMessageItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e, fallback: '대화 내용을 불러오지 못했습니다.'));
    }
  }

  String _mapError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null && detail.toString().trim().isNotEmpty) {
        return detail.toString();
      }
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return '응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
    }
    final status = e.response?.statusCode;
    if (status != null) return '$fallback ($status)';
    return fallback;
  }
}
