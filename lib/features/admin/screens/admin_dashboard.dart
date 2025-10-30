import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(),
          _buildStudentsTab(),
          _buildInstructorsTab(),
          _buildReportsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(child: _buildStatCard('Active\nInstructors', '0', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Active\nStudents', '0', Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Active\nSessions', '0', Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Total\nStudents', '0', Colors.purple)),
          ],
        ),
        const SizedBox(height: 24),

        // Recent activity
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  Icons.check_circle,
                  'John Doe completed 100km milestone',
                  '2 hours ago',
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.directions_car,
                  'Session started by Mike Smith',
                  '3 hours ago',
                  Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.feedback,
                  'New feedback received',
                  '5 hours ago',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Quick actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addStudent(),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Student'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addInstructor(),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Instructor'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(time),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No students yet'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _addStudent(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Student'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search instructors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No instructors yet'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _addInstructor(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Instructor'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.analytics, color: Colors.blue),
            title: const Text('Student Progress Report'),
            subtitle: const Text('View all students progress'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.assessment, color: Colors.green),
            title: const Text('Instructor Performance'),
            subtitle: const Text('View instructor statistics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.feedback, color: Colors.orange),
            title: const Text('Feedback & Complaints'),
            subtitle: const Text('View all feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.file_download, color: Colors.purple),
            title: const Text('Export Data'),
            subtitle: const Text('Export reports to PDF/Excel'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'School Configuration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Required Roadway Distance'),
                subtitle: const Text('70 km'),
                trailing: const Icon(Icons.edit),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text('Required Practice Place Distance'),
                subtitle: const Text('30 km'),
                trailing: const Icon(Icons.edit),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text('Required Classroom Hours'),
                subtitle: const Text('20 hours'),
                trailing: const Icon(Icons.edit),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: const Text('Student creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addInstructor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Instructor'),
        content: const Text('Instructor creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
