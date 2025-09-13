import 'package:flutter/material.dart';
import 'package:yarn_tracker/db/database_helper.dart';

class SecretScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecretScreenState();
}

class _SecretScreenState extends State<SecretScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Segreti")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // occupa solo lo spazio necessario
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: DatabaseHelper.instance.exportDatabase,
              child: Text("Export db"),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: DatabaseHelper.instance.importDatabase,
              child: Text("Import db"),
            ),
          ],
        ),
      ),
    );
  }
}
