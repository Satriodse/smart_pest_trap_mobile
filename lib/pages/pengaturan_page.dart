import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_page.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  // GANTI IP INI DENGAN IP LAPTOP ANDA
  final String serverIp = "10.111.11.120:5000";
  
  // Karena saat ini login flutter belum memakai state management yang utuh (seperti Zustand di React),
  // kita asumsikan id_user adalah 1 untuk demo, atau bisa diganti sesuai auth Anda nantinya.
  final String userId = "1"; 
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // State Toggle Notifikasi
  bool _trapApp = true;
  bool _trapWa = true;
  bool _reportApp = true;
  bool _reportWa = true;

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 1. Fungsi Mengambil Data Profil dari Backend
  Future<void> _loadProfile() async {
    try {
      final response = await http.get(Uri.parse("http://$serverIp/api/user/profile/$userId"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == null) {
          setState(() {
            _nameController.text = data['nama_lengkap'] ?? "Satrio Dwi Setiawan";
            _phoneController.text = data['no_telepon'] ?? "081332837406";
            _emailController.text = data['email'] ?? "satrio@email.com";
          });
        }
      }
    } catch (e) {
      print("Gagal mengambil profil dari server: $e");
      // Fallback
      setState(() {
        _nameController.text = "Satrio Dwi Setiawan";
        _phoneController.text = "081332837406";
        _emailController.text = "satrio@email.com";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Fungsi Load Preferensi Notifikasi dari Penyimpanan Lokal
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trapApp = prefs.getBool('trap_app') ?? true;
      _trapWa = prefs.getBool('trap_wa') ?? true;
      _reportApp = prefs.getBool('report_app') ?? true;
      _reportWa = prefs.getBool('report_wa') ?? true;
    });
  }

  // 3. Fungsi Menyimpan Preferensi Notifikasi
  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // 4. Fungsi Simpan Profil ke Backend Flask
  void _simpanPengaturan() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.put(
        Uri.parse("http://$serverIp/api/user/profile/$userId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nama_lengkap": _nameController.text,
          "no_telepon": _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Color(0xFF148348)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui profil.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan koneksi ke server.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Fungsi Keluar / Logout
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF148348)))
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= 1. HEADER =================
              const Text('Pengaturan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              const Text('Kelola informasi akun dan preferensi notifikasi Anda.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              
              const SizedBox(height: 24),

              // ================= 2. KARTU PROFIL =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kartu Profil
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: Color(0xFF148348), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                            Text('Informasi dasar akun Anda.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 20),

                    // Form Profil
                    _buildLabel('Nama Lengkap'),
                    _buildTextField(controller: _nameController, icon: Icons.person_outline),
                    
                    _buildLabel('Nomor Handphone'),
                    _buildTextField(controller: _phoneController, icon: Icons.phone_android),
                    
                    _buildLabel('Email (Tidak dapat diubah)'),
                    _buildTextField(controller: _emailController, icon: Icons.email_outlined, enabled: false),

                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF148348),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isSaving ? null : _simpanPengaturan,
                        icon: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save_outlined, size: 20),
                        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= 3. KARTU PREFERENSI NOTIFIKASI =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kartu Preferensi
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                          child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF148348), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Preferensi Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                              Text('Atur jenis notifikasi yang ingin diterima.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 20),

                    // Toggle Preferensi (Yellow Trap)
                    const Text('Notifikasi Yellow Sticky Trap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text('Saat jumlah hama mencapai kapasitas penuh.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    
                    _buildToggleTile(
                      title: 'Dalam Aplikasi',
                      subtitle: 'Notifikasi akan muncul di aplikasi.',
                      icon: Icons.smartphone,
                      value: _trapApp,
                      onChanged: (val) {
                        setState(() => _trapApp = val);
                        _savePreference('trap_app', val);
                      },
                    ),
                    _buildToggleTile(
                      title: 'Pesan WhatsApp',
                      subtitle: 'Notifikasi akan dikirim ke WA Anda.',
                      icon: Icons.chat_outlined,
                      value: _trapWa,
                      onChanged: (val) {
                        setState(() => _trapWa = val);
                        _savePreference('trap_wa', val);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Toggle Preferensi (Laporan Harian)
                    const Text('Laporan Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text('Ringkasan deteksi hama dari seluruh perangkap.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    
                    _buildToggleTile(
                      title: 'Dalam Aplikasi',
                      subtitle: 'Laporan harian di menu dashboard.',
                      icon: Icons.smartphone,
                      value: _reportApp,
                      onChanged: (val) {
                        setState(() => _reportApp = val);
                        _savePreference('report_app', val);
                      },
                    ),
                    _buildToggleTile(
                      title: 'Pesan WhatsApp',
                      subtitle: 'Laporan dikirim otomatis ke WA.',
                      icon: Icons.chat_outlined,
                      value: _reportWa,
                      onChanged: (val) {
                        setState(() => _reportWa = val);
                        _savePreference('report_wa', val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= 4. KARTU KEAMANAN & LOGOUT =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                          child: const Icon(Icons.security, color: Color(0xFF148348), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Keamanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                            Text('Jaga keamanan akun Anda.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),

                    // Tombol Ubah Sandi (Disabled style meniru web)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                      ),
                      title: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                      subtitle: const Text('Terakhir diubah pada 16 Jun 2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ================= 5. TOMBOL KELUAR =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Munculkan dialog konfirmasi sebelum logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar dari Aplikasi?'),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun Smart Pest Trap?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Tutup dialog
                              _logout(); // Eksekusi fungsi logout
                            },
                            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar (Logout)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required IconData icon, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.black87 : Colors.grey),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF148348), width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildToggleTile({required String title, required String subtitle, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF148348),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}