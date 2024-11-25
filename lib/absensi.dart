import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsensiPage extends StatefulWidget {
  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  DateTime? _selectedDate;
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Tanggal',
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Pegawai', '110 Orang', Icons.person),
                  _buildSummaryCard('Cuti', '2 Orang', Icons.luggage),
                  _buildSummaryCard('Sakit', '2 Orang', Icons.sick),
                  _buildSummaryCard('Izin', '2 Orang', Icons.book),
                ],
              ),
              const SizedBox(height: 20),

              // Line Chart Section
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: AttendanceLineChart(
                        tepatWaktuSpots: const [
                          FlSpot(0, 60),
                          FlSpot(1, 58),
                          FlSpot(2, 60),
                          FlSpot(3, 56),
                          FlSpot(4, 65),
                        ],
                        terlambatSpots: const [
                          FlSpot(0, 1),
                          FlSpot(1, 0),
                          FlSpot(2, 1),
                          FlSpot(3, 1),
                          FlSpot(4, 1),
                        ],
                        tidakPresensiSpots: const [
                          FlSpot(0, 2),
                          FlSpot(1, 2),
                          FlSpot(2, 2),
                          FlSpot(3, 2),
                          FlSpot(4, 2),
                        ],
                        bottomTitles: const ['22', '23', '24', '25', '26'],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LegendItem(color: Colors.blue, text: "Tepat Waktu"),
                        SizedBox(width: 10),
                        LegendItem(color: Colors.red, text: "Tidak Presensi"),
                        SizedBox(width: 10),
                        LegendItem(color: Colors.yellow, text: "Terlambat"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pie Chart Section
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: SizedBox(
                  height: 250,
                  child: PieChartWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 16),
              Icon(icon, size: 20, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(value,
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
            ],
          ),
        ),
      ),
    );
  }
}


class AttendanceLineChart extends StatelessWidget {
  final List<FlSpot> tepatWaktuSpots;
  final List<FlSpot> terlambatSpots;
  final List<FlSpot> tidakPresensiSpots;
  final List<String> bottomTitles;

  // Constructor untuk menerima data dari luar
  const AttendanceLineChart({
    required this.tepatWaktuSpots,
    required this.terlambatSpots,
    required this.tidakPresensiSpots,
    required this.bottomTitles,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: tepatWaktuSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: terlambatSpots,
            isCurved: true,
            color: Colors.yellow,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: tidakPresensiSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < bottomTitles.length) {
                  return Text(bottomTitles[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        minX: 0,
        maxX: bottomTitles.length.toDouble() - 1,
        minY: 0,
        maxY: 80, // Disesuaikan dengan skala data
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: showingSections(),
          centerSpaceRadius: 50,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

 List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 18,
        title: 'Michael Muda\n14.6%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 14,
        title: 'Isiah Hanna\n11.4%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 14,
        title: 'Keith Bullock\n11.4%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 14,
        title: 'Carlo Zamora\n11.4%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.cyan,
        value: 11,
        title: 'Johnson Mercer\n8.9%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: 10,
        title: 'Guy Villegas\n8.1%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 6,
        title: 'Bryon Osborn\n4.9%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.pink,
        value: 6,
        title: 'Erwin Musim\n4.9%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.brown,
        value: 4,
        title: 'Ahmad Baxter\n3.3%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: 14,
        title: 'Bryan Jalur\n11.4%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
    ];
  }
}