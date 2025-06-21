import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Simulación de datos que deberías traer de tu backend o base local
final int totalEvaluaciones = 32;
final int usuariosAltoAnsiedad = 5;
final int usuariosAltoDepresion = 3;
final int usuariosAltoEstres = 4;
final Map<String, int> estadosHistoricos = {
  'Ene': 10,
  'Feb': 14,
  'Mar': 8,
  'Abr': 12,
  'May': 9,
  'Jun': 15,
};

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final azulBimental = const Color(0xFF1A119B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulBimental,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
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

          // KPIs en tarjetas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KpiCard(
                label: 'Evaluaciones',
                value: '$totalEvaluaciones',
                icon: Icons.assignment_turned_in,
                color: azulBimental,
              ),
              _KpiCard(
                label: 'Alta Ansiedad',
                value: '$usuariosAltoAnsiedad',
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
              _KpiCard(
                label: 'Alta Depresión',
                value: '$usuariosAltoDepresion',
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
              ),
              _KpiCard(
                label: 'Alto Estrés',
                value: '$usuariosAltoEstres',
                icon: Icons.warning,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Gráfico de evolución
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolución de evaluaciones en el tiempo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                final meses = estadosHistoricos.keys.toList();
                                if (value.toInt() < 0 ||
                                    value.toInt() >= meses.length)
                                  return const SizedBox();
                                return Text(meses[value.toInt()],
                                    style: const TextStyle(fontSize: 12));
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
                        barGroups: List.generate(estadosHistoricos.length, (i) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
