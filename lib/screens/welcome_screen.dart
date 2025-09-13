import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn_tracker/screens/filato_list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');

    if (name != null && name.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FilatoListScreen())
      );
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
      // Primo avvio: chiedi il nome
      return Scaffold(
        appBar: AppBar(title: Text("Benvenuto")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 80),
              Text("Inserisci il tuo nome:"),
              TextField(controller: _controller),
              SizedBox(height: 100),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _saveUserName(_controller.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  backgroundColor: Colors.teal,
                  elevation: 5
                ),
                child: Text(
                  "Salva",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  ),
              )
            ],
          ),
        ),
      );
  }
}
