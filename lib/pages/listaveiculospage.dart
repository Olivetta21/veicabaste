import 'package:flutter/material.dart';
import '../viewmodel/veiculoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../models/veiculo.dart';
import '../utils/mensagens.dart';
import 'formveiculopage.dart';


class ListaVeiculosPage extends StatefulWidget {
  @override
  _ListaVeiculosPageState createState() => _ListaVeiculosPageState();
}

class _ListaVeiculosPageState extends State<ListaVeiculosPage> {
  final VeiculoViewModel _veiculoViewModel = VeiculoViewModel();

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  void _carregarVeiculos() {
    final userId = AuthViewModel.userid;    
    if (userId != null) {
      _veiculoViewModel.loadVeiculos(userId);
    } else {
      print('ListaVeiculosPage: Nenhum usuário logado!');
    }
  }

  Future<void> _navegarParaFormulario({Veiculo? veiculo}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormVeiculoPage(veiculo: veiculo),
      ),
    );

    // Se retornou true, recarregar a lista
    if (resultado == true) {
      _carregarVeiculos();
    }
  }

  Future<void> _confirmarExclusao(Veiculo veiculo) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o veículo ${veiculo.nomeCompleto}?'),
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
      final sucesso = await _veiculoViewModel.deleteVeiculo(veiculo.id!);
      if (mounted) {
        mostrarMensagem(
          context,
          sucesso
              ? 'Veículo excluído com sucesso!'
              : 'Erro ao excluir veículo',
          tipo: sucesso ? TipoMensagem.sucesso : TipoMensagem.erro,
        );
        if (sucesso) {
          _carregarVeiculos();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Veículos'),
      ),
      body: StreamBuilder<List<Veiculo>>(
        stream: _veiculoViewModel.veiculosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar veículos: ${snapshot.error}'),
            );
          }
          
          final veiculos = snapshot.data ?? [];
          
          if (veiculos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum veículo cadastrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navegarParaFormulario(),
                    icon: Icon(Icons.add),
                    label: Text('Cadastrar Primeiro Veículo'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.directions_car),
                  ),
                  title: Text(veiculo.nomeCompleto),
                  subtitle: Text('Ano: ${veiculo.ano}, Combustível: ${veiculo.tipoCombustivel}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navegarParaFormulario(veiculo: veiculo),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(veiculo),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Adicionar Veículo',
      ),
    );
  }
}




