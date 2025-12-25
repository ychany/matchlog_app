import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

/// 로그인 필요 다이얼로그를 표시합니다.
/// [context] - BuildContext
/// 취소 버튼과 로그인 버튼을 제공하며, 로그인 버튼 클릭 시 /login 화면으로 이동합니다.
void showLoginRequiredDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.loginRequired),
      content: Text(l10n.loginRequired),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/login');
          },
          child: Text(
            l10n.loginAction,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
