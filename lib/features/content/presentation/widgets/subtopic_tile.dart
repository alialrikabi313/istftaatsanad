import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/subtopic.dart';

class SubtopicTile extends StatelessWidget {
  final Subtopic subtopic;
  final VoidCallback onTap;
  const SubtopicTile({super.key, required this.subtopic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        subtopic.name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.gold.withValues(alpha:0.6),
      ),
      onTap: onTap,
    );
  }
}
