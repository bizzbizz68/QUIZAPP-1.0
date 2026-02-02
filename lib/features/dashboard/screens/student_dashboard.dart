import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../hsk_exam/student/screens/student_exam_list_screen.dart';
import '../../hsk_exam/student/screens/exam_history_screen.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/sidebar_toggle_button.dart';

class StudentDashboard extends StatefulWidget {
  final UserModel user;

  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
      icon: Icons.play_circle_fill,
      label: 'Làm Bài Thi',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.assignment,
      label: 'Đề Thi Khả Dụng',
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.history,
      label: 'Lịch Sử Thi',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: Icons.grade,
      label: 'Kết Quả',
      color: Colors.purple,
    ),
    NavigationItem(
      icon: Icons.trending_up,
      label: 'Tiến Độ',
      color: Colors.teal,
    ),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return const StudentExamListScreen();
      case 2:
        return const StudentExamListScreen();
      case 3:
        return const ExamHistoryScreen();
      case 4:
        return _buildPlaceholder('Kết Quả', Icons.grade, Colors.purple);
      case 5:
        return _buildPlaceholder('Tiến Độ', Icons.trending_up, Colors.teal);
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, ${widget.user.email}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chào mừng bạn đến với hệ thống luyện thi HSK',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          // Quick actions
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _QuickActionCard(
                icon: Icons.play_circle_fill,
                title: 'Làm Bài Thi',
                color: Colors.blue,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _QuickActionCard(
                icon: Icons.history,
                title: 'Lịch Sử',
                color: Colors.orange,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              _QuickActionCard(
                icon: Icons.grade,
                title: 'Kết Quả',
                color: Colors.purple,
                onTap: () => setState(() => _selectedIndex = 4),
              ),
              _QuickActionCard(
                icon: Icons.trending_up,
                title: 'Tiến Độ',
                color: Colors.teal,
                onTap: () => setState(() => _selectedIndex = 5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }

  double get _contentLeftMargin {
    switch (_sidebarState) {
      case SidebarState.hidden:
        return 0.0;
      case SidebarState.collapsed:
        return 70.0;
      case SidebarState.expanded:
        return 250.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area (below) - Animated with sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(left: _contentLeftMargin),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
