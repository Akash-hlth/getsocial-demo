import 'package:flutter/material.dart';

class AddMessageDialog extends StatefulWidget {
  @override
  _AddMessageDialogState createState() => _AddMessageDialogState();
}

class _AddMessageDialogState extends State<AddMessageDialog> {
  final _activityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(
                hintText: "Type a message here",
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.green),
              ),
              onPressed: () {
                final message = _activityController.text;
                Navigator.pop<String>(context, message);
              },
              child: Text(
                'Add Activity',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
