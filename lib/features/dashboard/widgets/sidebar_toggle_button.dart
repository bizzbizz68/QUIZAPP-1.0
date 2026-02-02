import 'package:flutter/material.dart';
import 'app_sidebar.dart';

class SidebarToggleButton extends StatelessWidget {
  final SidebarState sidebarState;
  final VoidCallback onTap;

  const SidebarToggleButton({
    super.key,
    required this.sidebarState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: sidebarState == SidebarState.hidden 
          ? 0 
          : sidebarState == SidebarState.collapsed 
              ? 65 
              : 245,
      top: MediaQuery.of(context).size.height / 2 - 30,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            sidebarState == SidebarState.hidden || sidebarState == SidebarState.collapsed
                ? Icons.chevron_right
                : Icons.chevron_left,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
