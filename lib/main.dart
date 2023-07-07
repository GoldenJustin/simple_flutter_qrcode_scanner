import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

void main() => runApp(QRCodeScannerApp());

class QRCodeScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRCodeScannerPage(),
    );
  }
}

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  QRViewController? _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  List<String> _scannedCodes = [];
  bool _isTorchOn = false;
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
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
              itemCount: _scannedCodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _scannedCodes[index],
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _isScanning ? null : _scanQRCode,
                child: Text('Scan QR Code'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _toggleTorch,
                child: Text(_isTorchOn ? 'Turn Off Torch' : 'Turn On Torch'),
              ),
            ],
          ),
        ],
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
    _controller?.toggleFlash();
    // _controller?.toggleCamera();
    _controller?.resumeCamera();
    _clearScannedCodes(); // Clear previously scanned codes
    _controller?.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        setState(() {
          _scannedCodes.add(scanData.code!);
        });
        _sendDataToBackend(scanData.code!);
      }
      setState(() {
        _isScanning = false;
      });
      _controller?.pauseCamera();
    });
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    _controller?.toggleFlash();
  }

  void _clearScannedCodes() {
    setState(() {
      _scannedCodes.clear();
    });
  }

  Future<void> _sendDataToBackend(String code) async {
    final url = Uri.parse('http://192.168.1.161:8000/cipher_text/'); // Your Django backend URL for decryption
    final response = await http.post(url, body: {'encrypted_data': code});

    if (response.statusCode == 200) {
      // Request successful
      final decryptedContents = response.body; // Extract decrypted contents from response
      setState(() {
        _scannedCodes.add(decryptedContents); // Add decrypted contents to the scannedCodes list
      });
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
