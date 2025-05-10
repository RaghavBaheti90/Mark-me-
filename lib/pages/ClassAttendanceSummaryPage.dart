import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceSessionsPage extends StatelessWidget {
  const AttendanceSessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const Text(
          'Attendance Sessions',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance_sessions')
            .where('created_by', isEqualTo: currentUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data?.docs ?? [];

          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                'No attendance sessions found.',
                style: TextStyle(fontFamily: 'ChivoMono'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(context, session);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, DocumentSnapshot session) {
    final data = session.data() as Map<String, dynamic>;
    final students = data['students'] as Map<String, dynamic>? ?? {};
    final String formattedDate = _formatDate(data['date']);
    final String formattedTime = _formatTime(data['time']);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFF3F4F8), // Same as page background
            title: Text(
              data['subject'] ?? 'Session Details',
              style: const TextStyle(
                fontFamily: 'ChivoMono',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: students.isEmpty
                  ? const Text(
                      'No students marked present.',
                      style: TextStyle(
                        fontFamily: 'ChivoMono',
                        fontSize: 14,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final studentId = students.keys.elementAt(index);
                        final studentData =
                            students[studentId] as Map<String, dynamic>;
                        final studentName = studentData['name'] ?? 'Unknown';
                        final markedTime =
                            _formatTime(studentData['timestamp']);

                        return ListTile(
                          leading: const Icon(Icons.person,
                              color: Colors.deepPurple),
                          title: Text(
                            studentName,
                            style: const TextStyle(
                              fontFamily: 'ChivoMono',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Marked at: $markedTime',
                            style: const TextStyle(
                              fontFamily: 'ChivoMono',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'ChivoMono',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['subject'] ?? 'Subject: N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ChivoMono',
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📅 Date: $formattedDate',
                      style: const TextStyle(fontFamily: 'ChivoMono'),
                    ),
                    Text(
                      '⏰ Time: $formattedTime',
                      style: const TextStyle(fontFamily: 'ChivoMono'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'Total Present: ${students.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ChivoMono',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, session.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy').format(value.toDate());
    } else if (value is String) {
      return value;
    }
    return 'N/A';
  }

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('hh:mm a').format(value.toDate());
    } else if (value is String) {
      return value;
    }
    return 'N/A';
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Session',
          style: TextStyle(fontFamily: 'ChivoMono'),
        ),
        content: const Text(
          'Are you sure you want to delete this session?',
          style: TextStyle(fontFamily: 'ChivoMono'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance
                  .collection('attendance_sessions')
                  .doc(sessionId)
                  .delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
