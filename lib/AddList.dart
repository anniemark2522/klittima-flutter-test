import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddList extends StatefulWidget {
  const AddList({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final TextEditingController listworkController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String status = 'ยังไม่เสร็จ';
  bool isLoading = false;

  Future<void> addListToFirestore() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    String taskName = listworkController.text.trim();
    String duration = durationController.text.trim();

    if (taskName.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ToDo').add({
        'task': taskName,
        'duration': duration,
        'status': status,
        'createAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกสำเร็จ')),
      );

      listworkController.clear(); // ล้างค่าหลังจากบันทึกสำเร็จ
      durationController.clear();
      setState(() {
        status = 'ยังไม่เสร็จ'; // รีเซ็ตค่า status
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFEB0B9),
        title: Text(
          'Add List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              controller: listworkController,
              hintText: 'งานที่ต้องทำ',
              inputType: TextInputType.text,
            ),
            SizedBox(height: 20),
            customTextField(
              controller: durationController,
              hintText: 'ระยะเวลาที่ใช้ (วัน)',
              inputType: TextInputType.number,
              inputFormatter: [FilteringTextInputFormatter.digitsOnly],
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
      onPressed: isLoading ? null : addListToFirestore, // ปิดปุ่มขณะโหลด
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
}
