class Filato {
  int? id;
  String nome;
  int peso;
  int? metraggio;
  String compratoDa;
  int quantitaPosseduta;
  String colore;
  List<double> spessoriUncinetto;
  String posizione;
  DateTime? dataAcquisto;
  Materiale materiale;

  Filato({
    this.id,
    required this.nome,
    required this.peso,
    this.metraggio,
    required this.compratoDa,
    required this.quantitaPosseduta,
    required this.colore,
    required this.spessoriUncinetto,
    required this.posizione,
    required this.dataAcquisto,
    required this.materiale
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'peso': peso,
      'metraggio': metraggio,
      'compratoDa': compratoDa,
      'quantitaPosseduta': quantitaPosseduta,
      'colore': colore,
      'spessoriUncinetto': spessoriUncinetto.join(','),
      'posizione': posizione,
      'dataAcquisto': dataAcquisto?.toIso8601String() ?? DateTime.now(),
      'materiale': materiale.toString().split('.').last
    };
  }

  factory Filato.fromMap(Map<String, dynamic> map) {
    return Filato(
      id: map['id'],
      nome: map['nome'],
      peso: map['peso'],
      metraggio: map['metraggio'],
      compratoDa: map['compratoDa'],
      quantitaPosseduta: map['quantitaPosseduta'],
      colore: map['colore'],
      spessoriUncinetto: (map['spessoriUncinetto'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((s) => double.parse(s))
        .toList(),
      posizione: map['posizione'],
      dataAcquisto: DateTime.parse(map['dataAcquisto']),
      materiale: Materiale.values.firstWhere(
        (e) => e.toString().split('.').last == map['materiale']
      )
    );
  }
}

enum Materiale {
  Lana,
  Cotone,
  Acrilico,
  Ciniglia,
  Fettuccia,
  Misto
}