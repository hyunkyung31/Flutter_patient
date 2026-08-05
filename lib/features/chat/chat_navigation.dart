import 'package:flutter/material.dart';

import '../model/chat_models.dart';
import '../service/chat_service.dart';
import '../view/chatbot_page.dart';

/// 홈/FAB 등에서 챗봇 화면으로 이동
Future<T?> openChatbot<T>(
  BuildContext context, {
  String? initialMessage,
  int? sessionId,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (_) => ChatbotPage(
        initialMessage: initialMessage,
        sessionId: sessionId,
      ),
    ),
  );
}

/// 홈 미리보기용 최근 세션 로드 헬퍼
Future<List<ChatSessionItem>> loadRecentChatSessions({int limit = 5}) {
  return ChatService().fetchSessions(limit: limit);
}
