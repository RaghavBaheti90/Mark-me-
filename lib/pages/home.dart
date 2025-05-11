import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_attendence_app/pages/ClassAttendanceSummaryPage.dart';

class QRHomePage extends StatelessWidget {
  const QRHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8), // light pastel background
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Mark Me',
                  style: TextStyle(
                    fontFamily: "ChivoMono",
                    fontSize: height * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3A3C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose what you want to do:',
                  style: TextStyle(
                    fontFamily: "ChivoMono",
                    fontSize: height * 0.02,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 60),

                // Generate QR
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/generate');
                  },
                  child: QRHomeCard(
                    title: "Generate QR Code",
                    icon: Icons.qr_code,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 30),

                // Scan QR
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/scan');
                  },
                  child: QRHomeCard(
                    title: "Scan QR Code",
                    icon: Icons.qr_code_scanner,
                    color: Colors.indigoAccent,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/attan');
                  },
                  child: QRHomeCard(
                    title: "Your Classes",
                    icon: Icons.class_,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: QRHomeCard(
                    title: "Profile",
                    icon: Icons.person,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRHomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const QRHomeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: height * 0.02,
              fontWeight: FontWeight.w500,
              fontFamily: "ChivoMono",
            ),
          ),
        ],
      ),
    );
  }
}
