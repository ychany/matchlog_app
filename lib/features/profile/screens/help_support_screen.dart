import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _textPrimary = Color(0xFF111827);
  static const _background = Color(0xFFF9FAFB);
  static const _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '도움말 및 지원',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ 섹션
              _buildSectionHeader(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: '자주 묻는 질문',
              ),
              const SizedBox(height: 12),
              _buildFAQSection(),

              const SizedBox(height: 24),

              // 문의하기 섹션
              _buildSectionHeader(
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFF10B981),
                title: '문의하기',
              ),
              const SizedBox(height: 12),
              _buildContactSection(context),

              const SizedBox(height: 24),

              // 앱 정보 섹션
              _buildSectionHeader(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: '앱 정보',
              ),
              const SizedBox(height: 12),
              _buildAppInfoSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': '직관 기록은 어떻게 추가하나요?',
        'answer': '홈 화면이나 직관 일기 탭에서 + 버튼을 눌러 새로운 직관 기록을 추가할 수 있습니다. 경기 일정에서 원하는 경기를 선택한 후 "직관 기록" 버튼을 눌러도 됩니다.',
      },
      {
        'question': '즐겨찾기 팀은 어떻게 추가하나요?',
        'answer': '내 정보 탭에서 즐겨찾기 섹션의 "관리" 버튼을 누르거나, 팀 상세 페이지에서 하트 버튼을 눌러 즐겨찾기에 추가할 수 있습니다.',
      },
      {
        'question': '경기 일정은 어디서 확인하나요?',
        'answer': '하단 메뉴의 "일정" 탭에서 캘린더 형태로 경기 일정을 확인할 수 있습니다. 리그별로 필터링도 가능합니다.',
      },
      {
        'question': '알림은 어떻게 설정하나요?',
        'answer': '내 정보 > 알림 설정에서 경기 시작 알림, 즐겨찾기 팀 경기 알림 등을 설정할 수 있습니다.',
      },
      {
        'question': '지원하는 리그는 무엇인가요?',
        'answer': 'EPL(잉글랜드), 라리가(스페인), 분데스리가(독일), 세리에A(이탈리아), 리그앙(프랑스), K리그, 챔피언스리그, 유로파리그를 지원합니다.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          final isLast = index == faqs.length - 1;

          return _FAQItem(
            question: faq['question']!,
            answer: faq['answer']!,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _ContactItem(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF3B82F6),
            title: '이메일 문의',
            subtitle: 'dudcks463@gmail.com',
            onTap: () => _launchEmail(context, subject: '[MatchLog 문의]'),
          ),
          Container(height: 1, margin: const EdgeInsets.only(left: 56), color: _border),
          _ContactItem(
            icon: Icons.bug_report_outlined,
            iconColor: const Color(0xFFEF4444),
            title: '버그 신고',
            subtitle: '오류나 문제점을 알려주세요',
            onTap: () => _showBugReportDialog(context),
          ),
          Container(height: 1, margin: const EdgeInsets.only(left: 56), color: _border),
          _ContactItem(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: '기능 제안',
            subtitle: '새로운 아이디어를 공유해주세요',
            onTap: () => _showFeatureRequestDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _InfoItem(
            title: '앱 버전',
            value: 'v1.0.0',
          ),
          Container(height: 1, margin: const EdgeInsets.only(left: 16), color: _border),
          _InfoItem(
            title: '빌드 번호',
            value: '1',
          ),
          Container(height: 1, margin: const EdgeInsets.only(left: 16), color: _border),
          _InfoItem(
            title: '개발자',
            value: 'JO YEONG CHAN',
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, {String? subject, String? body}) async {
    const email = 'dudcks463@gmail.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        Clipboard.setData(const ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 앱을 열 수 없어 주소가 복사되었습니다: $email')),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _FeedbackDialog(
        title: '버그 신고',
        hintText: '발견한 버그나 문제점을 자세히 설명해주세요...',
        onSubmit: (text) {
          Navigator.pop(dialogContext);
          _launchEmail(
            context,
            subject: '[MatchLog 버그 신고]',
            body: text,
          );
        },
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _FeedbackDialog(
        title: '기능 제안',
        hintText: '원하시는 기능을 자세히 설명해주세요...',
        onSubmit: (text) {
          Navigator.pop(dialogContext);
          _launchEmail(
            context,
            subject: '[MatchLog 기능 제안]',
            body: text,
          );
        },
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FAQItem({
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (widget.showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 16),
            color: const Color(0xFFE5E7EB),
          ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(String) onSubmit;

  const _FeedbackDialog({
    required this.title,
    required this.hintText,
    required this.onSubmit,
  });

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(color: Colors.grey.shade600)),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSubmit(_controller.text);
            }
          },
          child: const Text('제출', style: TextStyle(color: Color(0xFF2563EB))),
        ),
      ],
    );
  }
}
