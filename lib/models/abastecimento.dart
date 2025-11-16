import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  String? id;
  DateTime data;
  double quantidadeLitros;
  double valorPago;
  double quilometragem;
  String tipoCombustivel;
  String veiculoId;
  double? consumo;
  String? observacao;
  String userId;

  Abastecimento({
    this.id,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    required this.veiculoId,
    this.consumo,
    this.observacao,
    required this.userId,
  });

  // Calcular preço por litro
  double get precoPorLitro => quantidadeLitros > 0 ? valorPago / quantidadeLitros : 0;

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'veiculoId': veiculoId,
      'consumo': consumo,
      'observacao': observacao,
      'userId': userId,
    };
  }

  // Criar Abastecimento a partir de Map (do Firestore)
  factory Abastecimento.fromJson(Map<String, dynamic> json, String id) {
    return Abastecimento(
      id: id,
      data: (json['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quantidadeLitros: (json['quantidadeLitros'] ?? 0).toDouble(),
      valorPago: (json['valorPago'] ?? 0).toDouble(),
      quilometragem: (json['quilometragem'] ?? 0).toDouble(),
      tipoCombustivel: json['tipoCombustivel'] ?? '',
      veiculoId: json['veiculoId'] ?? '',
      consumo: json['consumo']?.toDouble(),
      observacao: json['observacao'],
      userId: json['userId'] ?? '',
    );
  }
}
