import 'package:flutter/material.dart';
import 'package:kaal_pass/services/password_service.dart';
import 'package:kaal_pass/widgets/my_drawer.dart';
import 'package:kaal_pass/widgets/password_display.dart';
import 'package:kaal_pass/widgets/secret_key_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PasswordService passwordService;

  @override
  void initState() {
    super.initState();
    passwordService = PasswordService(onPasswordUpdated: () {
      setState(() {});
    });
    passwordService.init();
  }

  @override
  void dispose() {
    passwordService.dispose();
    super.dispose();
  }

  void _promptForSecret() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SecretKeyDialog(
        onSecretSaved: (secret) => passwordService.saveSecret(secret),
        currentSecret: passwordService.getSecret(),
      ),
    );

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,),
      drawer: MyDrawer(_promptForSecret),
      body: PasswordDisplay(password: passwordService.currentPassword),
    );
  }
}

