import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../viewmodel/abastecimentoviewmodel.dart';
import '../viewmodel/veiculoviewmodel.dart';
import '../viewmodel/authviewmodel.dart';
import '../widgets/app_drawer.dart';

class GraficosConsumoPage extends StatefulWidget {
  const GraficosConsumoPage({Key? key}) : super(key: key);

  @override
  _GraficosConsumoPageState createState() => _GraficosConsumoPageState();
}

class _GraficosConsumoPageState extends State<GraficosConsumoPage> with SingleTickerProviderStateMixin {
  final AbastecimentoViewModel _abastecimentoViewModel = AbastecimentoViewModel();
  final VeiculoViewModel _veiculoViewModel = VeiculoViewModel();
  
  List<Veiculo> _veiculos = [];
  String? _veiculoSelecionadoId;
  List<Abastecimento> _abastecimentos = [];
  bool _isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _carregarVeiculos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _carregarVeiculos() async {
    setState(() => _isLoading = true);
    
    try {
      _veiculoViewModel.loadVeiculos(AuthViewModel.userid ?? '');
      final veiculos = await _veiculoViewModel.veiculosStream!.first;
      setState(() {
        _veiculos = veiculos;
        if (_veiculos.isNotEmpty) {
          _veiculoSelecionadoId = _veiculos.first.id;
          _carregarAbastecimentos();
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _carregarAbastecimentos() async {
    if (_veiculoSelecionadoId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      _abastecimentoViewModel.loadAbastecimentosByVeiculo(_veiculoSelecionadoId!);
      final abastecimentos = await _abastecimentoViewModel.abastecimentosStream!.first;
      
      abastecimentos.sort((a, b) => a.data.compareTo(b.data));
      
      setState(() {
        _abastecimentos = abastecimentos;
        _isLoading = false;
      });
      
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos de Consumo'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _veiculos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum veículo cadastrado',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cadastre veículos para visualizar os gráficos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seletor de Veículo
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selecione o Veículo',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _veiculoSelecionadoId,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.directions_car),
                                  ),
                                  items: _veiculos.map((veiculo) {
                                    return DropdownMenuItem<String>(
                                      value: veiculo.id,
                                      child: Text('${veiculo.marca} ${veiculo.modelo} - ${veiculo.placa}'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _veiculoSelecionadoId = value;
                                      _carregarAbastecimentos();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (_abastecimentos.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.bar_chart_outlined,
                                      size: 60,
                                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum abastecimento registrado',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else ...[
                          // Estatísticas
                          _buildEststatisticasCard(theme),
                          const SizedBox(height: 16),
                          
                          // Gráfico de Consumo
                          _buildGraficoConsumo(theme),
                          const SizedBox(height: 16),
                          
                          // Gráfico de Custos
                          _buildGraficoCustos(theme),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEststatisticasCard(ThemeData theme) {
    final consumoMedio = _calcularConsumoMedio();
    final custoMedio = _calcularCustoMedio();
    final totalGasto = _calcularTotalGasto();
    final totalLitros = _calcularTotalLitros();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    icon: Icons.speed,
                    label: 'Consumo Médio',
                    value: '${consumoMedio.toStringAsFixed(2)} km/l',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    icon: Icons.attach_money,
                    label: 'Custo Médio',
                    value: 'R\$ ${custoMedio.toStringAsFixed(2)}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    icon: Icons.local_gas_station,
                    label: 'Total de Litros',
                    value: '${totalLitros.toStringAsFixed(2)} L',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    icon: Icons.payments,
                    label: 'Total Gasto',
                    value: 'R\$ ${totalGasto.toStringAsFixed(2)}',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoConsumo(ThemeData theme) {
    final abastecimentosComConsumo = _abastecimentos.where((a) => (a.consumo ?? 0) > 0).toList();
    
    if (abastecimentosComConsumo.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Dados insuficientes para gerar o gráfico de consumo',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Evolução do Consumo (km/l)',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < abastecimentosComConsumo.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (abastecimentosComConsumo.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxConsumo() * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: abastecimentosComConsumo.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.consumo ?? 0);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoCustos(ThemeData theme) {
    if (_abastecimentos.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Custos por Abastecimento (R\$)',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxCusto() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'R\$ ${rod.toY.toStringAsFixed(2)}',
                          TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _abastecimentos.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  barGroups: _abastecimentos.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.valorPago,
                          color: Colors.orange,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcularConsumoMedio() {
    final consumos = _abastecimentos.where((a) => (a.consumo ?? 0) > 0).map((a) => a.consumo ?? 0);
    if (consumos.isEmpty) return 0;
    return consumos.reduce((a, b) => a + b) / consumos.length;
  }

  double _calcularCustoMedio() {
    if (_abastecimentos.isEmpty) return 0;
    return _abastecimentos.map((a) => a.valorPago).reduce((a, b) => a + b) / _abastecimentos.length;
  }

  double _calcularTotalGasto() {
    if (_abastecimentos.isEmpty) return 0;
    return _abastecimentos.map((a) => a.valorPago).reduce((a, b) => a + b);
  }

  double _calcularTotalLitros() {
    if (_abastecimentos.isEmpty) return 0;
    return _abastecimentos.map((a) => a.quantidadeLitros).reduce((a, b) => a + b);
  }

  double _getMaxConsumo() {
    final consumos = _abastecimentos.where((a) => (a.consumo ?? 0) > 0).map((a) => a.consumo ?? 0);
    if (consumos.isEmpty) return 10;
    return consumos.reduce((a, b) => a > b ? a : b);
  }

  double _getMaxCusto() {
    if (_abastecimentos.isEmpty) return 100;
    return _abastecimentos.map((a) => a.valorPago).reduce((a, b) => a > b ? a : b);
  }
}
