import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/db_service.dart';

class EmployeeRegistrationScreen extends StatefulWidget {
  @override
  _EmployeeRegistrationScreenState createState() => _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _registerEmployee() async {
    if (_nameController.text.isNotEmpty && _image != null) {
      if (_passwordController.text == _confirmPasswordController.text) {
        // Convert the password to MD5
        var bytes = utf8.encode(_passwordController.text);
        var digest = md5.convert(bytes);

        // Save the name and hashed password
        await DBService().insertEmployee(_nameController.text, digest.toString(), _image!.path);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Employee Registered Successfully')));
        _nameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _image = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Employee')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                autofocus: true,
                autocorrect: true,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Employee Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                obscureText: true,
                autofocus: true,
                autocorrect: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                obscureText: true,
                autofocus: true,
                autocorrect: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                setState(() {
                  _image = pickedFile;
                });
              },
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _image != null
                ? CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(File(_image!.path)),
            )
                : CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.camera_alt, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerEmployee,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
