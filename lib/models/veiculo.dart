import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  String? id;
  String modelo;
  String marca;
  String placa;
  int ano;
  String tipoCombustivel;
  String userId;
  DateTime dataCriacao;

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
    required this.userId,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
      'userId': userId,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }

  // Criar Veiculo a partir de Map (do Firestore)
  factory Veiculo.fromJson(Map<String, dynamic> json, String id) {
    final veiculo = Veiculo(
      id: id,
      modelo: json['modelo'] ?? '',
      marca: json['marca'] ?? '',
      placa: json['placa'] ?? '',
      ano: json['ano'] ?? 0,
      tipoCombustivel: json['tipoCombustivel'] ?? '',
      userId: json['userId'] ?? '',
      dataCriacao: (json['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
    return veiculo;
  }

  // Para exibição
  String get nomeCompleto => '$marca $modelo ($placa)';

  @override
  String toString() => nomeCompleto;

  // Sobrescrever == e hashCode para comparação correta no Dropdown
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Veiculo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
