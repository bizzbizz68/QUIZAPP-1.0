import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../hsk_exam/admin/screens/question_bank_dashboard.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/sidebar_toggle_button.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      icon: Icons.people,
      label: 'Quản Lý Người Dùng',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.school,
      label: 'Quản Lý Giáo Viên',
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.quiz,
      label: 'Quản Lý Đề Thi',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: Icons.analytics,
      label: 'Thống Kê & Báo Cáo',
      color: Colors.purple,
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Cài Đặt Hệ Thống',
      color: Colors.grey,
    ),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return _buildUserManagementContent();
      case 2:
        return _buildTeacherManagementContent();
      case 3:
        return _buildExamManagementContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng Quan Hệ Thống',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Tổng Người Dùng',
                value: '1,234',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Giáo Viên',
                value: '56',
                icon: Icons.school,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Học Sinh',
                value: '1,150',
                icon: Icons.person,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Đề Thi',
                value: '89',
                icon: Icons.quiz,
                color: Colors.purple,
              ),
              _buildStatCard(
                title: 'Bài Thi Hôm Nay',
                value: '245',
                icon: Icons.assignment_turned_in,
                color: Colors.teal,
              ),
              _buildStatCard(
                title: 'Phụ Huynh',
                value: '28',
                icon: Icons.family_restroom,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Quản Lý Người Dùng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }

  Widget _buildTeacherManagementContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Quản Lý Giáo Viên',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }

  Widget _buildExamManagementContent() {
    // Embed Question Bank Dashboard
    return const QuestionBankDashboard();
  }

  Widget _buildAnalyticsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'Thống Kê & Báo Cáo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tính năng đang được phát triển...'),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Cài Đặt Hệ Thống',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tính năng đang được phát triển...'),
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
          
          // Toggle button (animated)
          SidebarToggleButton(
            sidebarState: _sidebarState,
            onTap: () => _sidebarKey.currentState?.toggleSidebar(),
          ),
        ],
      ),
    );
  }
}
