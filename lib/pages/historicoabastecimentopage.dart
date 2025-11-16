import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../viewmodel/abastecimentoviewmodel.dart';
import '../viewmodel/veiculoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../utils/mensagens.dart';
import 'formabastecimentopage.dart';

class HistoricoAbastecimentoPage extends StatefulWidget {
  @override
  _HistoricoAbastecimentoPageState createState() => _HistoricoAbastecimentoPageState();
}

class _HistoricoAbastecimentoPageState extends State<HistoricoAbastecimentoPage> {
  final AbastecimentoViewModel _abastecimentoViewModel = AbastecimentoViewModel();
  final VeiculoViewModel _veiculoViewModel = VeiculoViewModel();
  final Map<String, Veiculo> _veiculosCache = {};

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
    _carregarVeiculos();
  }

  void _carregarAbastecimentos() {
    final userId = AuthViewModel.userid;
    if (userId != null) {
      _abastecimentoViewModel.loadAbastecimentos(userId);
    }
  }

  void _carregarVeiculos() {
    final userId = AuthViewModel.userid;
    if (userId != null) {
      _veiculoViewModel.loadVeiculos(userId);
      _veiculoViewModel.veiculosStream?.listen((veiculos) {
        setState(() {
          for (var veiculo in veiculos) {
            if (veiculo.id != null) {
              _veiculosCache[veiculo.id!] = veiculo;
            }
          }
        });
      });
    }
  }

  String _getNomeVeiculo(String veiculoId) {
    final veiculo = _veiculosCache[veiculoId];
    if (veiculo != null) {
      return '${veiculo.marca} ${veiculo.modelo} - ${veiculo.placa}';
    }
    return 'Veículo não encontrado';
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
            padding: const EdgeInsets.all(8.0),
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              final theme = Theme.of(context);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.local_gas_station, color: theme.colorScheme.onPrimary),
                  ),
                  title: Text(
                    _getNomeVeiculo(abastecimento.veiculoId),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${_formatNumber(abastecimento.quantidadeLitros)} L - ${_formatCurrency(abastecimento.valorPago)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Data: ${_formatDate(abastecimento.data)}',
                        style: theme.textTheme.bodySmall,
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.local_gas_station,
                            label: 'Combustível',
                            value: abastecimento.tipoCombustivel,
                            theme: theme,
                          ),
                          _buildDetailRow(
                            icon: Icons.speed,
                            label: 'Quilometragem',
                            value: '${_formatNumber(abastecimento.quilometragem)} km',
                            theme: theme,
                          ),
                          _buildDetailRow(
                            icon: Icons.attach_money,
                            label: 'Preço por Litro',
                            value: _formatCurrency(abastecimento.precoPorLitro),
                            theme: theme,
                          ),
                          if (abastecimento.consumo != null)
                            _buildDetailRow(
                              icon: Icons.show_chart,
                              label: 'Consumo',
                              value: '${_formatNumber(abastecimento.consumo!)} km/L',
                              theme: theme,
                              valueColor: Colors.green,
                            ),
                          if (abastecimento.observacao != null && 
                              abastecimento.observacao!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.note,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Observação:',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            abastecimento.observacao!,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
