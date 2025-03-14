import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EditList extends StatefulWidget {
  final String docId;
  final String task;
  final String duration;
  final String status;

  const EditList({
    super.key,
    required this.docId,
    required this.task,
    required this.duration,
    required this.status,
  });

  @override
  State<EditList> createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  late TextEditingController durationController;
  String? status;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    durationController = TextEditingController(text: widget.duration);
    status = widget.status;
  }

  Future<void> updateTask() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    String newDuration = durationController.text.trim();
    if (newDuration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกระยะเวลา')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ToDo').doc(widget.docId).update({
        'duration': newDuration,
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อัปเดตสำเร็จ')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Widget customTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatter,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDropDown() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: status,
        items: ['เสร็จแล้ว', 'ยังไม่เสร็จ'].map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            status = newValue!;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : updateTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? Colors.grey : Color(0xFFFEB0B9),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'ยกเลิก',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEB0B9),
        title: Text(
          'Edit List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              controller: durationController,
              hintText: 'ระยะเวลาที่ใช้ (วัน)',
              inputType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _buildDropDown(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCancelButton(context),
                _buildSaveButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
