import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_service.dart';
import '../services/location_service.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _markAttendance() async {
    if (_image != null) {
      final location = await LocationService().getCurrentLocation();
      await DBService().markAttendance(_image!.path, location);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance Marked Successfully')));
      setState(() => _image = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                setState(() {
                  _image = pickedFile;
                });
              },
              child: Text('Capture Image'),
            ),
            SizedBox(height: 20),
            _image != null
                ? CircleAvatar(
              radius: 100, // Adjust the radius as needed
              backgroundImage: FileImage(File(_image!.path)),
              backgroundColor: Colors.grey[200], // Optional: background color
            )
                : Container(
              height: 200, // Optional: size of the container
              width: 200,
              color: Colors.grey[300], // Optional: placeholder color
              child: Center(child: Text('No Image')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _markAttendance,
              child: Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
