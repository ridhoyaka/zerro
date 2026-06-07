import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/password_generator.dart';

class StrengthIndicator extends StatelessWidget {
  final String password;

  const StrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = PasswordGenerator.strength(password);
    final label = PasswordGenerator.strengthLabel(score);

    final colors = [
      AppTheme.danger,
      AppTheme.danger,
      AppTheme.warning,
      AppTheme.accentGreen,
      AppTheme.accentGreen,
    ];

    final barColor = password.isEmpty ? AppTheme.surfaceHigh : colors[score];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < score;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? barColor : AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: barColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
