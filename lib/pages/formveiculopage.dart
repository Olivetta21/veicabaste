import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../viewmodel/veiculoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../utils/constantes.dart';
import '../utils/mensagens.dart';

class FormVeiculoPage extends StatefulWidget {
  final Veiculo? veiculo; // null = criar novo, não-null = editar

  const FormVeiculoPage({Key? key, this.veiculo}) : super(key: key);

  @override
  _FormVeiculoPageState createState() => _FormVeiculoPageState();
}

class _FormVeiculoPageState extends State<FormVeiculoPage> {
  final _formKey = GlobalKey<FormState>();
  final VeiculoViewModel _veiculoViewModel = VeiculoViewModel();

  late TextEditingController _modeloController;
  late TextEditingController _marcaController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  
  late String _tipoCombustivel;

  @override
  void initState() {
    super.initState();
    // Se estiver editando, preencher os campos
    _modeloController = TextEditingController(text: widget.veiculo?.modelo ?? '');
    _marcaController = TextEditingController(text: widget.veiculo?.marca ?? '');
    _placaController = TextEditingController(text: widget.veiculo?.placa ?? '');
    _anoController = TextEditingController(
      text: widget.veiculo?.ano.toString() ?? '',
    );
    // Usa o combustível do veículo se estiver editando, senão usa o primeiro da lista (índice 0)
    _tipoCombustivel = widget.veiculo?.tipoCombustivel ?? Constantes.tiposCombustivel[0];
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = AuthViewModel.userid;
    if (userId == null) {
      mostrarMensagem(context, 'Erro: Usuário não autenticado', tipo: TipoMensagem.erro);
      return;
    }

    try {
      final veiculo = Veiculo(
        id: widget.veiculo?.id,
        modelo: _modeloController.text.trim(),
        marca: _marcaController.text.trim(),
        placa: _placaController.text.trim().toUpperCase(),
        ano: int.parse(_anoController.text.trim()),
        tipoCombustivel: _tipoCombustivel,
        userId: userId,
        dataCriacao: widget.veiculo?.dataCriacao,
      );

      bool sucesso;
      if (widget.veiculo == null) {
        // Criar novo
        sucesso = await _veiculoViewModel.addVeiculo(veiculo);
        if (sucesso) {
          mostrarMensagem(context, 'Veículo cadastrado com sucesso!', tipo: TipoMensagem.sucesso);
        }
      } else {
        // Atualizar existente
        sucesso = await _veiculoViewModel.updateVeiculo(widget.veiculo!.id!, veiculo);
        if (sucesso) {
          mostrarMensagem(context, 'Veículo atualizado com sucesso!', tipo: TipoMensagem.sucesso);
        }
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
      } else {
        mostrarMensagem(context, 'Erro ao salvar veículo', tipo: TipoMensagem.erro);
      }
    } catch (e) {
      mostrarMensagem(context, 'Erro: $e', tipo: TipoMensagem.erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.veiculo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Veículo' : 'Novo Veículo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a marca';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o modelo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                  hintText: 'ABC-1234',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a placa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o ano';
                  }
                  final ano = int.tryParse(value.trim());
                  if (ano == null) {
                    return 'Ano inválido';
                  }
                  if (ano < 1900 || ano > DateTime.now().year + 1) {
                    return 'Ano deve estar entre 1900 e ${DateTime.now().year + 1}';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoCombustivel,
                decoration: InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                items: Constantes.tiposCombustivel.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoCombustivel = value;
                    });
                  }
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEdicao ? 'ATUALIZAR' : 'CADASTRAR',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
