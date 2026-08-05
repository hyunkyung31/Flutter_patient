import 'package:flutter/material.dart';

class AiConsultationPreview extends StatefulWidget {
  const AiConsultationPreview({super.key, this.onQuestionSubmitted});

  final ValueChanged<String>? onQuestionSubmitted;

  @override
  State<AiConsultationPreview> createState() => _AiConsultationPreviewState();
}

class _AiConsultationPreviewState extends State<AiConsultationPreview> {
  final TextEditingController _questionController = TextEditingController();

  final FocusNode _questionFocusNode = FocusNode();

  final List<String> _popularQuestions = const [
    '운동하면 숨이 차요',
    '혈압약은 언제 먹나요?',
    '검사 결과 쉽게 설명해주세요.',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _questionFocusNode.dispose();

    super.dispose();
  }

  void _submitQuestion(String question) {
    final String trimmedQuestion = question.trim();

    if (trimmedQuestion.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('보미에게 궁금한 내용을 입력해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      _questionFocusNode.requestFocus();
      return;
    }

    _questionFocusNode.unfocus();

    widget.onQuestionSubmitted?.call(trimmedQuestion);

    if (widget.onQuestionSubmitted == null) {
      debugPrint('AI 상담 질문: $trimmedQuestion');
    }
  }

  void _selectPopularQuestion(String question) {
    _submitQuestion(question);
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

          _buildPopularQuestionHeader(),

          const SizedBox(height: 4),

          _buildPopularQuestionList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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

        Container(
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
      ],
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE3ED)),
      ),
      child: TextField(
        controller: _questionController,
        focusNode: _questionFocusNode,
        textInputAction: TextInputAction.send,
        onSubmitted: _submitQuestion,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF344054),
        ),
        decoration: InputDecoration(
          hintText: '궁금한 점은 보미에게 물어보세요...',
          hintStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF98A2B3),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: Color(0xFF667085),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: IconButton(
              onPressed: () {
                _submitQuestion(_questionController.text);
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF5B9CF6),
                foregroundColor: Colors.white,
                minimumSize: const Size(36, 36),
                maximumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPopularQuestionHeader() {
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
            Icons.trending_up_rounded,
            size: 16,
            color: Color(0xFF5B9CF6),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            '오늘 많이 물어본 질문',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF344054),
            ),
          ),
        ),
        const Text(
          '실시간',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF98A2B3),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularQuestionList() {
    return Column(
      children: List.generate(_popularQuestions.length, (index) {
        final String question = _popularQuestions[index];

        final bool isLast = index == _popularQuestions.length - 1;

        return Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _selectPopularQuestion(question);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
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
                        child: Text(
                          question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF344054),
                          ),
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
