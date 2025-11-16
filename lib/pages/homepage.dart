import 'package:abast_veiculo/services/authservice.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () {Navigator.pushReplacementNamed(context, 'listaveiculos');}, child: Text("Seus Veiculos")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {Navigator.pushReplacementNamed(context, 'historicoabastecimento');}, child: Text("Histórico Abastecimentos")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {Navigator.pushReplacementNamed(context, 'registrarabastecimento');}, child: Text("Abastecer Veículo")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}