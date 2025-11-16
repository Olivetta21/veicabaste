import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Início'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner/Logo com imagem ilustrativa
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_gas_station_rounded,
                    size: 100,
                    color: theme.colorScheme.onPrimary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Controle de Abastecimento',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie seus veículos e abastecimentos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Cards de acesso rápido
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acesso Rápido',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  
                  // Card Meus Veículos
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.directions_car,
                    title: 'Meus Veículos',
                    subtitle: 'Gerenciar veículos cadastrados',
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, 'listaveiculos'),
                  ),
                  SizedBox(height: 12),
                  
                  // Card Registrar Abastecimento
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.add_circle,
                    title: 'Registrar Abastecimento',
                    subtitle: 'Adicionar novo abastecimento',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, 'registrarabastecimento'),
                  ),
                  SizedBox(height: 12),
                  
                  // Card Histórico
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.history,
                    title: 'Histórico',
                    subtitle: 'Ver abastecimentos registrados',
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, 'historicoabastecimento'),
                  ),
                  SizedBox(height: 12),
                  
                  // Card Gráficos
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Gráficos',
                    subtitle: 'Análise de consumo e gastos',
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, 'graficos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}