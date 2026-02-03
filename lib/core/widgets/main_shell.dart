import 'package:flutter/material.dart';
import '../widgets/floating_nav_bar.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: FloatingNavBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          // Navigation handled by router
        },
      ),
    );
  }
}
