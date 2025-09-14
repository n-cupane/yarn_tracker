import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn_tracker/screens/secret_screen.dart';
import 'package:yarn_tracker/screens/welcome_screen.dart';
import '../models/filato.dart';
import '../db/database_helper.dart';
import 'filato_form_screen.dart';

class FilatoListScreen extends StatefulWidget {
  @override
  _FilatoListScreenState createState() => _FilatoListScreenState();
}

class _FilatoListScreenState extends State<FilatoListScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  List<Filato> filati = [];
  List<Filato> filatiFiltrati = [];
  String? _userName;

  String _searchQuery = "";
  String? _selectedPosizione;
  List<double> _selectedSpessori = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFilati();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');

    if (name == null || name.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen())
        );
    }

    setState(() {
      _userName = name;
    });
  }

  Future<void> _loadFilati() async {
    final data = await DatabaseHelper.instance.getAllFilati();
    setState(() {
      filati = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filatiFiltrati = filati.where((f) {
        final matchSearch = f.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.colore.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchPosizione = _selectedPosizione == null || f.posizione == _selectedPosizione;
        final matchSpessori = _selectedSpessori.isEmpty ||
              f.spessoriUncinetto.any((s) => _selectedSpessori.contains(s));

        return matchSearch && matchPosizione && matchSpessori;
      }).toList();
    });
  }

  Future<void> _openForm({Filato? filato}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilatoFormScreen(filato: filato)),
    );
    if (result == true) {
      _loadFilati();
    }
  }

  Future<void> _deleteFilato(int id) async {
    await DatabaseHelper.instance.deleteFilato(id);
    _loadFilati();
  }

  void _handleSecretTap() {
    final now = DateTime.now();

    if (_lastTapTime == null || now.difference(_lastTapTime!) > Duration(seconds: 2)) {
        _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = DateTime.now();

    if (_tapCount == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SecretScreen())
        );
    }
  }

  void _openFilterModal(BuildContext context, List<String> posizioni, List<double> spessori) {
  String? tempPosizione = _selectedPosizione;
  List<double> tempSpessori = List.from(_selectedSpessori);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Applica filtri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            // Posizione
            Text("Posizione", style: TextStyle(fontWeight: FontWeight.w500)),
            DropdownButton<String>(
              hint: Text("Seleziona posizione"),
              isExpanded: true,
              value: tempPosizione,
              items: [
                DropdownMenuItem(value: null, child: Text("Tutte")),
                ...posizioni.map((p) => DropdownMenuItem(value: p, child: Text(p))),
              ],
              onChanged: (value) {
                tempPosizione = value;
              },
            ),
            SizedBox(height: 16),

            // Spessori multipli
            Text("Spessori", style: TextStyle(fontWeight: FontWeight.w500)),
            MultiSelectDialogField<double>(
              items: spessori
                  .map((s) => MultiSelectItem<double>(s, "${s.toStringAsFixed(1)} mm"))
                  .toList(),
              initialValue: tempSpessori,
              title: Text("Seleziona spessori"),
              buttonText: Text("Spessori"),
              onConfirm: (values) {
                tempSpessori = values;
              },
            ),
            SizedBox(height: 24),

            // Pulsanti
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPosizione = null;
                      _selectedSpessori = [];
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Reset"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPosizione = tempPosizione;
                      _selectedSpessori = tempSpessori;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Applica"),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // ricavo le posizioni e spessori disponibili
    final posizioni = filati.map((f) => f.posizione).toSet().toList();
    final spessori = filati
        .expand((f) => f.spessoriUncinetto)
        .toSet()
        .toList()
        ..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text("I filati di $_userName"),
        actions: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: _handleSecretTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // dimensione tappabile
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 36,
                height: 36,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔎 Barra di ricerca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cerca per nome o colore...",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  // 🎯 Filtri
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    _openFilterModal(context, posizioni, spessori);
                  },
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          Divider(),
          // 📋 Lista filati
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFilati,
              child: ListView.builder(
              itemCount: filatiFiltrati.length,
              itemBuilder: (context, index) {
                final f = filatiFiltrati[index];
                return Dismissible(
                  key: ValueKey(f.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final deletedFilato = f;
                    await _deleteFilato(f.id!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${f.nome} eliminato"),
                        action: SnackBarAction(
                          label: 'Annulla',
                           onPressed: () async {
                            await DatabaseHelper.instance.insertFilato(deletedFilato);
                            _loadFilati();
                           }
                          ),
                        )
                    );
                  },
                  child: ListTile(
                  title: Text(f.nome),
                  subtitle: Text('${f.colore} - ${f.peso}g - ${f.quantitaPosseduta} pezzi'),
                  onTap: () => _openForm(filato: f), // modifica
                )
                  );
              },
            ),
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28)
        ),
        child: Icon(Icons.add, size: 32,),
      ),
    );
  }
}