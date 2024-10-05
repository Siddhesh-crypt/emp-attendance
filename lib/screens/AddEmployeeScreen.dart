import 'package:flutter/material.dart';
import '../services/db_connection.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _contactNumber = '';
  String _designation = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final conn = await DatabaseConnection.getConnection();

      // Insert the data into the MySQL database
      await conn.query(
        'INSERT INTO employees (name, contact_number, designation) VALUES (?, ?, ?)',
        [_name, _contactNumber, _designation],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E60CE), Color(0xFF48BFE3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F9FD), Color(0xFFCAE4DB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              Text(
                "Add New Employee",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              SizedBox(height: 20),

              // Name Input
              _buildTextField(
                label: 'Name',
                icon: Icons.person,
                onSaved: (value) => _name = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),

              // Contact Number Input
              _buildTextField(
                label: 'Contact Number',
                icon: Icons.phone,
                onSaved: (value) => _contactNumber = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a contact number' : null,
              ),

              // Designation Input
              _buildTextField(
                label: 'Designation',
                icon: Icons.work,
                onSaved: (value) => _designation = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a designation' : null,
              ),

              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: Color(0xFF48BFE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field builder
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF2D3142)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Color(0xFF48BFE3)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF48BFE3), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF5E60CE), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
