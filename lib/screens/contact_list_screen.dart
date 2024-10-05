import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import '../services/db_connection.dart'; // Import the DB connection file

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Map<String, String>> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData(); // Fetch employee data on page load
  }

  Future<void> _fetchEmployeeData() async {
    try {
      final conn = await DatabaseConnection.getConnection();

      // Fetch data from the employees table
      var results = await conn.query('SELECT name, contact_number, designation FROM employees');

      List<Map<String, String>> tempContacts = [];
      for (var row in results) {
        tempContacts.add({
          'name': row[0],
          'mobile': row[1],
          'designation': row[2],
        });
      }

      setState(() {
        contacts = tempContacts;
      });

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to copy the phone number to clipboard
  void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)); // Copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact List'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E60CE), Color(0xFF48BFE3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F9FD), Color(0xFFCAE4DB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: contacts.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loader if data is empty
            : ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                shadowColor: Color(0xFF48BFE3).withOpacity(0.3),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF48BFE3),
                    child: Text(
                      contact['name']![0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact['name']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _copyPhoneNumber(context, contact['mobile']!),
                        child: Text(
                          contact['mobile']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF48BFE3),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        contact['designation']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orangeAccent,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF48BFE3), // Set the background color of the circle
                    ),
                    padding: EdgeInsets.all(10), // Adjust the padding for size of the circle
                    child: Icon(
                      Icons.phone,
                      color: Colors.white, // Set the icon color to contrast the background
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
