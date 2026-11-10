import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogHamaPage extends StatefulWidget {
  const LogHamaPage({super.key});

  @override
  State<LogHamaPage> createState() => _LogHamaPageState();
}

class _LogHamaPageState extends State<LogHamaPage> {
  // GANTI IP INI DENGAN IP LAPTOP ANDA (DARI CMD -> ipconfig)
  final String serverIp = "10.111.11.120:5000";
  late final String apiUrl = "http://$serverIp/api/user/logs";

  bool isLoading = true;
  int totalHama3Hari = 0;
  String statusLahan = "Memuat...";
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // Fungsi pintar untuk memperbaiki URL gambar agar valid diakses HP
  String _fixImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return "";
    
    // Jika path lokal disk (mengandung backslash atau C:/)
    if (rawUrl.contains('\\') || rawUrl.contains('C:/') || rawUrl.contains('C:\\')) {
      // Ambil nama file terakhir saja (misal: "hama_123.jpg")
      String fileName = rawUrl.split(RegExp(r'[/\\]')).last;
      return "http://$serverIp/uploads/$fileName";
    }

    if (rawUrl.startsWith('http://localhost') || rawUrl.startsWith('http://127.0.0.1')) {
      return rawUrl.replaceAll(RegExp(r'localhost|127\.0\.0\.1:5000'), serverIp);
    } else if (rawUrl.startsWith('/')) {
      return 'http://$serverIp$rawUrl';
    } else if (!rawUrl.startsWith('http')) {
      return 'http://$serverIp/$rawUrl';
    }
    return rawUrl;
  }

  Future<void> _fetchLogs() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> rawLogs = data['logs'] ?? [];

        // Filter data hanya untuk 3 hari terbaru berdasarkan tanggal timestamp
        List<dynamic> filteredLogs = [];
        if (rawLogs.isNotEmpty) {
          // Cari tanggal paling baru dari database
          List<DateTime> parsedDates = rawLogs.map((l) {
            try {
              return DateTime.parse(l['timestamp']);
            } catch (e) {
              return DateTime.now();
            }
          }).toList();

          parsedDates.sort((a, b) => b.compareTo(a));
          DateTime latestDate = parsedDates.first;
          DateTime cutoffDate = latestDate.subtract(const Duration(days: 3));

          filteredLogs = rawLogs.where((l) {
            try {
              DateTime d = DateTime.parse(l['timestamp']);
              // Masukkan jika selisih waktunya dalam rentang 3 hari terakhir dari data paling atas
              return d.isAfter(cutoffDate) || d.isAtSameMomentAs(cutoffDate);
            } catch (e) {
              return true;
            }
          }).toList();
        }

        setState(() {
          logs = filteredLogs.isNotEmpty ? filteredLogs : rawLogs;
          totalHama3Hari = data['total_hama_3_hari'] ?? 0;
          statusLahan = data['status'] ?? "Aman";
          isLoading = false;
        });
      } else {
        print("Gagal mengambil data log. Status Code: ${response.statusCode}");
        setState(() {
          isLoading = false;
          statusLahan = "Error Server";
        });
      }
    } catch (e) {
      print("Error koneksi: $e");
      setState(() {
        isLoading = false;
        statusLahan = "Error Koneksi";
      });
    }
  }

  // Fungsi konversi waktu ISO dari database ke format Bahasa Indonesia
  String _formatWaktu(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      String hari = days[date.weekday - 1];
      String tanggal = '${date.day} ${months[date.month - 1]} ${date.year}';
      String jam = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$hari, $tanggal - $jam WIB';
    } catch (e) {
      return isoString;
    }
  }

  void _showImageModal(BuildContext context, String imageUrl) {
    final fixedUrl = _fixImageUrl(imageUrl);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fixedUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[800],
                            child: const Center(child: Text('Gagal memuat gambar dari server', style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: const Center(
                    child: Text('Bukti visual tangkapan kamera AI', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF148348)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Log Hama', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    const Text('Riwayat hasil deteksi hama dari perangkat ESP32-CAM di lahan Anda (3 Hari Terakhir).', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total (3 Hari)', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(totalHama3Hari.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF148348))),
                                    const SizedBox(width: 4),
                                    const Text('ekor', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(statusLahan, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF148348))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: 'Total Log: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    children: [
                                      TextSpan(text: '${logs.length} data', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.filter_list, color: Colors.grey),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          
                          logs.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Center(child: Text('Belum ada data riwayat deteksi.', style: TextStyle(color: Colors.grey))),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: logs.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    final imageUrl = _fixImageUrl(log['image_url'].toString());

                                    return InkWell(
                                      onTap: () {
                                        _showImageModal(context, log['image_url'].toString());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Deteksi Hama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.memory, size: 14, color: Colors.grey),
                                                      const SizedBox(width: 4),
                                                      Text(log['node_id'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(_formatWaktu(log['timestamp'].toString()), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                border: Border.all(color: Colors.green[100]!),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text('${log['pest_count']} ekor', style: const TextStyle(color: Color(0xFF148348), fontWeight: FontWeight.w900, fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}