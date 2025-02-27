import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Combustível',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FuelCalculator(),
    );
  }
}

class FuelCalculator extends StatefulWidget {
  @override
  _FuelCalculatorState createState() => _FuelCalculatorState();
}

class _FuelCalculatorState extends State<FuelCalculator> {
  final TextEditingController _alcoolController = TextEditingController();
  final TextEditingController _gasolinaController = TextEditingController();
  String _resultMessage = '';

  void _calculateFuel() {
    final alcool = double.tryParse(_alcoolController.text);
    final gasolina = double.tryParse(_gasolinaController.text);

    if (alcool == null || gasolina == null || alcool <= 0 || gasolina <= 0) {
      setState(() {
        _resultMessage = 'Por favor, insira preços válidos para ambos os combustíveis.';
      });
      return;
    }

    double ratio = alcool / gasolina;
    setState(() {
      _resultMessage = ratio < 0.7 ? 'Abasteça com Álcool' : 'Abasteça com Gasolina';
    });
  }

  void _clearFields() {
    setState(() {
      _alcoolController.clear();
      _gasolinaController.clear();
      _resultMessage = '';
    });
  }

  Future<void> _openUrl() async {
    final url = 'https://www.google.com.br/maps/preview';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar  : AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            GestureDetector(
              onTap: _openUrl,
              child: Image.asset(
                'assets/icone_posto.png',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 8),

            TextField(
              controller: _alcoolController,
              decoration: InputDecoration(
                labelText: 'Preço do Álcool (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _gasolinaController,
              decoration: InputDecoration(
                labelText: 'Preço da Gasolina (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _calculateFuel,
                  child: Text('Calcular'),
                ),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: Text('Limpar'),
                ),
              ],
            ),
            SizedBox(height: 20),

            Text(
              _resultMessage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _resultMessage == 'Abasteça com Álcool' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
