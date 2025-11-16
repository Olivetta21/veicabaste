import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authservice.dart';
import '../theme/theme_provider.dart';
import '../utils/mensagens.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          // Cabeçalho do Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: 64,
                  color: theme.colorScheme.onPrimary,
                ),
                SizedBox(height: 12),
                Text(
                  'Controle de Abastecimento',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Itens do Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Início',
                  subtitle: 'Voltar para home',
                  onTap: () {
                    Navigator.pop(context); // Fecha o drawer
                    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                  },
                ),
                Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.directions_car,
                  title: 'Meus Veículos',
                  subtitle: 'Gerenciar veículos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'listaveiculos');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.add_circle,
                  title: 'Registrar Abastecimento',
                  subtitle: 'Adicionar novo',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'registrarabastecimento');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'Histórico de Abastecimentos',
                  subtitle: 'Ver registros',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'historicoabastecimento');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Gráficos de Consumo',
                  subtitle: 'Análise e estatísticas',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'graficos');
                  },
                ),
                Divider(),
                _buildThemeToggle(context),
                Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sair',
                  subtitle: 'Fazer logout',
                  iconColor: theme.colorScheme.error,
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().signOut();
                    if (context.mounted) {
                      mostrarMensagem(context, 'Você saiu da conta', tipo: TipoMensagem.informacao);
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Rodapé
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Versão 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SwitchListTile(
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'Tema Escuro',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        themeProvider.isDarkMode ? 'Ativado' : 'Desativado',
        style: theme.textTheme.bodySmall,
      ),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme();
        mostrarMensagem(
          context, 
          'Tema ${value ? "escuro" : "claro"} ativado',
          tipo: TipoMensagem.informacao,
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
