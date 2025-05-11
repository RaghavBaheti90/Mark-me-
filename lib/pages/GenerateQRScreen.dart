import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String _qrData = "";
  String _subject = "";
  bool _loading = false;
  final TextEditingController _subjectController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _generateQR() async {
    setState(() => _loading = true);

    try {
      final now = DateTime.now();
      final sessionId = now.millisecondsSinceEpoch.toString();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final formattedTime = DateFormat('HH:mm:ss').format(now);
      final teacher = FirebaseAuth.instance.currentUser;

      if (teacher == null) throw Exception("User not logged in");

      final subject = _subjectController.text.trim();
      if (subject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a subject name")),
        );
        setState(() => _loading = false);
        return;
      }

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
        _subject = subject;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _shareQRImage() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/qr_image.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'QR for $_subject');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Generate QR',
          style: TextStyle(
            fontFamily: "ChivoMono",
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: Column(
          children: [
            SizedBox(height: height * 0.05),

            // Subject Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _generateQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 101, 229),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
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

            // QR Display & Share
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        children: [
                          QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: width * 0.6,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _subject,
                            style: const TextStyle(
                              fontFamily: "ChivoMono",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareQRImage,
                      icon: const Icon(Icons.share),
                      label: const Text(
                        "Share QR Image",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "ChivoMono",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
