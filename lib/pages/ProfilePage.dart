import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int attendedCount = 0;
  bool isLoading = true;
  String displayName = 'No Name';
  List<Map<String, dynamic>> attendedSessions = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        displayName = userDoc.data()?['name'] ?? 'No Name';
      });
    }
  }

  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': newName,
      'email': user.email,
    }, SetOptions(merge: true));

    setState(() {
      displayName = newName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name updated')),
    );
  }

  void showEditNameDialog() {
    final controller = TextEditingController(text: displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                updateUserName(newName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAttendanceData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final sessions = await FirebaseFirestore.instance
        .collection('attendance_sessions')
        .orderBy('timestamp', descending: true)
        .get();

    int count = 0;
    List<Map<String, dynamic>> sessionList = [];

    for (var doc in sessions.docs) {
      final data = doc.data();
      final students = data['students'] as Map<String, dynamic>? ?? {};

      if (students.containsKey(user.uid)) {
        count++;
        sessionList.add({
          'className': data['className'] ?? 'You are Present on',
          'timestamp': data['timestamp']?.toDate(),
        });
      }
    }

    setState(() {
      attendedCount = count;
      attendedSessions = sessionList;
      isLoading = false;
    });
  }

  void showAttendanceDetails() {
    if (attendedSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No attendance records found')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: attendedSessions.length,
        itemBuilder: (context, index) {
          final session = attendedSessions[index];
          final dateTime = session['timestamp'] as DateTime?;

          return ListTile(
            leading: const Icon(Icons.check),
            title: Text(
              session['className'],
              style: const TextStyle(
                fontFamily: 'ChivoMono',
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              dateTime != null
                  ? '${dateTime.day}/${dateTime.month}/${dateTime.year} – ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}'
                  : 'Unknown time',
              style: const TextStyle(
                fontFamily: 'ChivoMono',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  void signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'ChivoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("User not signed in"))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: showEditNameDialog,
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: 'ChivoMono',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(
                      fontFamily: 'ChivoMono',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: showAttendanceDetails,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Classes Attended: $attendedCount',
                                    style: const TextStyle(
                                      fontFamily: 'ChivoMono',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'ChivoMono',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
