import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // GANTI IP INI DENGAN IP LAPTOP ANDA (DARI CMD -> ipconfig)
  final String apiUrl = "http://10.111.11.120:5000/api/user/dashboard";

  final String userName = "Satrio Dwi Setiawan";
  bool isLoading = true;
  
  // Data dari Database
  int totalHamaHariIni = 0;
  String statusLahan = "Memuat..."; 
  int perangkatOnline = 0;
  int totalPerangkat = 0;
  List<dynamic> grafikData = []; 

  // Data AI Forecasting dari Database
  Map<String, dynamic> aiForecastData = {
    "latestPrediction": 24,
    "predictionDate": "10 Nov 2026",
    "calculationTime": "2026-11-09 09:16:47",
    "logs": [
      {"tanggal_prediksi": "04 Nov 2026", "jumlah_prediksi": 24.081, "waktu_kalkulasi": "2026-11-03 10:57:55"},
      {"tanggal_prediksi": "07 Nov 2026", "jumlah_prediksi": 24.351, "waktu_kalkulasi": "2026-11-06 11:11:22"},
      {"tanggal_prediksi": "10 Nov 2026", "jumlah_prediksi": 24.136, "waktu_kalkulasi": "2026-11-09 09:16:47"},
    ]
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  String _getIndonesianDay(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _getIndonesianMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> rawChartData = data['grafik'] ?? [];

        // Jika data dari backend kurang dari 7, kita buat rolling 7 hari terakhir berdasarkan tanggal terbaru
        Map<String, int> grouped = {};
        for (var item in rawChartData) {
          String dateStr = item['tanggal'] ?? '';
          DateTime dateObj = DateTime.now();
          try {
            if (dateStr.contains('-') && dateStr.length >= 10) {
              var parts = dateStr.split(' ')[0].split('-');
              dateObj = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else if (dateStr.contains('/')) {
              var parts = dateStr.split('/');
              if (parts.length == 3) {
                dateObj = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
              }
            }
          } catch (e) {
            dateObj = DateTime.now();
          }

          String key = "${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}";
          int total = item['total'] ?? 0;
          grouped[key] = (grouped[key] ?? 0) + total;
        }

        // Tentukan tanggal paling akhir sebagai titik jangkar 7 hari ke belakang
        DateTime latestDate = DateTime.now();
        if (grouped.isNotEmpty) {
          List<String> keys = grouped.keys.toList()..sort();
          var parts = keys.last.split('-');
          latestDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }

        // Generate tepat 7 hari ke belakang agar grafik selalu menampilkan 7 kolom konsisten
        List<dynamic> processedGrafik = [];
        for (int i = 6; i >= 0; i--) {
          DateTime targetDate = latestDate.subtract(Duration(days: i));
          String key = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
          
          int total = grouped[key] ?? 0;
          String hari = _getIndonesianDay(targetDate.weekday);
          String tanggal = "${targetDate.day.toString().padLeft(2, '0')} ${_getIndonesianMonth(targetDate.month)}";

          processedGrafik.add({
            'hari': hari,
            'tanggal': tanggal,
            'total': total,
          });
        }
        
        setState(() {
          totalHamaHariIni = data['summary']['total_hama_hari_ini'] ?? 0;
          statusLahan = data['summary']['status_lahan'] ?? "Aman";
          perangkatOnline = data['summary']['perangkat_online'] ?? 0;
          totalPerangkat = data['summary']['total_perangkat'] ?? 0;
          grafikData = processedGrafik;
          
          isLoading = false;
        });
      } else {
        print("Gagal mengambil data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error koneksi: $e");
      setState(() {
        isLoading = false;
        statusLahan = "Error Koneksi";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = "${DateTime.now().day} ${_getIndonesianMonth(DateTime.now().month)} ${DateTime.now().year}";

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF148348)))
          : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= 1. HEADER & GREETINGS =================
              const Text('Selamat datang,', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(userName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))), 
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Pantau kondisi lahan dan populasi hama Anda hari ini.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              
              const SizedBox(height: 16),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPill(Icons.calendar_today_outlined, formattedDate),
                    const SizedBox(width: 12),
                    _buildPill(Icons.location_on, 'Lahan Sawah - Semua Sektor', iconColor: const Color(0xFF148348)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= 2. KARTU STATISTIK =================
              _buildStatCard(
                title: 'Total Hama Hari Ini',
                value: totalHamaHariIni.toString(),
                unit: 'ekor',
                subtitle: 'Berdasarkan log deteksi sistem',
                icon: Icons.bug_report,
                iconColor: Colors.green[600]!,
                iconBgColor: Colors.green[100]!,
              ),
              
              const SizedBox(height: 16),
              _buildStatusCard(statusLahan),
              const SizedBox(height: 16),

              _buildStatCard(
                title: 'Perangkat Aktif',
                value: perangkatOnline.toString(),
                unit: 'dari $totalPerangkat Node',
                subtitle: 'Terhubung ke server',
                icon: Icons.router,
                iconColor: Colors.blue[500]!,
                iconBgColor: Colors.blue[50]!,
              ),

              const SizedBox(height: 24),

              // ================= 3. GRAFIK TREN POPULASI HAMA (FIXED OVERFLOW & 7 HARI) =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: Color(0xFF148348), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tren Populasi Hama (7 Hari Terakhir)', 
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      height: 220,
                      child: grafikData.isEmpty 
                        ? const Center(child: Text('Belum ada data riwayat deteksi untuk grafik.', style: TextStyle(color: Colors.grey, fontSize: 13)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: grafikData.map((item) {
                              int total = item['total'] ?? 0;
                              String hari = item['hari'] ?? '';
                              String tanggal = item['tanggal'] ?? '';
                              
                              num maxVal = 10;
                              for (var g in grafikData) {
                                if ((g['total'] ?? 0) > maxVal) maxVal = g['total'];
                              }
                              
                              double barHeight = (total / maxVal) * 120;
                              if (barHeight < 10) barHeight = 10;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('$total', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF148348))),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: barHeight,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(hari, style: const TextStyle(fontSize: 9.5, color: Color(0xFF0F172A), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(tanggal, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500), maxLines: 1),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= 4. PANEL AI FORECASTING (RAMALAN LONJAKAN HAMA) =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ramalan Lonjakan Hama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                Text('BERDASARKAN LOG PREDIKSI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), letterSpacing: 0.5)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Sistem Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Target Tanggal Prediksi:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(aiForecastData['predictionDate'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E7FF)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hasil Kalkulasi Terbaru', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('24', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF4338CA))),
                                  SizedBox(width: 4),
                                  Text('ekor (estimasi)', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('09:16 WIB', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RIWAYAT KALKULASI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                        Text('3 Data', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(aiForecastData['logs'] as List).map((log) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tgl Prediksi: ${log['tanggal_prediksi']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                const SizedBox(height: 2),
                                Text('Kalkulasi: ${log['waktu_kalkulasi']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              ],
                            ),
                            Text(log['jumlah_prediksi'].toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30), 
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchDashboardData();
        },
        backgroundColor: const Color(0xFF148348),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text, {Color iconColor = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title, required String value, required String unit, required String subtitle,
    required IconData icon, required Color iconColor, required Color iconBgColor
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    bool isWaspada = status == 'Waspada' || status == 'Bahaya';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWaspada ? const Color(0xFFFFFDF0) : const Color(0xFFF0FDF4),
        border: Border.all(color: isWaspada ? Colors.yellow[200]! : Colors.green[200]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWaspada ? Colors.yellow[100] : Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(isWaspada ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: isWaspada ? Colors.orange : Colors.green, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('Status Lahan', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(
                  isWaspada ? 'Populasi hama melebihi ambang batas aman.' : 'Kondisi lahan terpantau aman.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}