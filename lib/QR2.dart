import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'acc.dart';

class testQR extends StatefulWidget {
  const testQR({super.key, required this.mode});
  final String mode;

  @override
  State<testQR> createState() => _testQRState();
}

class _testQRState extends State<testQR> {
  String? _qrValue;
  final MobileScannerController _scannerController = MobileScannerController();

  void _handleBarcode(BarcodeCapture barcodes) {
    final Barcode? firstBarcode =
        barcodes.barcodes.isNotEmpty ? barcodes.barcodes.first : null;
    if (firstBarcode != null && firstBarcode.displayValue != _qrValue) {
      setState(() {
        _qrValue = firstBarcode.displayValue;
      });
      _processQRValue();
    }
  }

  void _processQRValue() {
    final String? qr = _qrValue;
    if (qr == null) return;

    if ((qr == "P1" || qr == "P2" || qr == "P3" || qr == "P4") &&
        widget.mode == "acc") {
      _scannerController.stop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Acc(
            P: qr,
          ),
        ),
      ).then((_) {
        _scannerController.start();
      });
    } else if ((qr == "BK" ||qr == "P1" || qr == "P2" || qr == "P3" || qr == "P4") &&
        widget.mode == "receive") {
      _scannerController.stop();
      Navigator.pop(context, qr);
    } else if (widget.mode == "QR") {
      _scannerController.stop();
      Navigator.pop(context, qr);
    } else if (widget.mode == "GO" && qr == 'GO'|| qr == 'BK') {
      _scannerController.stop();
      Navigator.pop(context, 'GO');
    } else {
      // Handle invalid value case (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR')),
      );
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: _qrValue == null
                    ? const Text(
                        'Scan a QR code',
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        _qrValue!,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
