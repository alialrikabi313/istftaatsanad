import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/palette_provider.dart';
import '../theme/app_palette.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            // ═══ الهيدر المخصص ═══
            _buildHeader(context),

            // ═══ المحتوى ═══
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // ─── قسم المظهر ───
                  _SectionCard(
                    isDark: isDark,
                    icon: Icons.palette_outlined,
                    title: 'المظهر',
                    subtitle: 'اختر وضع العرض المفضل',
                    accentColor: const Color(0xFF4A90D9),
                    children: [
                      _ThemeOptionTile(
                        title: 'تلقائي (حسب النظام)',
                        subtitle: 'يتبع إعدادات جهازك',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: themeMode == ThemeMode.system,
                        onTap: () =>
                            themeNotifier.setThemeMode(ThemeMode.system),
                        isDark: isDark,
                      ),
                      _buildThinDivider(isDark),
                      _ThemeOptionTile(
                        title: 'نهاري',
                        subtitle: 'وضع العرض الفاتح',
                        icon: Icons.light_mode_rounded,
                        isSelected: themeMode == ThemeMode.light,
                        onTap: () =>
                            themeNotifier.setThemeMode(ThemeMode.light),
                        isDark: isDark,
                      ),
                      _buildThinDivider(isDark),
                      _ThemeOptionTile(
                        title: 'ليلي',
                        subtitle: 'وضع العرض المظلم',
                        icon: Icons.dark_mode_rounded,
                        isSelected: themeMode == ThemeMode.dark,
                        onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── قسم لون الثيم ───
                  _SectionCard(
                    isDark: isDark,
                    icon: Icons.color_lens_outlined,
                    title: 'لون الثيم',
                    subtitle: 'اختر لون خلفية التطبيق',
                    accentColor: const Color(0xFFB8922E),
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final selected = ref.watch(paletteProvider);
                          return _PaletteGrid(
                            selectedId: selected.id,
                            isDark: isDark,
                            onSelect: (p) => ref
                                .read(paletteProvider.notifier)
                                .setPalette(p),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── قسم حجم الخط ───
                  _SectionCard(
                    isDark: isDark,
                    icon: Icons.text_fields_rounded,
                    title: 'حجم الخط',
                    subtitle: 'تحكم بحجم النصوص',
                    accentColor: AppColors.gold,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final fontSize = ref.watch(fontSizeProvider);
                          final fontSizeNotifier =
                              ref.read(fontSizeProvider.notifier);

                          return Column(
                            children: [
                              // شريط القيمة الحالية
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha:0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha:0.12),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.format_size_rounded,
                                        color: AppColors.gold.withValues(alpha:0.7),
                                        size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${(fontSize * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.goldDark,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.text_decrease_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: AppColors.gold,
                                        inactiveTrackColor:
                                            AppColors.gold.withValues(alpha:0.15),
                                        thumbColor: AppColors.gold,
                                        overlayColor:
                                            AppColors.gold.withValues(alpha:0.08),
                                        trackHeight: 4,
                                        thumbShape:
                                            const RoundSliderThumbShape(
                                                enabledThumbRadius: 8),
                                      ),
                                      child: Slider(
                                        value: fontSize,
                                        min: fontSizeNotifier.minFontSize,
                                        max: fontSizeNotifier.maxFontSize,
                                        divisions: 14,
                                        onChanged: (value) {
                                          fontSizeNotifier.setFontSize(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.text_increase_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // نص المعاينة
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha:0.03)
                                      : Colors.black.withValues(alpha:0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (isDark
                                            ? AppColors.borderDark
                                            : AppColors.border)
                                        .withValues(alpha:0.5),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'معاينة حجم الخط',
                                      style: TextStyle(
                                        color: AppColors.gold.withValues(alpha:0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.headerGradient,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخرفة هندسية
          Positioned(
            top: -10,
            left: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:0.04),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 30,
            right: 30,
            height: 35,
            child: CustomPaint(
              painter: _SettingsArchPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الإعدادات',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.gold.withValues(alpha:0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 16,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gold.withValues(alpha:0.7),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // عنصر وهمي لموازنة الصف
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 0.8,
            color: AppColors.gold.withValues(alpha:0.2),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  بطاقة القسم
// ═══════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<Widget> children;

  const _SectionCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withValues(alpha:0.5)
              : accentColor.withValues(alpha:0.1),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha:0.12),
                        accentColor.withValues(alpha:0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: accentColor.withValues(alpha:0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accentColor.withValues(alpha:0.7),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // الخط الفاصل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.divider,
                  ),
                ),
              ],
            ),
          ),
          // المحتوى
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  خيار المظهر
// ═══════════════════════════════════════════════
class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withValues(alpha:0.05) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // الأيقونة
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withValues(alpha:0.12)
                    : (isDark
                        ? Colors.white.withValues(alpha:0.04)
                        : Colors.black.withValues(alpha:0.03)),
                borderRadius: BorderRadius.circular(11),
                border: isSelected
                    ? Border.all(
                        color: AppColors.gold.withValues(alpha:0.25),
                        width: 0.5,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.gold : AppColors.textSecondary,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.gold : null,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha:0.7),
                        ),
                  ),
                ],
              ),
            ),
            // علامة الاختيار
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('selected'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.goldGradient,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha:0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : Container(
                      key: const ValueKey('unselected'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary.withValues(alpha:0.2),
                          width: 1.5,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  شبكة اختيار لوحة الألوان
// ═══════════════════════════════════════════════
class _PaletteGrid extends StatelessWidget {
  final String selectedId;
  final bool isDark;
  final ValueChanged<AppPalette> onSelect;

  const _PaletteGrid({
    required this.selectedId,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final p in AppPalette.all)
          _PaletteSwatch(
            palette: p,
            isSelected: p.id == selectedId,
            isDark: isDark,
            onTap: () => onSelect(p),
          ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PaletteSwatch({
    required this.palette,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.06)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.black.withValues(alpha: 0.015)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.4)
                : (isDark
                    ? AppColors.borderDark.withValues(alpha: 0.4)
                    : AppColors.border.withValues(alpha: 0.6)),
            width: isSelected ? 1.2 : 0.6,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryDeep.withValues(alpha: 0.08),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.swatch.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.goldGradient),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              palette.nameAr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.goldDark : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha:0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.1, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
