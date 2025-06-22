import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'AnswersRepository.dart';
import 'ManageAnswers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalEvaluaciones = 0;
  int usuariosAltoAnsiedad = 0;
  int usuariosAltoDepresion = 0;
  int usuariosAltoEstres = 0;
  Map<String, int> estadosHistoricos = {};
  bool isLoading = true;

  final azulBimental = const Color(0xFF1A119B);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    final allUsersAnswers = await AnswersRepository.getAllAnswersFromFirestore();

    totalEvaluaciones = allUsersAnswers.length;
    usuariosAltoAnsiedad = allUsersAnswers.where((a) => a.p_ansiedad >= 8).length;
    usuariosAltoDepresion = allUsersAnswers.where((a) => a.p_depresion >= 11).length;
    usuariosAltoEstres = allUsersAnswers.where((a) => a.p_estres >= 13).length;

    Map<String, int> tempHistoricos = {};
    for (final answer in allUsersAnswers) {
      String fecha = '';
      if (answer.timestamp.contains(' ')) {
        fecha = answer.timestamp.split(' ')[0];
      } else {
        fecha = answer.timestamp;
      }
      DateTime? dt;
      try {
        dt = DateTime.parse(fecha);
      } catch (_) {
        dt = null;
      }
      if (dt != null) {
        String mes = _getShortMonth(dt.month);
        tempHistoricos[mes] = (tempHistoricos[mes] ?? 0) + 1;
      }
    }
    final mesesEnOrden = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    estadosHistoricos = {
      for (final m in mesesEnOrden)
        if (tempHistoricos.containsKey(m)) m: tempHistoricos[m]!
    };

    setState(() => isLoading = false);
  }

  String _getShortMonth(int mes) {
    switch (mes) {
      case 1:
        return 'Ene';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Abr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Ago';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dic';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulBimental,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_bimental.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Resumen de tu bienestar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: azulBimental,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // KPIs en tarjetas (2 filas de 2 KPIs cada una)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Evaluaciones',
                      value: '$totalEvaluaciones',
                      icon: Icons.assignment_turned_in,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _KpiCard(
                      label: 'Alta Ansiedad',
                      value: '$usuariosAltoAnsiedad',
                      icon: Icons.warning_amber,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Alta Depresión',
                      value: '$usuariosAltoDepresion',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _KpiCard(
                      label: 'Alto Estrés',
                      value: '$usuariosAltoEstres',
                      icon: Icons.warning,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Gráfico de evolución
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolución de evaluaciones en el tiempo',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final meses =
                                estadosHistoricos.keys.toList();
                                if (value.toInt() < 0 ||
                                    value.toInt() >= meses.length) {
                                  return const SizedBox();
                                }
                                return Text(meses[value.toInt()],
                                    style:
                                    const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: List.generate(
                            estadosHistoricos.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: estadosHistoricos.values
                                    .elementAt(i)
                                    .toDouble(),
                                color: azulBimental,
                                width: 18,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pie de página, botón de historial, etc.
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulBimental,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/historial');
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text('Ver Historial',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}