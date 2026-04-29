import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const GradientHeader({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.headerGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(96);
}
