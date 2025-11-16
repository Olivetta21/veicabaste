import '../models/abastecimento.dart';
import '../services/firestoreservice.dart';

class AbastecimentoViewModel {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<List<Abastecimento>>? abastecimentosStream;

  // Carregar abastecimentos do usuário
  void loadAbastecimentos(String userId) {
    abastecimentosStream = _firestoreService.getAbastecimentos(userId);
  }

  // Carregar abastecimentos por veículo
  void loadAbastecimentosByVeiculo(String veiculoId) {
    abastecimentosStream = _firestoreService.getAbastecimentosByVeiculo(veiculoId);
  }

  // Adicionar abastecimento
  Future<bool> addAbastecimento(Abastecimento abastecimento) async {
    try {
      await _firestoreService.addAbastecimento(abastecimento);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Atualizar abastecimento
  Future<bool> updateAbastecimento(String abastecimentoId, Abastecimento abastecimento) async {
    try {
      await _firestoreService.updateAbastecimento(abastecimentoId, abastecimento);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Excluir abastecimento
  Future<bool> deleteAbastecimento(String abastecimentoId) async {
    try {
      await _firestoreService.deleteAbastecimento(abastecimentoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Calcular consumo médio
  Future<double> calcularConsumoMedio(String veiculoId) async {
    try {
      return await _firestoreService.calcularConsumoMedio(veiculoId);
    } catch (e) {
      return 0;
    }
  }
}
