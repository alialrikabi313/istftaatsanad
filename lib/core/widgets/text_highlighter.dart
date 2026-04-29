import 'package:flutter/material.dart';

class TextHighlighter extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final int maxLines;

  const TextHighlighter({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || query.trim().isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    // تنظيف كلمة البحث من المسافات الزائدة
    final cleanQuery = query.trim();
    
    // تقسيم النص بناءً على الكلمة المفتاحية (غير حساس لحالة الأحرف)
    final lowerText = text.toLowerCase();
    final lowerQuery = cleanQuery.toLowerCase();

    // إذا لم توجد الكلمة
    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    // البحث عن جميع التطابقات وتظليلها
    while ((indexOfHighlight = lowerText.indexOf(lowerQuery, start)) != -1) {
      // 1. النص ما قبل التظليل
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
          style: style,
        ));
      }

      // 2. النص المظلل (نستخدم lowerQuery.length للحفاظ على الأحرف الأصلية)
      final highlightEnd = indexOfHighlight + lowerQuery.length;
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, highlightEnd),
        style: TextStyle(
          backgroundColor: const Color(0xFFFFEB3B), // أصفر فاتح واضح
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: style?.fontSize,
          height: style?.height,
        ),
      ));

      start = highlightEnd;
    }

    // 3. النص المتبقي
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}