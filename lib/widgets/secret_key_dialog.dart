import 'package:flutter/material.dart';

class SecretKeyDialog extends StatefulWidget {
  final void Function(String) onSecretSaved;
  final String currentSecret;

  const SecretKeyDialog({super.key, required this.onSecretSaved, this.currentSecret=""});

  @override
  State<SecretKeyDialog> createState() => _SecretKeyDialogState();
}
class _SecretKeyDialogState extends State<SecretKeyDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Secret Key'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.currentSecret.isNotEmpty)
                Text(
                'Current Secret Key: ${widget.currentSecret}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary.withAlpha(153), // 0.6 * 255 ≈ 153
                ),
              ),
            SizedBox(height: 16.0),
          TextField(
            controller: _controller,
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Secret Key'),
          ),
          const SizedBox(height: 24.0),
          Text(
            'This key will be used to generate your daily password. It should match the one used in your bash script.',
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
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primaryFixedDim)),
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
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              widget.onSecretSaved(text);
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'Save',
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ],
    );
  }
}
