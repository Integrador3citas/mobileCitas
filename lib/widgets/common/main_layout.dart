import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget sidebar;
  final Widget child;

  const MainLayout({
    super.key,
    required this.title,
    required this.sidebar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Center(
              child: Text("Invitado"),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          sidebar,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}