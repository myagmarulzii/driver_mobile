import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/bluetooth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/models/driving_session.dart';
import '../../../core/services/database_service.dart';

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({super.key});

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final instructorId = authProvider.currentUser?.id;

    if (instructorId != null) {
      Provider.of<SessionProvider>(context, listen: false)
          .loadSessionsForInstructor(instructorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
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
          _buildHomeTab(),
          _buildStudentsTab(),
          _buildSessionsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: Consumer<SessionProvider>(
        builder: (context, sessionProvider, _) {
          if (_selectedIndex == 1 && !sessionProvider.hasActiveSession) {
            return FloatingActionButton.extended(
              onPressed: () => _showStartSessionDialog(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        if (sessionProvider.hasActiveSession) {
          return _buildActiveSessionView(sessionProvider.activeSession!);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.directions_car,
                          '0',
                          'Sessions',
                          Colors.blue,
                        ),
                        _buildStatItem(
                          Icons.location_on,
                          '0 km',
                          'Distance',
                          Colors.green,
                        ),
                        _buildStatItem(
                          Icons.access_time,
                          '0 hrs',
                          'Duration',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.play_arrow, color: Colors.green),
                      title: const Text('Start New Session'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showStartSessionDialog(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people, color: Colors.blue),
                      title: const Text('View Students'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.orange),
                      title: const Text('Session History'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionView(DrivingSession session) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text('Map View\n(Google Maps integration)'),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSessionStat(
                    'Distance',
                    '${session.distance.toStringAsFixed(2)} km',
                    Icons.location_on,
                  ),
                  _buildSessionStat(
                    'Duration',
                    '${session.duration} min',
                    Icons.access_time,
                  ),
                  _buildSessionStat(
                    'Type',
                    session.practiceType.name,
                    Icons.directions_car,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pauseSession(),
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _endSession(),
                      icon: const Icon(Icons.stop),
                      label: const Text('End Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Assigned Students'),
          const SizedBox(height: 8),
          Text(
            'Students assigned by admin will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        if (sessionProvider.sessions.isEmpty) {
          return const Center(
            child: Text('No sessions yet'),
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
                  child: const Icon(Icons.directions_car, color: Colors.white),
                ),
                title: Text('${session.distance.toStringAsFixed(2)} km'),
                subtitle: Text(
                  '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}',
                ),
                trailing: Text('${session.duration} min'),
              ),
            );
          },
        );
      },
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
                  'Driving Instructor',
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
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(user?.email ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Phone'),
          subtitle: Text(user?.phone ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text('License Number'),
          subtitle: Text(user?.licenseNumber ?? ''),
        ),
      ],
    );
  }

  Future<void> _showStartSessionDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Driving Session'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a student and practice type to begin'),
            SizedBox(height: 16),
            Text('1. Pair with student via Bluetooth'),
            Text('2. Select practice type'),
            Text('3. Start session'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initiatePairing();
            },
            child: const Text('Start Pairing'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePairing() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    await bluetoothProvider.startScanning();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning for student devices...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pauseSession() async {
    await Provider.of<SessionProvider>(context, listen: false).pauseSession();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session paused')),
    );
  }

  Future<void> _endSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this driving session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final currentPos = locationProvider.currentPosition;

      Location? endLocation;
      if (currentPos != null) {
        endLocation = Location(
          latitude: currentPos.latitude,
          longitude: currentPos.longitude,
          timestamp: DateTime.now(),
        );
      }

      final success = await Provider.of<SessionProvider>(context, listen: false)
          .endSession(endLocation: endLocation);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session ended successfully')),
        );
        setState(() => _selectedIndex = 0);
      }
    }
  }
}
