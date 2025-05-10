import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPopup extends StatelessWidget {
  final String data;

  const QRPopup({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Your QR Code",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
