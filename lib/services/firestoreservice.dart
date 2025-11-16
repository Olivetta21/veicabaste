import 'package:abast_veiculo/models/abastecimento.dart';
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

  // ==================== ABASTECIMENTOS ====================

  // Adicionar abastecimento
  Future<String> addAbastecimento(Abastecimento abastecimento) async {
    try {
      final docRef = await _firestore.collection('abastecimentos').add(abastecimento.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Erro ao adicionar abastecimento: $e';
    }
  }

  // Buscar abastecimentos do usuário
  Stream<List<Abastecimento>> getAbastecimentos(String userId) {
    print('FirestoreService: Buscando abastecimentos para userId: $userId');
    try {
      return _firestore
          .collection('abastecimentos')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        print('FirestoreService: Recebidos ${snapshot.docs.length} abastecimentos');
        final abastecimentos = snapshot.docs
            .map((doc) => Abastecimento.fromJson(doc.data(), doc.id))
            .toList();
        // Ordenar manualmente por data
        abastecimentos.sort((a, b) => b.data.compareTo(a.data));
        return abastecimentos;
      });
    } catch (e) {
      print('FirestoreService: Erro ao buscar abastecimentos: $e');
      rethrow;
    }
  }

  // Buscar abastecimentos por veículo
  Stream<List<Abastecimento>> getAbastecimentosByVeiculo(String veiculoId) {
    print('FirestoreService: Buscando abastecimentos para veiculoId: $veiculoId');
    try {
      return _firestore
          .collection('abastecimentos')
          .where('veiculoId', isEqualTo: veiculoId)
          .snapshots()
          .map((snapshot) {
        final abastecimentos = snapshot.docs
            .map((doc) => Abastecimento.fromJson(doc.data(), doc.id))
            .toList();
        // Ordenar manualmente por data
        abastecimentos.sort((a, b) => b.data.compareTo(a.data));
        return abastecimentos;
      });
    } catch (e) {
      print('FirestoreService: Erro ao buscar abastecimentos do veículo: $e');
      rethrow;
    }
  }

  // Atualizar abastecimento
  Future<void> updateAbastecimento(String abastecimentoId, Abastecimento abastecimento) async {
    try {
      await _firestore
          .collection('abastecimentos')
          .doc(abastecimentoId)
          .update(abastecimento.toJson());
    } catch (e) {
      throw 'Erro ao atualizar abastecimento: $e';
    }
  }

  // Excluir abastecimento
  Future<void> deleteAbastecimento(String abastecimentoId) async {
    try {
      await _firestore.collection('abastecimentos').doc(abastecimentoId).delete();
    } catch (e) {
      throw 'Erro ao excluir abastecimento: $e';
    }
  }

  // Calcular consumo médio
  Future<double> calcularConsumoMedio(String veiculoId) async {
    try {
      final snapshot = await _firestore
          .collection('abastecimentos')
          .where('veiculoId', isEqualTo: veiculoId)
          .where('consumo', isNull: false)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      double totalConsumo = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final consumo = doc.data()['consumo'];
        if (consumo != null) {
          totalConsumo += consumo;
          count++;
        }
      }

      return count > 0 ? totalConsumo / count : 0;
    } catch (e) {
      return 0;
    }
  }
}
