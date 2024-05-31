import 'package:flutter/material.dart';
import 'acc.dart';

class testQR extends StatefulWidget {
  const testQR({super.key, required this.mode});
  final String mode;
  @override
  State<testQR> createState() => _testQRState();
}

class _testQRState extends State<testQR> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter P value',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final String qr = _controller.text;
                if ((qr == "P1" || qr == "P2" || qr == "P3" || qr == "P4") &&
                    widget.mode == "acc") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Acc(
                        P: qr,
                      ),
                    ),
                  );
                } else if ((qr == "BK" ||
                  qr == "P1" ||
                        qr == "P2" ||
                        qr == "P3" ||
                        qr == "P4") &&
                    widget.mode == "receive") {
                  Navigator.pop(context, qr);
                } else if (widget.mode == "QR") {
                  Navigator.pop(context, qr);
                } else if (widget.mode == "GO" && qr == 'GO') {
                  Navigator.pop(context, 'GO');
                } else {
                  // Handle invalid value case (e.g., show an error message)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid QR')),
                  );
                }
              },
              child: const Text('QR'),
            )
          ],
        ),
      ),
    );
  }
}
