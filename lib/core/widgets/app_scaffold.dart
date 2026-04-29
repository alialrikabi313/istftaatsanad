import 'package:flutter/material.dart';


class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  const AppScaffold({super.key, required this.child, required this.title, this.actions});


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: child,
      ),
    );
  }
}

