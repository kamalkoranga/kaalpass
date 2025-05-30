import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kaal_pass/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appGroupId = "klka.kaalpass";
  String androidWidgetName = "KaalPassWidget";
  String dataKey = "today's_password";

  final String secret = 'MY_SUPER_SECRET'; // Replace with your actual secret
  String currentPassword = '';
  Timer? midnightTimer;

  @override
  void initState() {
    super.initState();
    _updatePassword();
    _scheduleMidnightUpdate();
    HomeWidget.setAppGroupId(appGroupId);
  }

  void _updatePassword() async {
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
        child: Center(
          child: CupertinoSwitch(
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()
          ),
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
