import 'package:abast_veiculo/viewmodel/authviewmodel.dart';
import 'package:flutter/material.dart';
import '../utils/mensagens.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthViewModel().signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, 'home');
        }
      } catch (e) {
        if (mounted) {
          String errorMessage;
          switch (e.toString()) {
            case 'user-not-found':
              errorMessage = 'Usuário não encontrado';
              break;
            case 'wrong-password':
              errorMessage = 'Senha incorreta';
              break;
            case 'invalid-email':
              errorMessage = 'Email inválido';
              break;
            case 'user-disabled':
              errorMessage = 'Usuário desabilitado';
              break;
            case 'invalid-credential':
              errorMessage = 'Credenciais inválidas';
              break;
            default:
              errorMessage = 'Erro no login: ${e.toString()}';
          }
          
          mostrarMensagem(context, errorMessage, tipo: TipoMensagem.erro);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'registrousuario');
                  },
                  child: Text('Register'),
                ),
              ],
            ),
        ),
      ),
    );
  }
}