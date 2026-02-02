import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/sidebar_toggle_button.dart';

class ParentDashboard extends StatefulWidget {
  final UserModel user;

  const ParentDashboard({super.key, required this.user});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  final _sidebarKey = GlobalKey<AppSidebarState>();
  SidebarState _sidebarState = SidebarState.expanded;

  void _updateSidebarState(SidebarState state) {
    setState(() {
      _sidebarState = state;
    });
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Tổng Quan',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.child_care,
      label: 'Con Của Tôi',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.assessment,
      label: 'Kết Quả Học Tập',
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.trending_up,
      label: 'Tiến Độ Học Tập',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: Icons.schedule,
      label: 'Lịch Thi',
      color: Colors.purple,
    ),
    NavigationItem(
      icon: Icons.chat,
      label: 'Liên Hệ Giáo Viên',
      color: Colors.teal,
    ),
  ];

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _navigationItems[_selectedIndex].icon,
            size: 64,
            color: _navigationItems[_selectedIndex].color,
          ),
          const SizedBox(height: 16),
          Text(
            _navigationItems[_selectedIndex].label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area (below)
          Row(
            children: [
              // Main Content Area
              Expanded(
            child: Column(
              children: [
                // Top AppBar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _navigationItems[_selectedIndex].label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // TODO: Show notifications
                        },
                        tooltip: 'Thông báo',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
          ],
          ),
          
          // Sidebar on top (LAST child = on top in Stack)
          AppSidebar(
            key: _sidebarKey,
            user: widget.user,
            navigationItems: _navigationItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            onStateChanged: _updateSidebarState,
          ),
          
          // Toggle button
          SidebarToggleButton(
            sidebarState: _sidebarState,
            onTap: () => _sidebarKey.currentState?.toggleSidebar(),
          ),
        ],
      ),
    );
  }
}
