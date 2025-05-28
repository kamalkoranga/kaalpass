import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updatePassword();
    timer = Timer.periodic(Duration(minutes: 5), (_) {
      _updatePassword();
    });
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Today\'sPassword:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            SelectableText(
              currentPassword,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
