import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(DailyPasswordApp());
}

class DailyPasswordApp extends StatelessWidget {
  const DailyPasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Password',
      home: PasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final String secret = 'MY_SUPER_SECRET'; // Replace with your actual secret
  String currentPassword = '';
  Timer? midnightTimer;

  @override
  void initState() {
    super.initState();
    _updatePassword();
    _scheduleMidnightUpdate();
  }

  void _updatePassword() {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final input = utf8.encode(secret + dateKey);
    final hash = sha256.convert(input).toString();

    final password = hash.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 14);

    setState(() {
      currentPassword = password;
    });
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    // Next midnight (start of next day)
    final nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final durationUntilMidnight = nextMidnight.difference(now);

    midnightTimer?.cancel();
    midnightTimer = Timer(durationUntilMidnight, () {
      _updatePassword();
      _scheduleMidnightUpdate(); // Reschedule for the next midnight
    });
  }

  @override
  void dispose() {
    midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Today\'sPassword:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  currentPassword,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8,),
                IconButton(
                  icon: Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: currentPassword));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password copied to clipboard'),
                        duration: Duration(seconds: 1),
                      )
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
