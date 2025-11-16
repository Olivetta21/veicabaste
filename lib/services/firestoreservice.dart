import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== VEÍCULOS ====================

  // Adicionar veículo
  Future<String> addVeiculo(Veiculo veiculo) async {
    try {
      final docRef = await _firestore.collection('veiculos').add(veiculo.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Erro ao adicionar veículo: $e';
    }
  }

  // Buscar veículos do usuário
  Stream<List<Veiculo>> getVeiculos(String userId) {
    print('FirestoreService: Buscando veículos para userId: $userId');
    try {
      return _firestore
          .collection('veiculos')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final veiculos = snapshot.docs
            .map((doc) {
              print('Documento ID: ${doc.id}, Dados: ${doc.data()}');
              return Veiculo.fromJson(doc.data(), doc.id);
            })
            .toList();
        // Ordenar manualmente por dataCriacao
        veiculos.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
        return veiculos;
      });
    } catch (e) {
      print('FirestoreService: Erro ao buscar veículos: $e');
      rethrow;
    }
  }

  // Buscar um veículo específico
  Future<Veiculo?> getVeiculo(String veiculoId) async {
    try {
      final doc = await _firestore.collection('veiculos').doc(veiculoId).get();
      if (doc.exists) {
        return Veiculo.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Erro ao buscar veículo: $e';
    }
  }

  // Atualizar veículo
  Future<void> updateVeiculo(String veiculoId, Veiculo veiculo) async {
    try {
      await _firestore.collection('veiculos').doc(veiculoId).update(veiculo.toJson());
    } catch (e) {
      throw 'Erro ao atualizar veículo: $e';
    }
  }

  // Excluir veículo
  Future<void> deleteVeiculo(String veiculoId) async {
    try {
      // Primeiro exclui os abastecimentos relacionados
      final abastecimentos = await _firestore
          .collection('abastecimentos')
          .where('veiculoId', isEqualTo: veiculoId)
          .get();
      
      for (var doc in abastecimentos.docs) {
        await doc.reference.delete();
      }
      
      // Depois exclui o veículo
      await _firestore.collection('veiculos').doc(veiculoId).delete();
    } catch (e) {
      throw 'Erro ao excluir veículo: $e';
    }
  }

}
