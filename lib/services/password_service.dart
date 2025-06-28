import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordService {
  static const String appGroupId = "klka.kaalpass";
  static const String androidWidgetName = "KaalPassWidget";
  static const String dataKey = "today's_password";

  String secret = '';
  String currentPassword = '';
  Timer? _midnightTimer;
  final VoidCallback onPasswordUpdated;

  PasswordService({required this.onPasswordUpdated});

  Future<void> init() async {
    HomeWidget.setAppGroupId(appGroupId);
    final prefs = await SharedPreferences.getInstance();
    secret = prefs.getString('secret_key') ?? '';
    if (secret.isNotEmpty) {
      _updatePassword();
      _scheduleMidnightUpdate();
    }
  }

  Future<void> saveSecret(String newSecret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secret_key', newSecret);
    secret = newSecret;
    _updatePassword();
    _scheduleMidnightUpdate();
  }

  String getSecret() {
    return secret;
  }


  void _updatePassword() async {
    if (secret.isEmpty) return;
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final input = utf8.encode(secret + dateKey);
    final hash = sha256.convert(input).toString();
    currentPassword = hash.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 14);
    onPasswordUpdated();

    await HomeWidget.saveWidgetData(dataKey, currentPassword);
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    _midnightTimer?.cancel();
    _midnightTimer = Timer(duration, () {
      _updatePassword();
      _scheduleMidnightUpdate();
    });
  }

  void dispose() {
    _midnightTimer?.cancel();
  }
}