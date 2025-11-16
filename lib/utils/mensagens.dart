import 'package:flutter/material.dart';

/// Tipos de mensagem disponíveis
enum TipoMensagem {
  informacao,
  sucesso,
  aviso,
  erro,
}

/// Mostra uma mensagem SnackBar na tela
void mostrarMensagem(
  BuildContext context,
  String mensagem, {
  TipoMensagem tipo = TipoMensagem.informacao,
  Duration duracao = const Duration(seconds: 3),
}) {
  Color backgroundColor;
  IconData icon;

  switch (tipo) {
    case TipoMensagem.sucesso:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case TipoMensagem.erro:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case TipoMensagem.aviso:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case TipoMensagem.informacao:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(mensagem)),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duracao,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
