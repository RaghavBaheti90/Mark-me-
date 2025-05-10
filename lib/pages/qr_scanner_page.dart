import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing) return;
      isProcessing = true;

      final data = scanData.code ?? '';

      try {
        final decoded = jsonDecode(data);

        if (decoded['session_id'] != null) {
          final sessionId = decoded['session_id'];
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            final sessionRef = FirebaseFirestore.instance
                .collection('attendance_sessions')
                .doc(sessionId);

            final sessionSnapshot = await sessionRef.get();

            if (sessionSnapshot.exists) {
              final sessionData =
                  sessionSnapshot.data() as Map<String, dynamic>;
              final students =
                  sessionData['students'] as Map<String, dynamic>? ?? {};

              if (students.containsKey(user.uid)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attendance already marked")),
                );
              } else {
                // Show dialog to enter name manually
                final userName = await _promptForName();

                if (userName != null && userName.trim().isNotEmpty) {
                  await sessionRef.update({
                    'students.${user.uid}': {
                      'name': userName.trim(),
                      'email': user.email,
                      'timestamp': Timestamp.now(),
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Attendance marked successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name entry cancelled")),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid session ID")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not authenticated")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid QR code format")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error parsing QR code")),
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      controller.resumeCamera();
      isProcessing = false;
    });
  }

  Future<String?> _promptForName() async {
    String name = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Name'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Your full name'),
            onChanged: (value) {
              name = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () => Navigator.of(context).pop(name),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.purple,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: width * 0.8,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code to mark attendance...'),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
