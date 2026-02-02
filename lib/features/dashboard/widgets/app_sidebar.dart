import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/role_resolver.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/firebase_auth_service.dart';

enum SidebarState {
  hidden,    // Ẩn hoàn toàn
  collapsed, // Chỉ icon
  expanded,  // Full width
}

class AppSidebar extends StatefulWidget {
  final UserModel user;
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Function(SidebarState)? onStateChanged;

  const AppSidebar({
    super.key,
    required this.user,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onStateChanged,
  });

  @override
  State<AppSidebar> createState() => AppSidebarState();
}

class AppSidebarState extends State<AppSidebar> {
  SidebarState _state = SidebarState.expanded;

  double get width {
    switch (_state) {
      case SidebarState.hidden:
        return 0.0;
      case SidebarState.collapsed:
        return 70.0;
      case SidebarState.expanded:
        return 250.0;
    }
  }

  void toggleSidebar() {
    setState(() {
      // Cycle: expanded → collapsed → hidden → expanded
      switch (_state) {
        case SidebarState.expanded:
          _state = SidebarState.collapsed;
          break;
        case SidebarState.collapsed:
          _state = SidebarState.hidden;
          break;
        case SidebarState.hidden:
          _state = SidebarState.expanded;
          break;
      }
      widget.onStateChanged?.call(_state);
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      print('🔴 Logout: Starting logout process...');
      final authService = FirebaseAuthService();
      await authService.logout();
      print('🔴 Logout: Auth service logout completed');

      if (!context.mounted) {
        print('🔴 Logout: Context not mounted, aborting navigation');
        return;
      }

      print('🔴 Logout: Navigating to login screen...');
      // Use Navigator.pushAndRemoveUntil to clear navigation stack
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      print('🔴 Logout: Navigation completed');
    } catch (e) {
      print('🔴 Logout ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHidden = _state == SidebarState.hidden;
    final isCollapsed = _state == SidebarState.collapsed;
    final isExpanded = _state == SidebarState.expanded;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: width,
          color: Colors.grey[900],
          child: !isHidden
                  ? Column(
                      children: [
                        // Header với Avatar
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[850],
                          child: isExpanded
                              ? Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: RoleResolver.getRoleColor(widget.user.role),
                                      child: Icon(
                                        RoleResolver.getRoleIcon(widget.user.role),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.user.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            RoleResolver.getRoleDisplayName(widget.user.role),
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: RoleResolver.getRoleColor(widget.user.role),
                                    child: Icon(
                                      RoleResolver.getRoleIcon(widget.user.role),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ),

                        const Divider(color: Colors.grey, height: 1),

                        // Navigation Items
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: widget.navigationItems.length,
                            itemBuilder: (context, index) {
                              final item = widget.navigationItems[index];
                              final isSelected = widget.selectedIndex == index;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Material(
                                  color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () => widget.onItemSelected(index),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      child: isExpanded
                                          ? Row(
                                              children: [
                                                Icon(
                                                  item.icon,
                                                  color: isSelected ? Colors.blue : Colors.white70,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    item.label,
                                                    style: TextStyle(
                                                      color: isSelected ? Colors.white : Colors.white70,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Icon(
                                                item.icon,
                                                color: isSelected ? Colors.blue : Colors.white70,
                                                size: 24,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const Divider(color: Colors.grey, height: 1),

                        // Logout Button - Improved tap target
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                print('🔴 Logout button tapped!'); // Debug
                                _handleLogout(context);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                // Larger tap target
                                constraints: const BoxConstraints(minHeight: 48),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: isExpanded
                                    ? const Row(
                                        children: [
                                          Icon(Icons.logout, color: Colors.red, size: 24),
                                          SizedBox(width: 12),
                                          Text(
                                            'Đăng Xuất',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Icon(Icons.logout, color: Colors.red, size: 24),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
        ),

      ],
    );
  }
  
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
