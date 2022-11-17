import 'package:flutter/material.dart';

Future<String?> inputDialog(BuildContext context, String label) async {
  TextEditingController controller = TextEditingController();
  return showDialog<String?>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Column(children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                ),
                const SizedBox(width: 16,),
                ElevatedButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ]));
    },
  );
}
