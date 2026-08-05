import 'package:flutter/material.dart';

import '../../chat/chat_navigation.dart';
import '../../chat/model/chat_models.dart';
import '../../chat/service/chat_service.dart';

class AiConsultationPreview extends StatefulWidget {
  const AiConsultationPreview({
    super.key,
    this.onOpenChatbot,
  });

  /// null이면 기본 openChatbot 사용
  final void Function(String? initialMessage, {int? sessionId})? onOpenChatbot;

  @override
  State<AiConsultationPreview> createState() => _AiConsultationPreviewState();
}

class _AiConsultationPreviewState extends State<AiConsultationPreview> {
  final ChatService _chatService = ChatService();

  List<ChatSessionItem> _sessions = [];
  bool _loadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final list = await _chatService.fetchSessions(limit: 5);
      if (!mounted) return;
      setState(() {
        _sessions = list;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingHistory = false;
        _historyError = e.toString().replaceFirst('Exception: ', '');
        _sessions = [];
      });
    }
  }

  void _open({String? message, int? sessionId}) {
    final opener = widget.onOpenChatbot;
    if (opener != null) {
      opener(message, sessionId: sessionId);
      return;
    }
    openChatbot(
      context,
      initialMessage: message,
      sessionId: sessionId,
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1D2939),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildQuestionInput(),
          const SizedBox(height: 16),
          _buildHistoryHeader(),
          const SizedBox(height: 4),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF4FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 21,
            color: Color(0xFF5B9CF6),
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 심혈관 건강 상담',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D2939),
                ),
              ),
              SizedBox(height: 3),
              Text(
                '건강과 검사 결과를 보미에게 물어보세요.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => _open(),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'AI 상담',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3478D4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionInput() {
    return Material(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE3ED)),
          ),
          padding: const EdgeInsets.only(left: 4, right: 5),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.search_rounded, size: 18, color: Color(0xFF667085)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '궁금한 점은 보미에게 물어보세요...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _open(),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9CF6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(36, 36),
                  maximumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF4FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.history_rounded,
            size: 16,
            color: Color(0xFF5B9CF6),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            '최근 상담 기록',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF344054),
            ),
          ),
        ),
        TextButton(
          onPressed: _loadingHistory ? null : _loadHistory,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 28),
          ),
          child: Text(
            _loadingHistory ? '불러오는 중' : '새로고침',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF98A2B3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_loadingHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    if (_historyError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
        child: Text(
          '상담 기록을 불러오지 못했어요.\n(서버에 history API가 배포됐는지 확인해 주세요)\n$_historyError',
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF98A2B3),
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Text(
          '아직 상담 기록이 없어요.\n위에서 질문을 입력해 보미와 대화해 보세요.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: Color(0xFF98A2B3),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_sessions.length, (index) {
        final item = _sessions[index];
        final isLast = index == _sessions.length - 1;
        final preview = item.lastMessage.trim().isEmpty
            ? item.title
            : item.lastMessage.trim().replaceAll('\n', ' ');

        return Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _open(sessionId: item.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: index == 0
                                ? const Color(0xFF5B9CF6)
                                : const Color(0xFF98A2B3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF344054),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF98A2B3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 19,
                        color: Color(0xFF98A2B3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isLast)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 40,
                color: Color(0xFFEEF1F5),
              ),
          ],
        );
      }),
    );
  }
}
