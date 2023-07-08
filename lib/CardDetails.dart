import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardDetailsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  String programme = '';
  String name = '';
  String studentCode = '';
  String signature = '';
  String expDate = '';
  String photo = '';
  String qrcode = '';
  String studentCodeInput = '';
  String payment = '';

  Future<void> fetchCardDetails() async {
    final url = Uri.parse('http://192.168.1.161:8000/cardDetails/$studentCodeInput/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData != null && responseData is Map<String, dynamic>) {
        setState(() {
          programme = responseData['programme'] ?? '';
          name = responseData['name'] ?? '';
          studentCode = responseData['student_code'] ?? '';
          signature = responseData['signature'] ?? '';
          expDate = responseData['exp_date'] ?? '';
          photo = responseData['avatar_url'] ?? '';
          qrcode = responseData['qrcode_url'] ?? '';
          payment = responseData['payment_status']?? '';
        });
      } else {
        print('Invalid response data');
      }
    } else {
      print('Failed to fetch card details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student ID Card Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Student Code:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    studentCodeInput = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: fetchCardDetails,
                  child: Text('Fetch Card Details'),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: photo.isNotEmpty
                            ? Image.network(
                          photo,
                          height: 100,
                          width: 80,
                          fit: BoxFit.contain,
                        )
                            : Container(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Programme:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            programme,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Name:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            name,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Student Code:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            studentCode,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Signature:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            signature,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Expiration Date:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            expDate,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: qrcode.isNotEmpty
                            ? Image.network(
                          qrcode,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}