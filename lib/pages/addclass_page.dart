import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendence_app/pages/GenerateQRScreen.dart';
import 'package:uuid/uuid.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classSizeController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();

  bool isLoading = false;

  void createClass(BuildContext context) async {
    if (_classNameController.text.isEmpty ||
        _classSizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String classId = const Uuid().v4();
    final classData = {
      'classId': classId,
      'className': _classNameController.text.trim(),
      'classSize': int.tryParse(_classSizeController.text.trim()) ?? 0,
      'subject': _subjectController.text.trim(),
      'teacher': _teacherController.text.trim(),
      'createdAt': DateTime.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .set(classData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenerateQRScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create class: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
          'Create Class',
          style: TextStyle(
            fontFamily: "ChivoMono",
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.06, vertical: height * 0.04),
        child: Column(
          children: [
            _buildTextField("Class Name", _classNameController),
            const SizedBox(height: 16),
            _buildTextField("Class Size", _classSizeController,
                inputType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField("Subject", _subjectController),
            const SizedBox(height: 16),
            _buildTextField("Teacher Name", _teacherController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => createClass(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent[60],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create & Generate QR",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "ChivoMono",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
