import '../models/veiculo.dart';
import '../services/firestoreservice.dart';

class VeiculoViewModel {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<List<Veiculo>>? veiculosStream;

  // Carregar veículos do usuário
  void loadVeiculos(String userId) {
    veiculosStream = _firestoreService.getVeiculos(userId);
  }

  // Adicionar veículo
  Future<bool> addVeiculo(Veiculo veiculo) async {
    try {
      await _firestoreService.addVeiculo(veiculo);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Atualizar veículo
  Future<bool> updateVeiculo(String veiculoId, Veiculo veiculo) async {

    try {
      await _firestoreService.updateVeiculo(veiculoId, veiculo);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Excluir veículo
  Future<bool> deleteVeiculo(String veiculoId) async {
    try {
      await _firestoreService.deleteVeiculo(veiculoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Buscar veículo por ID
  Future<Veiculo?> getVeiculo(String veiculoId) async {
    try {
      return await _firestoreService.getVeiculo(veiculoId);
    } catch (e) {
      return null;
    }
  }
}
