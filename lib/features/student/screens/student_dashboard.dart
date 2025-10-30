import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/models/student_progress.dart';
import '../../../core/services/database_service.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  StudentProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      final progressMap = await DatabaseService.instance.getProgress(userId);
      if (progressMap != null) {
        setState(() {
          _progress = StudentProgress.fromMap(progressMap);
          _isLoading = false;
        });
      } else {
        // Create new progress record
        final newProgress = StudentProgress(studentId: userId);
        await DatabaseService.instance.insertOrUpdateProgress(newProgress.toMap());
        setState(() {
          _progress = newProgress;
          _isLoading = false;
        });
      }

      // Load sessions
      Provider.of<SessionProvider>(context, listen: false)
          .loadSessionsForStudent(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildProgressTab(),
                _buildSessionHistoryTab(),
                _buildFeedbackTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_progress == null) {
      return const Center(child: Text('No progress data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Exam eligibility card
          Card(
            color: _progress!.meetsRequirements ? Colors.green : Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    _progress!.meetsRequirements ? Icons.check_circle : Icons.access_time,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progress!.meetsRequirements
                        ? 'Exam Eligible'
                        : 'Not Yet Eligible',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!_progress!.meetsRequirements)
                    const Text(
                      'Complete the requirements below',
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Overall progress
          _buildProgressCard(
            'Total Distance',
            _progress!.totalDistance,
            _progress!.totalRequiredDistance,
            'km',
            Colors.blue,
          ),

          _buildProgressCard(
            'Roadway Distance',
            _progress!.totalRoadwayDistance,
            _progress!.requiredRoadwayDistance,
            'km',
            Colors.green,
          ),

          _buildProgressCard(
            'Practice Place Distance',
            _progress!.totalPracticePlaceDistance,
            _progress!.requiredPracticePlaceDistance,
            'km',
            Colors.orange,
          ),

          _buildProgressCard(
            'Classroom Hours',
            _progress!.totalClassroomHours,
            _progress!.requiredClassroomHours,
            'hours',
            Colors.purple,
          ),

          const SizedBox(height: 16),

          // Progress chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barGroups: [
                          _buildBarGroup(0, _progress!.distanceProgressPercentage, Colors.blue),
                          _buildBarGroup(1, _progress!.roadwayProgressPercentage, Colors.green),
                          _buildBarGroup(2, _progress!.practicePlaceProgressPercentage, Colors.orange),
                          _buildBarGroup(3, _progress!.classroomProgressPercentage, Colors.purple),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['Total', 'Road', 'Practice', 'Class'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(titles[value.toInt()]),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    String title,
    double current,
    double required,
    String unit,
    Color color,
  ) {
    final percentage = (current / required * 100).clamp(0, 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${current.toStringAsFixed(1)} / ${required.toStringAsFixed(0)} $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistoryTab() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        if (sessionProvider.sessions.isEmpty) {
          return const Center(
            child: Text('No driving sessions yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessionProvider.sessions.length,
          itemBuilder: (context, index) {
            final session = sessionProvider.sessions[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: session.practiceType.name == 'roadway'
                      ? Colors.green
                      : Colors.orange,
                  child: Icon(
                    session.practiceType.name == 'roadway'
                        ? Icons.directions_car
                        : Icons.local_parking,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${session.distance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${session.startTime.day}/${session.startTime.month}/${session.startTime.year} - ${session.duration} min',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to session details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.feedback, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Feedback System'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to feedback form
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Rate Instructor'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to complaint form
            },
            icon: const Icon(Icons.report),
            label: const Text('Submit Complaint'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Phone'),
          subtitle: Text(user?.phone ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text('Student ID'),
          subtitle: Text(user?.idNumber ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Enrollment Date'),
          subtitle: Text(user?.enrollmentDate?.toString().split(' ')[0] ?? ''),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Change password
          },
          child: const Text('Change Password'),
        ),
      ],
    );
  }
}
