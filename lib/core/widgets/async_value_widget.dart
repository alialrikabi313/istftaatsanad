import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_widget.dart';
import 'empty_state_widget.dart';

/// ويدجت محسّنة للتعامل مع AsyncValue
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final String? emptyMessage;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.emptyMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (dataValue) {
        // التحقق من القائمة الفارغة
        if (dataValue is List && dataValue.isEmpty) {
          return EmptyStateWidget(message: emptyMessage);
        }
        return data(dataValue);
      },
      loading: () => loading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        if (this.error != null) {
          return this.error!(error, stackTrace);
        }
        return AppErrorWidget(
          error: error,
          onRetry: onRetry,
        );
      },
    );
  }
}