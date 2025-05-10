import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final String subject;

  const SessionDetailPage({
    Key? key,
    required this.sessionId,
    required this.subject,
  }) : super(key: key);

  @override
  _SessionDetailPageState createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, dynamic>> filteredStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: Text(
          widget.subject,
          style: const TextStyle(
            fontFamily: 'ChivoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('attendance_sessions')
            .doc(widget.sessionId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('No session data found.'));
          }

          final students = (data['students'] ?? {}) as Map<String, dynamic>;
          final studentList = students.entries.toList();

          final formattedDate = formatTimestamp(data['date'], 'dd MMM yyyy');
          final formattedTime = formatTimestamp(data['time'], 'hh:mm a');

          // Filtering students based on search query
          if (_searchController.text.isNotEmpty) {
            filteredStudents = studentList
                .where((student) => student.value
                    .toString()
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          } else {
            filteredStudents = studentList;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: $formattedDate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'ChivoMono',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time: $formattedTime',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'ChivoMono',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Present: ${filteredStudents.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'ChivoMono',
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(
                        () {}); // Update the list when search query changes
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search by student name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final name = filteredStudents[index].value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.deepPurple),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ChivoMono',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String formatTimestamp(dynamic value, String pattern) {
    if (value is Timestamp) {
      return DateFormat(pattern).format(value.toDate());
    } else if (value is String) {
      return value;
    } else {
      return 'N/A';
    }
  }
}
