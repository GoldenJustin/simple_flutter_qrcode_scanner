import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:scanner_app/login_role.dart';
import 'package:scanner_app/payment.dart';
import 'package:scanner_app/requestID.dart';
import 'CardDetails.dart';

class QRCodeScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRCodeScannerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  String studentCodeInput = '';
  QRViewController? _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  List<String> _decryptedCodes = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unicard Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _decryptedCodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _decryptedCodes[index],
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _isScanning ? null : _scanQRCode,
            child: Text('Scan QR Code'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.withOpacity(0.4),
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Student Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'RequestID',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'login',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CardDetailsPage()),
            );
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MakePaymentPage(),
              ),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    IDCardRequestPage(),
              ),
            );
          }
          else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserLoginScreen(),
              ),
            );
          }
        }
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _scanQRCode() {
    setState(() {
      _isScanning = true;
    });
    _controller?.resumeCamera();
    _clearDecryptedCodes();
    _controller?.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        _sendDataToBackend(scanData.code!);
      }
      setState(() {
        _isScanning = false;
      });
      _controller?.pauseCamera();
    });
  }

  void _clearDecryptedCodes() {
    setState(() {
      _decryptedCodes.clear();
    });
  }

  Future<void> _sendDataToBackend(String code) async {
    final url = Uri.parse('http://192.168.1.161:8000/cipher_text/'); // Your Django backend URL for decryption
    final response = await http.post(url, body: {'encrypted_data': code});

    if (response.statusCode == 200) {
      // Request successful
      final decryptedContents = response.body;
      final decodedData = jsonDecode(decryptedContents);

      if (decodedData.containsKey('STUDENT DATA')) {
        final studentData = decodedData['STUDENT DATA'];

        // Show a dialog with the decoded student data
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Student Details'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Programme: ${studentData['programme']}'),
                  Text('Name: ${studentData['name']}'),
                  Text('Student Code: ${studentData['student_code']}'),
                  Text('Signature: ${studentData['signature']}'),
                  Text('Expiration Date: ${studentData['exp_date']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _controller?.resumeCamera();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _decryptedCodes.add("This is not an Institute's ID card");
        });
      }
      print('Data sent to backend for decryption');
    } else {
      // Request failed
      print('Failed to send data to backend');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

