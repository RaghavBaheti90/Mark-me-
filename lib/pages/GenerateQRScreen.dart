import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String _qrData = "";
  bool _loading = true;
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _generateAutoQR();
  }

  Future<void> _generateAutoQR() async {
    setState(() {
      _loading = true;
    });

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final formattedTime = DateFormat('HH:mm:ss').format(now);
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      final teacher = FirebaseAuth.instance.currentUser;

      if (teacher == null) {
        throw Exception("User not logged in.");
      }

      final subject = _subjectController.text.trim().isEmpty
          ? "Unknown Subject"
          : _subjectController.text.trim();

      final qrPayload = {
        "type": "attendance",
        "session_id": sessionId,
        "subject": subject,
        "date": formattedDate,
        "time": formattedTime,
      };

      await FirebaseFirestore.instance
          .collection("attendance_sessions")
          .doc(sessionId)
          .set({
        "session_id": sessionId,
        "subject": subject,
        "date": formattedDate,
        "time": formattedTime,
        "timestamp": Timestamp.now(),
        "created_by": teacher.uid,
        "students": {},
      });

      setState(() {
        _qrData = jsonEncode(qrPayload);
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating QR: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _generateManualQR() {
    final subject = _subjectController.text.trim();
    if (subject.isNotEmpty) {
      _generateAutoQR();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a subject name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Generate QR',
          style: TextStyle(
            fontFamily: "ChivoMono",
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.05),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    hintText: "Enter Subject Name...",
                    hintStyle: TextStyle(
                      fontFamily: "ChivoMono",
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateManualQR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent[100],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Generate QR Code",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "ChivoMono",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.06),
              // if (_loading)
              //   const CircularProgressIndicator()
              // else
              if (_qrData.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: width * 0.6,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
