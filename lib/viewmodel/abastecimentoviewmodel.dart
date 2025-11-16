import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../services/firestoreservice.dart';

class AbastecimentoViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<List<Abastecimento>>? abastecimentosStream;

  // Carregar abastecimentos do usuário
  void loadAbastecimentos(String userId) {
    print('AbastecimentoViewModel: Carregando abastecimentos para userId: $userId');
    abastecimentosStream = _firestoreService.getAbastecimentos(userId);
  }

  // Carregar abastecimentos por veículo
  void loadAbastecimentosByVeiculo(String veiculoId) {
    print('AbastecimentoViewModel: Carregando abastecimentos para veiculoId: $veiculoId');
    abastecimentosStream = _firestoreService.getAbastecimentosByVeiculo(veiculoId);
  }

  // Adicionar abastecimento
  Future<bool> addAbastecimento(Abastecimento abastecimento) async {
    try {
      final docId = await _firestoreService.addAbastecimento(abastecimento);
      print('AbastecimentoViewModel: Abastecimento adicionado com ID: $docId');
      return true;
    } catch (e) {
      print('AbastecimentoViewModel: Erro ao adicionar abastecimento: $e');
      return false;
    }
  }

  // Atualizar abastecimento
  Future<bool> updateAbastecimento(String abastecimentoId, Abastecimento abastecimento) async {
    try {
      await _firestoreService.updateAbastecimento(abastecimentoId, abastecimento);
      print('AbastecimentoViewModel: Abastecimento atualizado');
      return true;
    } catch (e) {
      print('AbastecimentoViewModel: Erro ao atualizar abastecimento: $e');
      return false;
    }
  }

  // Excluir abastecimento
  Future<bool> deleteAbastecimento(String abastecimentoId) async {
    try {
      await _firestoreService.deleteAbastecimento(abastecimentoId);
      print('AbastecimentoViewModel: Abastecimento excluído');
      return true;
    } catch (e) {
      print('AbastecimentoViewModel: Erro ao excluir abastecimento: $e');
      return false;
    }
  }

  // Calcular consumo médio
  Future<double> calcularConsumoMedio(String veiculoId) async {
    try {
      return await _firestoreService.calcularConsumoMedio(veiculoId);
    } catch (e) {
      print('AbastecimentoViewModel: Erro ao calcular consumo médio: $e');
      return 0;
    }
  }
}
