import 'package:flutter/material.dart';
import 'package:abast_veiculo/pages/registerpage.dart';
import 'package:abast_veiculo/pages/loginpage.dart';
import 'package:abast_veiculo/pages/homepage.dart';
import 'package:abast_veiculo/pages/listaveiculospage.dart';
import 'package:abast_veiculo/pages/formabastecimentopage.dart';
import 'package:abast_veiculo/pages/historicoabastecimentopage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        'registrousuario': (context) => RegisterPage(),
        'home': (context) => HomePage(),
        'listaveiculos': (context) => ListaVeiculosPage(),
        'registrarabastecimento': (context) => RegistrarAbastecimentoPage(),
        'historicoabastecimento': (context) => HistoricoAbastecimentoPage(),
      },
    );
  }
}
