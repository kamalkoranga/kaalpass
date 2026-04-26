import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordDisplay extends StatelessWidget {
  final String password;
  final int secondsRemaining;
  final int rotationSeconds;

  const PasswordDisplay({
    super.key,
    required this.password,
    required this.secondsRemaining,
    this.rotationSeconds = 30,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / rotationSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current Password', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(
                password,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy),
                tooltip: 'Copy to Clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 240,
            child: Column(
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text(
                  'Refreshes in ${secondsRemaining}s',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
