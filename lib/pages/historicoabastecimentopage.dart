import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../viewmodel/abastecimentoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../utils/mensagens.dart';
import 'formabastecimentopage.dart';

class HistoricoAbastecimentoPage extends StatefulWidget {
  @override
  _HistoricoAbastecimentoPageState createState() => _HistoricoAbastecimentoPageState();
}

class _HistoricoAbastecimentoPageState extends State<HistoricoAbastecimentoPage> {
  final AbastecimentoViewModel _abastecimentoViewModel = AbastecimentoViewModel();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  void initState() {
    super.initState();
    _carregarAbastecimentos();
  }

  void _carregarAbastecimentos() {
    final userId = AuthViewModel.userid;
    if (userId != null) {
      _abastecimentoViewModel.loadAbastecimentos(userId);
    } else {
      print('HistoricoAbastecimentoPage: Nenhum usuário logado!');
    }
  }

  Future<void> _navegarParaFormulario({Abastecimento? abastecimento}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrarAbastecimentoPage(abastecimento: abastecimento),
      ),
    );

    if (resultado == true) {
      _carregarAbastecimentos();
    }
  }

  Future<void> _confirmarExclusao(Abastecimento abastecimento) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o abastecimento de ${_formatDate(abastecimento.data)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      final sucesso = await _abastecimentoViewModel.deleteAbastecimento(abastecimento.id!);
      if (mounted) {
        mostrarMensagem(
          context,
          sucesso ? 'Abastecimento excluído com sucesso!' : 'Erro ao excluir abastecimento',
          tipo: sucesso ? TipoMensagem.sucesso : TipoMensagem.erro,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Abastecimentos'),
      ),
      body: StreamBuilder<List<Abastecimento>>(
        stream: _abastecimentoViewModel.abastecimentosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar abastecimentos: ${snapshot.error}'),
            );
          }

          final abastecimentos = snapshot.data ?? [];

          if (abastecimentos.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum abastecimento registrado',
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navegarParaFormulario(),
                    icon: Icon(Icons.add),
                    label: Text('Registrar Primeiro Abastecimento'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.local_gas_station, color: Colors.white),
                  ),
                  title: Text(
                    '${_formatNumber(abastecimento.quantidadeLitros)} L - ${_formatCurrency(abastecimento.valorPago)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Data: ${_formatDate(abastecimento.data)}'),
                      Text('Km: ${_formatNumber(abastecimento.quilometragem)}'),
                      Text('Preço/L: ${_formatCurrency(abastecimento.precoPorLitro)}'),
                      if (abastecimento.consumo != null)
                        Text(
                          'Consumo: ${_formatNumber(abastecimento.consumo!)} km/L',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navegarParaFormulario(abastecimento: abastecimento),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(abastecimento),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Registrar Abastecimento',
      ),
    );
  }
}
