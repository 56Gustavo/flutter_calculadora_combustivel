import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Importando o Syncfusion Charts

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
  List<ChartData> _chartData = []; // Lista para armazenar os dados do gráfico

  // Função para calcular a relação entre álcool e gasolina
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
      _chartData = _generateChartData(alcool, gasolina); // Atualiza os dados do gráfico
    });
  }

  // Função para limpar os campos de entrada e a mensagem de resultado
  void _clearFields() {
    setState(() {
      _alcoolController.clear();
      _gasolinaController.clear();
      _resultMessage = '';
      _chartData = []; // Limpa os dados do gráfico
    });
  }

  // Função para abrir a URL do Google Maps
  Future<void> _openUrl() async {
    final url = 'https://precos.petrobras.com.br/sele%C3%A7%C3%A3o-de-estados-gasolina';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

  // Função para gerar os dados do gráfico baseado no preço do álcool e gasolina
  List<ChartData> _generateChartData(double alcool, double gasolina) {
    List<ChartData> data = [];
    for (int i = 1; i <= 100; i += 5) {
      // Calculando o valor a ser pago por litro de combustível
      double gasolinaValue = gasolina * i; // Total a ser pago por gasolina (preço * quantidade de litros)
      double alcoolValue = alcool * i; // Total a ser pago por álcool (preço * quantidade de litros)
      data.add(ChartData('Litros ${i}', gasolinaValue, alcoolValue)); // Adicionando ao gráfico
    }
    return data;
  }

  // Função para navegar para a tela do gráfico
  void _openChartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartScreen(chartData: _chartData), // Passando os dados para a nova tela
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Combustível'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                ElevatedButton(
                  onPressed: _openChartScreen, // Botão para abrir a tela do gráfico
                  child: Text('Abrir Gráfico'),
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

// Classe que define os dados para o gráfico
class ChartData {
  final String x;
  final double y; // Valor a ser pago com gasolina
  final double y2; // Valor a ser pago com álcool

  ChartData(this.x, this.y, this.y2);
}

// Tela separada para exibir o gráfico
class ChartScreen extends StatelessWidget {
  final List<ChartData> chartData;

  ChartScreen({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Combustíveis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 400, // Definindo um tamanho maior para o gráfico
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  // Configurando o eixo X com intervalos de 5 litros entre 1 e 100
                  title: AxisTitle(text: 'Litros'),
                  interval: 5,
                ),
                primaryYAxis: NumericAxis(
                  // Configurando o eixo Y com prefixo "R$"
                  labelFormat: 'R\$ {value}',
                ),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y, // Total a ser pago com gasolina
                    name: 'Gasolina',
                    color: Colors.red,
                    markerSettings: MarkerSettings(isVisible: true), // Adicionando marcadores
                  ),
                  LineSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y2, // Total a ser pago com álcool
                    name: 'Álcool',
                    color: Colors.green,
                    markerSettings: MarkerSettings(isVisible: true), // Adicionando marcadores
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

