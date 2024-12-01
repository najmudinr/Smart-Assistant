import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartassistant/asktoexpert.dart';
import 'package:smartassistant/dashboardmemo.dart';
import 'package:smartassistant/editchart.dart';
import 'package:smartassistant/konsultasi.dart';
import 'package:smartassistant/models/agenda.dart';
import 'package:smartassistant/pengajuan.dart';
import 'package:smartassistant/diskusirapat.dart';
import 'package:smartassistant/penugasan.dart';
import 'package:smartassistant/projectmanagement.dart';
import 'package:smartassistant/iqc.dart';
import 'package:smartassistant/services/agenda_notifier.dart';
import 'package:smartassistant/widgets/agenda_card.dart';

class DashboardPage extends StatefulWidget {
  final String userRole;

  const DashboardPage({required this.userRole});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userName;
  String? _userRole;
  final AgendaNotifier _agendaNotifier = AgendaNotifier();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchUserDetailsFromFirestore();
    _fetchUserNameFromFirestore();
    _loadAgendas();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedName = prefs.getString('userName');
    setState(() {
      userName = cachedName;
    });
  }

  Future<void> _fetchUserDetailsFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name']; // Ambil nama pengguna
            _userRole = userDoc['roles']; // Ambil roles dari Firestore
          });

          // Simpan nama dan roles di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userName', userName!);
          prefs.setString('userRole', _userRole!);
        }
      }
    } catch (e) {
      print("Failed to fetch user details: $e");
    }
  }

  Future<void> _fetchUserNameFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'];
          });

          // Simpan nama di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userName', userName!);
        }
      }
    } catch (e, stackTrace) {
      print("Failed to fetch user name: $e");
      print(stackTrace);
    }
  }

  void _loadAgendas() {
    FirebaseFirestore.instance
        .collection('agendas')
        .snapshots()
        .listen((snapshot) {
      final agendas = snapshot.docs.map((doc) {
        return Agenda.fromFirestore(doc);
      }).toList();
      _agendaNotifier.startMonitoring(agendas);
    });
  }

  @override
  void dispose() {
    _agendaNotifier.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // Tampilkan teks "Selamat datang, $name"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    'Selamat datang, ${userName ?? 'Pengguna'}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Widget Dashboard Ikon Navigasi
                // Widget Dashboard Ikon Navigasi tanpa Expanded
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 11.5,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildDashboardItem(context, 'Penugasan',
                          'assets/penugasan.png', PenugasanPage()),
                      _buildDashboardItem(context, 'Ask To Expert',
                          'assets/comdev.png', ComdevPage()),
                      _buildDashboardItem(context, 'Pengajuan',
                          'assets/pengajuan.png', PengajuanPage()),
                      _buildDashboardItem(context, 'Konsultasi',
                          'assets/konsultasi.png', ConsultationPage()),
                      _buildDashboardItem(context, 'Diskusi Rapat',
                          'assets/teamwork.png', DiskusiRapatPage()),
                      _buildDashboardItem(
                          context, 'IQC', 'assets/laporan.png', IQCPage()),
                      _buildDashboardItem(context, 'Project Management',
                          'assets/project.png', ProjectManagementPage()),
                      _buildDashboardItem(context, 'Rekap Memo',
                          'assets/rekapmemo.png', MemoDashboardPage()),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Widgets lainnya
                AgendaCard(
                  screenWidth: screenWidth,
                  userRole: widget.userRole,
                ),
                GudangInternalCard(screenWidth: screenWidth),
                GudangExternalCard(screenWidth: screenWidth),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          widget.userRole == 'Admin Bagian' || widget.userRole == 'Admin Seksi'
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminInputPage()),
                    );
                  },
                  tooltip: 'Input Data Gudang',
                  child: Icon(Icons.edit),
                )
              : null,
    );
  }

  // Widget untuk membangun item dashboard
  Widget _buildDashboardItem(
      BuildContext context, String title, String imagePath, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 30, width: 30),
          SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class PetugasCard extends StatelessWidget {
  final double screenWidth;

  const PetugasCard({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(screenWidth * 0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Petugas Hari Ini',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text('20 Maret 2024 (Shift 1)'),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foreman'),
                    Text('Lendy Tri',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loket'),
                    Text('Faisol Yunaedi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Checker'),
                    Text(
                      'M. Hidayat Fanani\nM. Ustanul Arifin\nDavid Ardiansyah\nSimon M. K. W',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GudangInternalCard extends StatelessWidget {
  final double screenWidth;

  const GudangInternalCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(screenWidth * 0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utilisasi Kapasitas Gudang Internal Area 3',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            SizedBox(
              height: screenWidth * 0.8,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('gudang_internal')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  final barGroups = docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value.data() as Map<String, dynamic>;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['total_capacity']?.toDouble() ?? 0,
                          color: Colors.blue,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: data['used_capacity']?.toDouble() ?? 0,
                          color: Colors.red,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: data['free_capacity']?.toDouble() ?? 0,
                          color: Colors.yellow,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList();

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 80000,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < docs.length) {
                                return Text(
                                  docs[index]['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      barGroups: barGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipMargin: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String capacityType;
                            if (rod.color == Colors.blue) {
                              capacityType = "Total Capacity";
                            } else if (rod.color == Colors.red) {
                              capacityType = "Used Capacity";
                            } else {
                              capacityType = "Free Capacity";
                            }
                            return BarTooltipItem(
                              '$capacityType\n${rod.toY.toStringAsFixed(0)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GudangExternalCard extends StatelessWidget {
  final double screenWidth;

  const GudangExternalCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(screenWidth * 0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utilisasi Kapasitas Gudang External Area 3',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            SizedBox(
              height: screenWidth * 0.8,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('gudang_external')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  final barGroups = docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value.data() as Map<String, dynamic>;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                            toY: data['total_capacity'].toDouble(),
                            width: 12,
                            color: Colors.blue),
                        BarChartRodData(
                            toY: data['used_capacity'].toDouble(),
                            width: 12,
                            color: Colors.red),
                        BarChartRodData(
                            toY: data['free_capacity'].toDouble(),
                            width: 12,
                            color: Colors.yellow),
                      ],
                    );
                  }).toList();

                  return BarChart(
                    BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 80000,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const style = TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                                return Text(docs[value.toInt()]['name'],
                                    style: style);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text('${value.toInt()}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ));
                              },
                              interval: 10000,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        barGroups: barGroups,
                        barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipMargin: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                String capacityType;
                                if (rod.color == Colors.blue) {
                                  capacityType = "Total Capacity";
                                } else if (rod.color == Colors.red) {
                                  capacityType = "Used Capacity";
                                } else {
                                  capacityType = "Free Capacity";
                                }
                                return BarTooltipItem(
                                  '$capacityType\n${rod.toY.toStringAsFixed(0)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
