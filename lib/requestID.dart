import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IDCardRequestPage extends StatefulWidget {
  @override
  _IDCardRequestPageState createState() => _IDCardRequestPageState();
}

class _IDCardRequestPageState extends State<IDCardRequestPage> {
  TextEditingController _studentCodeController = TextEditingController();
  String? _csrfToken;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchCSRFToken(); // Fetch the CSRF token when the page is initialized
  }

  Future<void> _fetchCSRFToken() async {
    final url = Uri.parse('http://192.168.1.161:8000/csrf_cookie/'); // Replace with your server's CSRF cookie endpoint
    final response = await http.get(url);

    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final csrfToken = cookies.split(';').firstWhere((cookie) => cookie.trim().startsWith('csrftoken='));
      setState(() {
        _csrfToken = csrfToken.split('=').last;
        _isButtonEnabled = true; // Enable the button once the CSRF token is fetched
      });
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitIDCardRequest() async {
    final studentCode = _studentCodeController.text;

    if (_csrfToken != null) {
      final url = Uri.parse('http://192.168.1.161:8000/submit_id_card_request/');
      final response = await http.post(
        url,
        body: {'student_code': studentCode},
        headers: {'X-CSRFToken': _csrfToken!}, // Include the CSRF token in the request headers
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'];
        // Handle the ID card request response or perform any necessary actions
        print('ID card request message: $message');
      } else {
        print('Failed to submit ID card request');
      }
    } else {
      print('CSRF token is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card Request'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Student Code:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _studentCodeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _submitIDCardRequest : null, // Disable button if CSRF token is null
              child: Text('Submit ID Card Request'),
            ),
          ],
        ),
      ),
    );
  }
}
