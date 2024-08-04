import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        controller.stopCamera(); // Stop the camera
        Navigator.of(context).pop(); // Close the scanner dialog
      }
    });
  }

  void _scanQRCode() {
    setState(() {
      result = null; // Reset the result before scanning
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.infinity,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller?.stopCamera();
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL() async {
    if (result != null && result!.code != null) {
      final Uri url = Uri.parse(result!.code!);
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code Scanner',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'Sf_Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Color(0xFFC7E6FA),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x8C34A0EF),
              ),
              onPressed: _scanQRCode,
              child: Text(
                'Scan',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Sf_Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (result != null)
              Column(
                children: [
                  Text(
                    'Data: ${result!.code}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0x8C34A0EF),
                    ),
                    onPressed: _launchURL,
                    child: Text(
                      'Open in Browser',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontFamily: 'Sf_Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(''),
          ],
        ),
      ),
    );
  }
}
