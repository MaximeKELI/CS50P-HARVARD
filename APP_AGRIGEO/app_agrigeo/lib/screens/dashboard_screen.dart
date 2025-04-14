import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DataPoint> data = [];
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final List<String> months = [
    "Jan",
    "Fév",
    "Mars",
    "Avr",
    "Mai",
    "Juin",
    "Juil",
    "Août",
    "Sept",
    "Oct",
    "Nov",
    "Déc"
  ];
  String _chartType = 'Line';
  RangeValues _rangeValues = const RangeValues(0, 11);
  Timer? _autoSaveTimer;
  bool _isLoading = false;
  double? _averageValue;
  double? _maxValue;
  double? _minValue;
  double? _predictedNextValue;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _loadData();
    _setupAutoSave();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Firebase initialization error: $e");
    }
  }

  Future<void> _setupAutoSave() async {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _saveData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await _loadFromFirebase();
      } else {
        await _loadFromLocal();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        data = [
          DataPoint("Jan", 30),
          DataPoint("Fév", 40),
          DataPoint("Mars", 60),
          DataPoint("Avr", 50),
        ];
      });
    } finally {
      _calculateStats();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('userDashboardData')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      final List<dynamic> loadedData = snapshot.data()!['data'];
      setState(() {
        data =
            loadedData.map((e) => DataPoint(e['month'], e['value'])).toList();
      });
    }
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedData = prefs.getStringList('dashboard_data');

    if (savedData != null) {
      setState(() {
        data = savedData.map((item) {
          final parts = item.split(':');
          return DataPoint(parts[0], int.parse(parts[1]));
        }).toList();
      });
    }
  }

  Future<void> _saveData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('userDashboardData')
            .doc(user.uid)
            .set({
          'data':
              data.map((e) => {'month': e.month, 'value': e.value}).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'dashboard_data',
        data.map((item) => '${item.month}:${item.value}').toList(),
      );
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  void _calculateStats() {
    if (data.isEmpty) return;

    final values = data.map((e) => e.value.toDouble()).toList();
    _averageValue = values.reduce((a, b) => a + b) / values.length;
    _maxValue = values.reduce(max);
    _minValue = values.reduce(min);

    if (values.length >= 2) {
      final last = values[values.length - 1];
      final secondLast = values[values.length - 2];
      _predictedNextValue = last + (last - secondLast);
    }
  }

  void _addDataPoint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter des données"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Mois"),
              items: months.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => _monthController.text = value!,
              validator: (value) =>
                  value == null ? 'Sélectionnez un mois' : null,
            ),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: "Valeur"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value!.isEmpty ? 'Entrez une valeur' : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_monthController.text.isNotEmpty &&
                  _valueController.text.isNotEmpty) {
                setState(() {
                  data.add(DataPoint(
                    _monthController.text,
                    int.parse(_valueController.text),
                  ));
                });
                _saveData();
                _calculateStats();
                _monthController.clear();
                _valueController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final csvData = const ListToCsvConverter().convert([
            ['Mois', 'Valeur']
          ] +
          data.map((e) => [e.month, e.value.toString()]).toList());

      final path = await FilePicker.platform.saveFile(
        fileName: 'export_agricole_${DateTime.now().toIso8601String()}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path != null) {
        await File(path).writeAsString(csvData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export CSV réussi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'export: $e')),
      );
    }
  }

  Future<void> _importFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final csvData = await file.readAsString();
        final List<List<dynamic>> rows =
            const CsvToListConverter().convert(csvData);

        setState(() {
          data = rows
              .skip(1)
              .map((row) =>
                  DataPoint(row[0].toString(), int.parse(row[1].toString())))
              .toList();
        });

        await _saveData();
        _calculateStats();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import CSV réussi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'import: $e')),
      );
    }
  }

  Widget _buildChart() {
    final filteredData = data.where((dp) {
      final index = months.indexOf(dp.month);
      return index >= _rangeValues.start && index <= _rangeValues.end;
    }).toList();

    switch (_chartType) {
      case 'Bar':
        return SfCartesianChart(
          title: ChartTitle(text: 'Données Agricoles (Barres)'),
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Valeurs'),
          ),
          series: <CartesianSeries>[
            ColumnSeries<DataPoint, String>(
              dataSource: filteredData,
              xValueMapper: (dp, _) => dp.month,
              yValueMapper: (dp, _) => dp.value,
              name: 'Valeurs',
              color: Colors.green,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      case 'Pie':
        return SfCircularChart(
          title: ChartTitle(text: 'Répartition par Mois'),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            PieSeries<DataPoint, String>(
              dataSource: filteredData,
              xValueMapper: (dp, _) => dp.month,
              yValueMapper: (dp, _) => dp.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              explode: true,
              explodeIndex: 0,
            ),
          ],
        );
      default: // Line
        return SfCartesianChart(
          title: ChartTitle(text: 'Évolution Mensuelle'),
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Valeurs'),
          ),
          series: <CartesianSeries>[
            LineSeries<DataPoint, String>(
              dataSource: filteredData,
              xValueMapper: (dp, _) => dp.month,
              yValueMapper: (dp, _) => dp.value,
              name: 'Valeurs',
              color: Colors.green,
              markerSettings: const MarkerSettings(isVisible: true),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              animationDuration: 2000,
            ),
            if (_predictedNextValue != null && filteredData.isNotEmpty)
              LineSeries<DataPoint, String>(
                dataSource: [
                  filteredData.last,
                  DataPoint(
                    months[(months.indexOf(filteredData.last.month) + 1) %
                        months.length],
                    _predictedNextValue!.round(),
                  ),
                ],
                xValueMapper: (dp, _) => dp.month,
                yValueMapper: (dp, _) => dp.value,
                name: 'Prévision',
                color: Colors.orange,
                dashArray: [5, 5],
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
          ],
        );
    }
  }

  Widget _buildKPICard(String title, dynamic value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value?.toStringAsFixed(2) ?? 'N/A',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de Bord Agricole"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter des données',
            onPressed: _addDataPoint,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Exporter en CSV',
            onPressed: _exportToCSV,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Importer depuis CSV',
            onPressed: _importFromCSV,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _chartType = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Line',
                child: Text('Graphique Linéaire'),
              ),
              const PopupMenuItem(
                value: 'Bar',
                child: Text('Graphique à Barres'),
              ),
              const PopupMenuItem(
                value: 'Pie',
                child: Text('Graphique Circulaire'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildKPICard('Moyenne', _averageValue, Colors.blue),
                      _buildKPICard('Maximum', _maxValue, Colors.green),
                      _buildKPICard('Minimum', _minValue, Colors.red),
                      if (_predictedNextValue != null)
                        _buildKPICard(
                            'Prévision', _predictedNextValue, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Type de Visualisation',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _chartType,
                            items: ['Line', 'Bar', 'Pie'].map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text({
                                  'Line': 'Linéaire',
                                  'Bar': 'Barres',
                                  'Pie': 'Circulaire',
                                }[type]!),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _chartType = value!),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtrer par Période',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: _rangeValues,
                            min: 0,
                            max: 11,
                            divisions: 11,
                            labels: RangeLabels(
                              months[_rangeValues.start.round()],
                              months[_rangeValues.end.round()],
                            ),
                            onChanged: (values) =>
                                setState(() => _rangeValues = values),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: _buildChart(),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Détails des Données',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Mois')),
                                DataColumn(label: Text('Valeur')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: data
                                  .map((item) => DataRow(
                                        cells: [
                                          DataCell(Text(item.month)),
                                          DataCell(Text(item.value.toString())),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    size: 20),
                                                onPressed: () => _editDataPoint(
                                                    data.indexOf(item)),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    size: 20,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _deleteDataPoint(
                                                        data.indexOf(item)),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDataPoint,
        tooltip: 'Ajouter des données',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editDataPoint(int index) {
    _monthController.text = data[index].month;
    _valueController.text = data[index].value.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier les données"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _monthController,
              decoration: const InputDecoration(labelText: "Mois"),
              readOnly: true,
            ),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: "Valeur"),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Entrez une valeur' : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_valueController.text.isNotEmpty) {
                setState(() {
                  data[index] = DataPoint(
                    data[index].month,
                    int.parse(_valueController.text),
                  );
                });
                _saveData();
                _calculateStats();
                _valueController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _deleteDataPoint(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Supprimer les données pour ${data[index].month}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              setState(() => data.removeAt(index));
              _saveData();
              _calculateStats();
              Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _monthController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}

class DataPoint {
  final String month;
  final int value;

  DataPoint(this.month, this.value);
}
