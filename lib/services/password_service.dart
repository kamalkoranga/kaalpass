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
  Timer? _rotationTimer;
  int? _lastWindowKey;
  final VoidCallback onPasswordUpdated;

  PasswordService({required this.onPasswordUpdated});

  Future<void> init() async {
    HomeWidget.setAppGroupId(appGroupId);
    final prefs = await SharedPreferences.getInstance();
    secret = prefs.getString('secret_key') ?? '';
    if (secret.isNotEmpty) {
      _updatePassword();
      _startPasswordTicker();
    }
  }

  Future<void> saveSecret(String newSecret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secret_key', newSecret);
    secret = newSecret;
    _updatePassword();
    _startPasswordTicker();
  }

  String getSecret() {
    return secret;
  }

  int get remainingSeconds {
    final now = DateTime.now().toUtc();
    final elapsedSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final remainder = elapsedSeconds % 30;
    return remainder == 0 ? 30 : 30 - remainder;
  }


  void _updatePassword() async {
    if (secret.isEmpty) return;
    final timeWindowKey = _currentWindowKey().toString();
    final input = utf8.encode(secret + timeWindowKey);
    final hash = sha256.convert(input).toString();
    currentPassword = hash.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 14);
    _lastWindowKey = int.parse(timeWindowKey);
    onPasswordUpdated();

    await HomeWidget.saveWidgetData(dataKey, currentPassword);
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  int _currentWindowKey() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 30000;
  }

  void _startPasswordTicker() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secret.isEmpty) return;

      final windowKey = _currentWindowKey();
      if (_lastWindowKey != windowKey) {
        _updatePassword();
      } else {
        onPasswordUpdated();
      }
    });
  }

  void dispose() {
    _rotationTimer?.cancel();
  }
}