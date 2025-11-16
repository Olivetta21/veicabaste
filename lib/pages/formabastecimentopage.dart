import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../viewmodel/abastecimentoviewmodel.dart';
import '../viewmodel/veiculoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../utils/constantes.dart';
import '../utils/mensagens.dart';

class RegistrarAbastecimentoPage extends StatefulWidget {
  final Abastecimento? abastecimento; // null = criar novo, não-null = editar

  const RegistrarAbastecimentoPage({Key? key, this.abastecimento}) : super(key: key);

  @override
  _RegistrarAbastecimentoPageState createState() => _RegistrarAbastecimentoPageState();
}

class _RegistrarAbastecimentoPageState extends State<RegistrarAbastecimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final AbastecimentoViewModel _abastecimentoViewModel = AbastecimentoViewModel();
  final VeiculoViewModel _veiculoViewModel = VeiculoViewModel();

  late TextEditingController _quantidadeController;
  late TextEditingController _valorController;
  late TextEditingController _quilometragemController;
  late TextEditingController _consumoController;
  late TextEditingController _observacaoController;

  DateTime _dataSelecionada = DateTime.now();
  String? _veiculoIdSelecionado;
  late String _tipoCombustivel;
  List<Veiculo> _veiculos = [];
  bool _isLoadingVeiculos = true;

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
    
    // Se estiver editando, preencher os campos
    _quantidadeController = TextEditingController(
      text: widget.abastecimento?.quantidadeLitros.toStringAsFixed(2) ?? '',
    );
    _valorController = TextEditingController(
      text: widget.abastecimento?.valorPago.toStringAsFixed(2) ?? '',
    );
    _quilometragemController = TextEditingController(
      text: widget.abastecimento?.quilometragem.toStringAsFixed(0) ?? '',
    );
    _consumoController = TextEditingController(
      text: widget.abastecimento?.consumo?.toStringAsFixed(2) ?? '',
    );
    _observacaoController = TextEditingController(
      text: widget.abastecimento?.observacao ?? '',
    );
    
    _dataSelecionada = widget.abastecimento?.data ?? DateTime.now();
    _veiculoIdSelecionado = widget.abastecimento?.veiculoId;
    _tipoCombustivel = widget.abastecimento?.tipoCombustivel ?? Constantes.tiposCombustivel[0];
  }

  Future<void> _carregarVeiculos() async {
    final userId = AuthViewModel.userid;
    if (userId != null) {
      try {
        // Usar o Stream do VeiculoViewModel
        _veiculoViewModel.loadVeiculos(userId);
        // Aguardar o primeiro evento do stream
        _veiculos = await _veiculoViewModel.veiculosStream!.first;
        setState(() {
          _isLoadingVeiculos = false;
          
          // Auto-selecionar tipo de combustível do veículo se estiver criando novo
          if (widget.abastecimento == null && _veiculoIdSelecionado != null) {
            final veiculo = _veiculos.firstWhere((v) => v.id == _veiculoIdSelecionado);
            _tipoCombustivel = veiculo.tipoCombustivel;
          }
        });
      } catch (e) {
        setState(() {
          _isLoadingVeiculos = false;
        });
        mostrarMensagem(context, 'Erro ao carregar veículos', tipo: TipoMensagem.erro);
      }
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    _quilometragemController.dispose();
    _consumoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_veiculoIdSelecionado == null) {
      mostrarMensagem(context, 'Por favor, selecione um veículo', tipo: TipoMensagem.aviso);
      return;
    }

    final userId = AuthViewModel.userid;
    if (userId == null) {
      mostrarMensagem(context, 'Erro: Usuário não autenticado', tipo: TipoMensagem.erro);
      return;
    }

    try {
      final abastecimento = Abastecimento(
        id: widget.abastecimento?.id,
        data: _dataSelecionada,
        quantidadeLitros: double.parse(_quantidadeController.text.replaceAll(',', '.')),
        valorPago: double.parse(_valorController.text.replaceAll(',', '.')),
        quilometragem: double.parse(_quilometragemController.text.replaceAll(',', '.')),
        tipoCombustivel: _tipoCombustivel,
        veiculoId: _veiculoIdSelecionado!,
        consumo: _consumoController.text.isEmpty 
            ? null 
            : double.parse(_consumoController.text.replaceAll(',', '.')),
        observacao: _observacaoController.text.isEmpty ? null : _observacaoController.text,
        userId: userId,
      );

      bool sucesso;
      if (widget.abastecimento == null) {
        // Criar novo
        sucesso = await _abastecimentoViewModel.addAbastecimento(abastecimento);
        if (sucesso) {
          mostrarMensagem(context, 'Abastecimento registrado com sucesso!', tipo: TipoMensagem.sucesso);
        }
      } else {
        // Atualizar existente
        sucesso = await _abastecimentoViewModel.updateAbastecimento(
          widget.abastecimento!.id!, 
          abastecimento,
        );
        if (sucesso) {
          mostrarMensagem(context, 'Abastecimento atualizado com sucesso!', tipo: TipoMensagem.sucesso);
        }
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop(true);
      } else {
        mostrarMensagem(context, 'Erro ao salvar abastecimento', tipo: TipoMensagem.erro);
      }
    } catch (e) {
      mostrarMensagem(context, 'Erro: $e', tipo: TipoMensagem.erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.abastecimento != null;

    if (_isLoadingVeiculos) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Carregando...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_veiculos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Registrar Abastecimento'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Você precisa cadastrar um veículo primeiro',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('VOLTAR'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Abastecimento' : 'Registrar Abastecimento'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Veículo
              DropdownButtonFormField<String>(
                value: _veiculoIdSelecionado,
                decoration: InputDecoration(
                  labelText: 'Veículo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: _veiculos.map((veiculo) {
                  return DropdownMenuItem(
                    value: veiculo.id,
                    child: Text(veiculo.nomeCompleto),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _veiculoIdSelecionado = value;
                    // Auto-selecionar tipo de combustível do veículo
                    if (value != null) {
                      final veiculo = _veiculos.firstWhere((v) => v.id == value);
                      _tipoCombustivel = veiculo.tipoCombustivel;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um veículo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Data
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_dataSelecionada)),
                ),
              ),
              SizedBox(height: 16),
              
              // Quantidade de Litros
              TextFormField(
                controller: _quantidadeController,
                decoration: InputDecoration(
                  labelText: 'Quantidade (Litros)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a quantidade';
                  }
                  final numero = double.tryParse(value.replaceAll(',', '.'));
                  if (numero == null || numero <= 0) {
                    return 'Quantidade inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Valor Pago
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Valor Pago (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o valor';
                  }
                  final numero = double.tryParse(value.replaceAll(',', '.'));
                  if (numero == null || numero <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Quilometragem
              TextFormField(
                controller: _quilometragemController,
                decoration: InputDecoration(
                  labelText: 'Quilometragem (km)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a quilometragem';
                  }
                  final numero = double.tryParse(value.replaceAll(',', '.'));
                  if (numero == null || numero < 0) {
                    return 'Quilometragem inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Tipo de Combustível
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
              SizedBox(height: 16),
              
              // Consumo (Opcional)
              TextFormField(
                controller: _consumoController,
                decoration: InputDecoration(
                  labelText: 'Consumo (km/L) - Opcional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.show_chart),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              
              // Observação (Opcional)
              TextFormField(
                controller: _observacaoController,
                decoration: InputDecoration(
                  labelText: 'Observação - Opcional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Adicione uma observação...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              
              // Botão Salvar
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEdicao ? 'ATUALIZAR' : 'REGISTRAR',
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
