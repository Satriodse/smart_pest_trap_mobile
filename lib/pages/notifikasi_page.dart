import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // GANTI IP INI DENGAN IP LAPTOP ANDA
  final String apiUrl = "http://10.111.11.120:5000/api/user/notifications";

  bool isLoading = true;
  List<dynamic> notifications = [];
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // Fungsi Fetch Notifikasi dari Flask
  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data['alerts'] ?? [];
          unreadCount = data['unread_count'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Gagal mengambil data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error koneksi: $e");
    }
  }

  // Fungsi tandai SATU notifikasi telah dibaca
  Future<void> _markAsRead(int idAlert) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_alert": idAlert}),
      );
      
      if (response.statusCode == 200) {
        // Refresh data setelah berhasil
        _fetchNotifications();
      }
    } catch (e) {
      print("Error memperbarui status baca: $e");
    }
  }

  // Fungsi tandai SEMUA notifikasi telah dibaca
  Future<void> _markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "read_all"}),
      );
      
      if (response.statusCode == 200) {
        // Refresh data setelah berhasil
        _fetchNotifications();
      }
    } catch (e) {
      print("Error menandai semua dibaca: $e");
    }
  }

  // Fungsi Format Waktu Bahasa Indonesia
  String _formatWaktu(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      String tanggal = '${date.day} ${months[date.month - 1]} ${date.year}';
      String jam = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$tanggal, $jam WIB';
    } catch (e) {
      return isoString;
    }
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
                  // ================= 1. HEADER =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notifikasi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            SizedBox(height: 8),
                            Text('Pantau semua peringatan lonjakan hama penting dari perangkat IoT.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF148348), 
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: _markAllAsRead,
                          child: const Text('Tandai Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // ================= 2. FILTER PILLS =================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF148348), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Text('Semua', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                child: Text('${notifications.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Text('Belum Dibaca', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(10)),
                                child: Text('$unreadCount', style: TextStyle(color: Colors.red[700], fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= 3. LIST NOTIFIKASI =================
                  if (notifications.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                      child: const Center(
                        child: Text('Belum ada notifikasi atau peringatan masuk. Lahan Anda aman!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final bool isUnread = notif['status_baca'] == 'unread';

                        return InkWell(
                          onTap: () {
                            if (isUnread) {
                              _markAsRead(notif['id_alert']);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isUnread ? const Color(0xFFFFFBFB) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border(
                                left: BorderSide(color: isUnread ? Colors.red : const Color(0xFF148348), width: 6),
                                top: BorderSide(color: isUnread ? Colors.red[100]! : Colors.grey[200]!),
                                right: BorderSide(color: isUnread ? Colors.red[100]! : Colors.grey[200]!),
                                bottom: BorderSide(color: isUnread ? Colors.red[100]! : Colors.grey[200]!),
                              ),
                              boxShadow: [
                                if (isUnread) BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnread ? Colors.orange[50] : Colors.green[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.warning_amber_rounded, color: isUnread ? Colors.orange : const Color(0xFF148348), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Expanded(
                                            child: Text('Peringatan Lonjakan Hama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isUnread ? Colors.red[100] : Colors.green[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isUnread ? 'Penting' : 'Dibaca',
                                              style: TextStyle(color: isUnread ? Colors.red[700] : const Color(0xFF148348), fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(notif['pesan_alert'].toString(), style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(_formatWaktu(notif['waktu_alert'].toString()), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                  const SizedBox(height: 32),
                  
                  // ================= 4. PANEL INFORMASI SISTEM =================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Sistem Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                        const SizedBox(height: 8),
                        const Text('Sistem otomatis mengirimkan peringatan harian apabila hasil deteksi kamera ESP32-CAM menemukan hama pada hari sebelumnya.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.yellow[50], border: Border.all(color: Colors.yellow[200]!), borderRadius: BorderRadius.circular(12)),
                          child: Text('Klik pada salah satu kartu notifikasi untuk mengubah statusnya menjadi "Sudah Dibaca".', style: TextStyle(color: Colors.yellow[800], fontSize: 12)),
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