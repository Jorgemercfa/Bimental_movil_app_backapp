import 'package:flutter/material.dart';
import 'AnswersUser.dart';
import 'UserRepository.dart';
import 'User.dart';
import 'AnswersRepository.dart';

class UserResultsPage extends StatefulWidget {
  @override
  _UserResultsPageState createState() => _UserResultsPageState();
}

class _UserResultsPageState extends State<UserResultsPage> {
  List<Map<String, String>> allData = [];
  List<Map<String, String>> filteredData = [];
  List<User> users = [];
  String selectedCriterion = 'Depresión';
  String selectedValue = 'Extremadamente severa';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    users = await UserRepository.instance.getUsers();
    List<AnswersUser> respuestasGuardadas =
        await AnswersRepository.getAllAnswersFromFirestore();

    List<Map<String, String>> tempData = respuestasGuardadas.map((entry) {
      User user = users.firstWhere(
        (u) => u.id == entry.userId,
        orElse: () => User('', 'Desconocido', 'N/A', '', '', 'N/A'),
      );

      String clasificacionDepresion = _clasificarDepresion(entry.p_depresion);
      String clasificacionAnsiedad = _clasificarAnsiedad(entry.p_ansiedad);
      String clasificacionEstres = _clasificarEstres(entry.p_estres);

      return {
        'Nombre': user.name,
        'Apellido': user.lastName,
        'Correo': user.email,
        'Teléfono': user.phone,
        'Fecha': entry.timestamp.split(' ')[0],
        'Depresión': clasificacionDepresion,
        'Ansiedad': clasificacionAnsiedad,
        'Estrés': clasificacionEstres,
        'UserId': user.id,
        'Timestamp': entry.timestamp,
      };
    }).toList();

    setState(() {
      allData = tempData;
      filteredData = List<Map<String, String>>.from(allData);
      isLoading = false;
    });
  }

  String _clasificarDepresion(int score) {
    if (score >= 14) return 'Extremadamente severa';
    if (score >= 11) return 'Severa';
    if (score >= 7) return 'Moderada';
    if (score >= 5) return 'Leve';
    return 'Sin depresión';
  }

  String _clasificarAnsiedad(int score) {
    if (score >= 10) return 'Extremadamente severa';
    if (score >= 8) return 'Severa';
    if (score >= 5) return 'Moderada';
    if (score >= 4) return 'Leve';
    return 'Sin ansiedad';
  }

  String _clasificarEstres(int score) {
    if (score >= 17) return 'Extremadamente severo';
    if (score >= 13) return 'Severo';
    if (score >= 10) return 'Moderado';
    if (score >= 8) return 'Leve';
    return 'Sin estrés';
  }

  void _showFilterDialog() {
    final Map<String, List<String>> options = {
      'Depresión': [
        'Extremadamente severa',
        'Severa',
        'Moderada',
        'Leve',
        'Sin depresión'
      ],
      'Ansiedad': [
        'Extremadamente severa',
        'Severa',
        'Moderada',
        'Leve',
        'Sin ansiedad'
      ],
      'Estrés': [
        'Extremadamente severo',
        'Severo',
        'Moderado',
        'Leve',
        'Sin estrés'
      ],
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccionar filtro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCriterion,
                items: ['Depresión', 'Ansiedad', 'Estrés']
                    .map((criterion) => DropdownMenuItem(
                          value: criterion,
                          child: Text(criterion),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCriterion = value ?? 'Depresión';
                    selectedValue = options[selectedCriterion]!.first;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedValue,
                items: options[selectedCriterion]!
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value ?? options[selectedCriterion]!.first;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filteredData = allData
                      .where((user) => user[selectedCriterion] == selectedValue)
                      .toList();
                });
                Navigator.of(context).pop();
              },
              child: Text('Aplicar'),
            ),
            TextButton(
              onPressed: () {
                setState(() =>
                    filteredData = List<Map<String, String>>.from(allData));
                Navigator.of(context).pop();
              },
              child: Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Resultados Usuarios', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A119B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF1A119B),
                    ),
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(Color(0xFF4CAF50)),
                      dataRowColor:
                          MaterialStateProperty.all(Color(0xFF1A119B)),
                      columns: [
                        DataColumn(
                          label: Text('Nombre',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Apellido',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Correo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Teléfono',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Fecha',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Depresión',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Ansiedad',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Estrés',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredData.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user['Nombre']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Apellido']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Correo']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Teléfono']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Fecha']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Depresión']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Ansiedad']!,
                                style: TextStyle(color: Colors.white))),
                            DataCell(Text(user['Estrés']!,
                                style: TextStyle(color: Colors.white))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
