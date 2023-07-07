
import 'package:flutter/material.dart';
import 'package:scanner_app/scanqrcode.dart';

import 'CardDetails.dart';

void main() => runApp(QRCodeScannerApp());

class StudentCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardDetailsPage(),
    );
  }
}
