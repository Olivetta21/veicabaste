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
  bool _isLoading = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
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
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Ícone
              Icon(
                Icons.local_gas_station_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: 16),
              
              // Título
              Text(
                'Controle de Abastecimento',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Faça login para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 48),
              
              // Formulário
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    
                    // Botão Login
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text('Entrar'),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Botão Registrar
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, 'registrousuario');
                      },
                      child: Text('Não tem uma conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}