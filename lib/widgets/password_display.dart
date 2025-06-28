import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PasswordDisplay extends StatelessWidget {
  const PasswordDisplay({
    super.key,
    required this.currentPassword,
  });

  final String currentPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
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
      );
  }
}
