import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Logo
                  Row(
                    children: [
                      Image.asset('assets/LogoWeb.png', height: 36),
                      const SizedBox(width: 12),
                      Text(
                        'Smart Pest Trap',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Teks Sambutan
                  const Text('Selamat datang kembali', style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Masuk ke Smart\nPest Trap', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1.1, color: Colors.black87)),
                  const SizedBox(height: 16),
                  const Text('Pantau hama. Prediksi peningkatan.\nLindungi hasil panen.', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                  
                  const SizedBox(height: 40),

                  // Kotak Form AuthClientForm
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
                        // Header Form
                        const Text('Masuk ke Smart Pest Trap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))), // 0xFF0F172A = slate-900
                        const SizedBox(height: 8),
                        const Text('Pantau lahan pertanian Anda secara presisi dengan teknologi AIoT.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 24),
                        
                        // Input Email
                        const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Masukkan email Anda',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC), // Sesuai web
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF148348), width: 2)), // Sesuai web
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Input Kata Sandi
                        const Text('Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF148348), width: 2)),
                          ),
                        ),
                        
                        // Lupa Password & Ingat Saya
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: const Color(0xFF148348),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text('Ingat saya', style: TextStyle(fontSize: 13, color: Colors.black87)),
                              ],
                            ),
                            const Text('Lupa kata sandi?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF148348))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Tombol Submit (Masuk)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF148348), // Warna hijau dari web
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: () {
                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
                            },
                            child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        
                        // Teks Daftar
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(color: Colors.black54, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Daftar sekarang', style: TextStyle(color: Color(0xFF148348), fontWeight: FontWeight.bold)),
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
}