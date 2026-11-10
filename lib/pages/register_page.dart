import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Sawah
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Sawah.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Back & Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF148348)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Image.asset('assets/LogoWeb.png', height: 32),
                      const SizedBox(width: 8),
                      Text(
                        'Smart Pest Trap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Teks Sambutan Register
                  const Text('Selamat datang', style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Buat Akun Baru\nSmart Pest Trap', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1.1, color: Colors.black87)),
                  const SizedBox(height: 16),
                  const Text('Mulai pemantauan hama lahan Anda\ndengan teknologi AIoT.', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                  
                  const SizedBox(height: 30),

                  // Kotak Form Register
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daftar Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 8),
                        const Text('Lengkapi informasi berikut untuk membuat akun.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 24),
                        
                        // Input Nama
                        _buildLabel('Nama Lengkap'),
                        _buildTextField(hint: 'Masukkan nama lengkap', icon: Icons.person_outline),
                        
                        // Input No HP
                        _buildLabel('Nomor Handphone'),
                        _buildTextField(hint: 'Contoh: 081234567890', icon: Icons.phone_android),
                        
                        // Input Email
                        _buildLabel('Email'),
                        _buildTextField(hint: 'Masukkan email Anda', icon: Icons.email_outlined),
                        
                        // Input Kata Sandi
                        _buildLabel('Kata Sandi'),
                        _buildPasswordField(
                          hint: 'Minimal 8 karakter', 
                          isObscure: _obscurePassword, 
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword)
                        ),
                        
                        // Input Konfirmasi Kata Sandi
                        _buildLabel('Konfirmasi Kata Sandi'),
                        _buildPasswordField(
                          hint: 'Ulangi kata sandi Anda', 
                          isObscure: _obscureConfirmPassword, 
                          onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Tombol Submit (Daftar)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF148348),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              // Kembali ke login saat selesai daftar
                              Navigator.pop(context);
                            },
                            child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Garis pemisah "atau"
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('atau', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                            ),
                            const Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Teks Masuk
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context); // Kembali ke halaman login
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Sudah punya akun? ',
                                style: TextStyle(color: Colors.black54, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Masuk di sini', style: TextStyle(color: Color(0xFF148348), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi helper (widget ekstraksi) agar kode form tidak terlalu panjang
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF148348), width: 2)),
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required bool isObscure, required VoidCallback onTap}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
          onPressed: onTap,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF148348), width: 2)),
      ),
    );
  }
}