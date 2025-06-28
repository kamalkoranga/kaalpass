import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kaal_pass/components/my_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String appGroupId = "klka.kaalpass";
  static const String androidWidgetName = "KaalPassWidget";
  static const String dataKey = "today's_password";

  String secret = '';
  String currentPassword = '';
  Timer? midnightTimer;

  @override
  void initState() {
    super.initState();
    _loadSecret();
    HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> _loadSecret() async {
    final prefs = await SharedPreferences.getInstance();
    secret = prefs.getString('secret_key') ?? '';
    if (secret.isEmpty) {
      _promptForSecret();
    } else {
      _updatePassword();
      _scheduleMidnightUpdate();
    }
  }

  Future<void> _saveSecret(String newSecret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secret_key', newSecret);
    setState(() {
      secret = newSecret;
    });
    _updatePassword();
    _scheduleMidnightUpdate();
  }

  void _promptForSecret() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter Secret Key'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: false,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Secret Key'),
            ),
            SizedBox(height: 24.0),
            Text(
              'This key will be used to generate your daily password. It should be the same as the one used in the bash script.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primaryFixedDim),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _saveSecret(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _updatePassword() async {
    if (secret.isEmpty) return;
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final input = utf8.encode(secret + dateKey);
    final hash = sha256.convert(input).toString();
    final password = hash.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 14);

    setState(() {
      currentPassword = password;
    });

    await HomeWidget.saveWidgetData(dataKey, password);
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final durationUntilMidnight = nextMidnight.difference(now);

    midnightTimer?.cancel();
    midnightTimer = Timer(durationUntilMidnight, () {
      _updatePassword();
      _scheduleMidnightUpdate();
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
      appBar: AppBar(
        elevation: 0,
      ),
      drawer: MyDrawer(_promptForSecret),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Today\'s Password',
              style: TextStyle(
                fontSize: 20
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  currentPassword,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(width: 8,),
                IconButton(
                 icon: Icon(Icons.copy),
                 tooltip: 'Copy to Clipboard',
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
            SizedBox(height: 100,),
          ],
        ),
      );
  }
}
