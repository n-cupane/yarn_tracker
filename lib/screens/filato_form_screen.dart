import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import '../models/filato.dart';
import '../db/database_helper.dart';

class FilatoFormScreen extends StatefulWidget {
  final Filato? filato;

  FilatoFormScreen({this.filato});

  @override
  _FilatoFormScreenState createState() => _FilatoFormScreenState();
}

class _FilatoFormScreenState extends State<FilatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _posizioniEsistenti = [];
  List<String> _compratoDaEsistenti = [];
  final List<double> _allSpessori = List.generate(20, (i) => (i + 1) * 0.5);
  List<double> _selectedSpessori = [];

  // Controller per i campi
  late TextEditingController _nomeController;
  late TextEditingController _pesoController;
  late TextEditingController _metraggioController;
  late TextEditingController _compratoDaController;
  late TextEditingController _quantitaController;
  late TextEditingController _coloreController;
  late TextEditingController _spessoreController;
  late TextEditingController _posizioneController;

  DateTime _dataAcquisto = DateTime.now();
  Materiale? _selectedMateriale;

  @override
  void initState() {
    super.initState();
    _loadFilati();
    final f = widget.filato;
    _nomeController = TextEditingController(text: f?.nome ?? "");
    _pesoController = TextEditingController(text: f?.peso.toString() ?? "");
    _metraggioController = TextEditingController(text: f?.metraggio.toString() ?? "");
    _compratoDaController = TextEditingController(text: f?.compratoDa ?? "");
    _quantitaController = TextEditingController(text: f?.quantitaPosseduta.toString() ?? "");
    _coloreController = TextEditingController(text: f?.colore ?? "");
    _posizioneController = TextEditingController(text: f?.posizione ?? "");
    _dataAcquisto = f?.dataAcquisto ?? DateTime.now();
    _selectedMateriale = f?.materiale;
    _selectedSpessori = widget.filato?.spessoriUncinetto ?? [];

  }

  Future<void> _loadFilati() async {
    final data = await DatabaseHelper.instance.getAllFilati();
    setState(() {
      _posizioniEsistenti = data.map((f) => f.posizione).toSet().toList();
      _compratoDaEsistenti = data.map((f) => f.compratoDa).toSet().toList();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pesoController.dispose();
    _metraggioController.dispose();
    _compratoDaController.dispose();
    _quantitaController.dispose();
    _coloreController.dispose();
    _spessoreController.dispose();
    _posizioneController.dispose();
    super.dispose();
  }

  Future<void> _saveFilato() async {
    if (_formKey.currentState!.validate()) {
      final filato = Filato(
        id: widget.filato?.id,
        nome: _nomeController.text,
        peso: int.parse(_pesoController.text),
        metraggio: int.parse(_metraggioController.text),
        compratoDa: _compratoDaController.text,
        quantitaPosseduta: int.parse(_quantitaController.text),
        colore: _coloreController.text,
        spessoriUncinetto: _selectedSpessori,
        posizione: _posizioneController.text,
        dataAcquisto: _dataAcquisto,
        materiale: _selectedMateriale!
      );

      if (widget.filato == null) {
        await DatabaseHelper.instance.insertFilato(filato);
      } else {
        await DatabaseHelper.instance.updateFilato(filato);
      }

      Navigator.pop(context, true); // ritorna alla lista
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataAcquisto,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dataAcquisto = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filato == null ? "Aggiungi Filato" : "Modifica Filato"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: "Nome"),
                validator: (value) => value!.isEmpty ? "Inserisci un nome" : null,
              ),
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Peso (g)"),
                validator: (value) => value!.isEmpty ? "Inserisci il peso" : null,
              ),
              TextFormField(
                controller: _metraggioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Metraggio"),
                validator: (value) => value!.isEmpty ? "Inserisci il metraggio" : null,
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _compratoDaEsistenti.where((p) => 
                  p.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: _compratoDaController,
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: focusNode,
                    decoration: InputDecoration(labelText: "Comprato da"),
                    onEditingComplete: onEditingComplete,
                  );
                },
                onSelected: (String selection) {
                  _compratoDaController.text = selection;
                },
              ),
              TextFormField(
                controller: _quantitaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantità posseduta"),
                validator: (value) => value!.isEmpty ? "Inserisci la quantità" : null,
              ),
              TextFormField(
                controller: _coloreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: "Colore"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Spessori uncinetto",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              MultiSelectDialogField<double>(
                items: _allSpessori
                    .map((s) => MultiSelectItem<double>(s, "${s.toStringAsFixed(1)} mm"))
                    .toList(),
                title: Text("Seleziona spessori"),
                buttonText: Text("Seleziona"),
                initialValue: _selectedSpessori,
                onConfirm: (values) {
                  setState(() {
                    _selectedSpessori = values;
                  });
                },
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _posizioniEsistenti.where((p) => 
                  p.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: _posizioneController,
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: focusNode,
                    decoration: InputDecoration(labelText: "Posizione"),
                    onEditingComplete: onEditingComplete,
                  );
                },
                onSelected: (String selection) {
                  _posizioneController.text = selection;
                },
              ),
              DropdownButtonFormField<Materiale>(
                initialValue: _selectedMateriale,
                decoration: InputDecoration(labelText: "Materiale"),
                items: Materiale.values.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMateriale = value;
                  });
                },
                validator: (value) => value == null ? "Seleziona un materiale" : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text("Data acquisto: ${_dataAcquisto.toLocal().toString().split(' ')[0]}"),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text("Seleziona"),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFilato,
                child: Text("Salva"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
