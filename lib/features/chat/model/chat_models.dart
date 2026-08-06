class ChatSessionItem {
  const ChatSessionItem({
    required this.id,
    required this.title,
    this.lastMessage = '',
    this.lastRole,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String lastMessage;
  final String? lastRole;
  final DateTime? updatedAt;

  factory ChatSessionItem.fromJson(Map<String, dynamic> json) {
    return ChatSessionItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? '새로운 상담').toString(),
      lastMessage: (json['last_message'] ?? json['lastMessage'] ?? '').toString(),
      lastRole: json['last_role']?.toString() ?? json['lastRole']?.toString(),
      updatedAt: DateTime.tryParse(
        (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      ),
    );
  }
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.role,
    required this.content,
    this.id,
    this.createdAt,
    this.isLocalPending = false,
  });

  final int? id;
  final String role; // user | assistant
  final String content;
  final DateTime? createdAt;
  final bool isLocalPending;

  bool get isUser => role == 'user';

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      role: (json['role'] ?? 'assistant').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      ),
    );
  }

  ChatMessageItem copyWith({
    String? content,
    bool? isLocalPending,
  }) {
    return ChatMessageItem(
      id: id,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      isLocalPending: isLocalPending ?? this.isLocalPending,
    );
  }
}

class ChatReply {
  const ChatReply({
    required this.sessionId,
    required this.answer,
    this.intent,
    this.risk,
    this.report,
  });

  final int sessionId;
  final String answer;
  final Map<String, dynamic>? intent;
  final Map<String, dynamic>? risk;
  final Map<String, dynamic>? report;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    return ChatReply(
      sessionId: int.tryParse(json['session_id']?.toString() ?? '') ?? 0,
      answer: (json['answer'] ?? '').toString(),
      intent: asMap(json['intent']),
      risk: asMap(json['risk']),
      report: asMap(json['report']),
    );
  }
}
