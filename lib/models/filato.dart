class Filato {
  int? id;
  String nome;
  int peso;
  String compratoDa;
  int quantitaPosseduta;
  String colore;
  double spessoreUncinetto;
  String posizione;
  DateTime? dataAcquisto;
  Materiale materiale;

  Filato({
    this.id,
    required this.nome,
    required this.peso,
    required this.compratoDa,
    required this.quantitaPosseduta,
    required this.colore,
    required this.spessoreUncinetto,
    required this.posizione,
    required this.dataAcquisto,
    required this.materiale
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'peso': peso,
      'compratoDa': compratoDa,
      'quantitaPosseduta': quantitaPosseduta,
      'colore': colore,
      'spessoreUncinetto': spessoreUncinetto,
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
      compratoDa: map['compratoDa'],
      quantitaPosseduta: map['quantitaPosseduta'],
      colore: map['colore'],
      spessoreUncinetto: map['spessoreUncinetto']?.toDouble() ?? 0.0,
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
  Misto
}