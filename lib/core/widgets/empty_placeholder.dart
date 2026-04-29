import 'package:flutter/material.dart';


class EmptyPlaceholder extends StatelessWidget {
  final String message;
  const EmptyPlaceholder({super.key, required this.message});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}