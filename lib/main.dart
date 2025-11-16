import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abast_veiculo/pages/registerpage.dart';
import 'package:abast_veiculo/pages/loginpage.dart';
import 'package:abast_veiculo/pages/homepage.dart';
import 'package:abast_veiculo/pages/listaveiculospage.dart';
import 'package:abast_veiculo/pages/formabastecimentopage.dart';
import 'package:abast_veiculo/pages/historicoabastecimentopage.dart';
import 'package:abast_veiculo/pages/graficosconsumopag.dart';
import 'package:abast_veiculo/theme/app_theme.dart';
import 'package:abast_veiculo/theme/theme_provider.dart';
import 'package:abast_veiculo/utils/page_transitions.dart';
import 'package:abast_veiculo/viewmodel/authviewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Controle de Abastecimento',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            // Verificar autenticação para rotas protegidas
            final rotasPublicas = ['/', 'registrousuario'];
            final rotaAtual = settings.name ?? '/';
            
            // Se não está logado e tenta acessar rota protegida, redireciona para login
            if (!rotasPublicas.contains(rotaAtual) && 
                (AuthViewModel.userid == null || AuthViewModel.userid!.isEmpty)) {
              return PageTransitions.fadeScaleTransition(LoginPage());
            }
            
            // Mapeamento de rotas com transições animadas
            switch (settings.name) {
              case '/':
                return PageTransitions.fadeScaleTransition(LoginPage());
              case 'registrousuario':
                return PageTransitions.slideUpTransition(RegisterPage());
              case 'home':
                return PageTransitions.fadeScaleTransition(HomePage());
              case 'listaveiculos':
                return PageTransitions.slideTransition(ListaVeiculosPage());
              case 'registrarabastecimento':
                return PageTransitions.slideTransition(RegistrarAbastecimentoPage());
              case 'historicoabastecimento':
                return PageTransitions.slideTransition(HistoricoAbastecimentoPage());
              case 'graficos':
                return PageTransitions.slideTransition(GraficosConsumoPage());
              default:
                return PageTransitions.fadeScaleTransition(LoginPage());
            }
          },
        );
      },
    );
  }
}

