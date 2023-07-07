import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MakePaymentPage extends StatefulWidget {
  @override
  _MakePaymentPageState createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  TextEditingController _paymentAmountController = TextEditingController();
  String studentCodeInput = '';
  @override
  void dispose() {
    _paymentAmountController.dispose();
    super.dispose();
  }

  void _makePayment() async {
    final paymentAmount = double.parse(_paymentAmountController.text);

    final url = Uri.parse('http://192.168.1.161:8000/payment/$studentCodeInput/');
    final response = await http.post(url, body: {'payment_amount': paymentAmount.toString()});

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final status = responseData['status'];
      // Handle the payment status response or perform any necessary actions
      print('Payment status: $status');
    } else {
      print('Failed to make payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
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
              Text(
                'Enter Payment Amount:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _paymentAmountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _makePayment,
                child: Text('Make Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
