import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kaal_pass/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appGroupId = "klka.kaalpass";
  String androidWidgetName = "KaalPassWidget";
  String dataKey = "today's_password";

  String secret = ''; // Replace with your actual secret
  String currentPassword = '';
  Timer? midnightTimer;

  @override
  void initState() {
    super.initState();
    _loadSecret();
    _updatePassword();
    _scheduleMidnightUpdate();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Secret Key'),
            SizedBox(height: 8.0),
            (secret.isNotEmpty)
                ? Text(
                    'Current Secret Key: $secret',
                    style: TextStyle(
                      fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.6)),
                  )
                : Container(),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: false,
              decoration: InputDecoration(hintText: 'Secret Key'),
            ),
            SizedBox(height: 24.0),
            Text(
              'This key will be used to generate your daily password. It should be same as the one used in the bash script.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
    if (secret.isEmpty) {return;}
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final input = utf8.encode(secret + dateKey);
    final hash = sha256.convert(input).toString();

    final password = hash.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 14);

    setState(() {
      currentPassword = password;
    });

    await HomeWidget.saveWidgetData(dataKey, password);
    await HomeWidget.updateWidget(
      androidName: androidWidgetName
    );
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
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dark Mode: ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 16,),
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()
                ),
              ],
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _promptForSecret,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Change Secret Key',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 16
                )
              )
            ),
          ]
        ),
      ),
      body: Center(
        child: Column(
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
            )
          ],
        ),
      ),
    );
  }
}
