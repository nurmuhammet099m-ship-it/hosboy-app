import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BypassDnsHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = BypassDnsHttpOverrides();

  await Supabase.initialize(
    url: 'https://hifajxvajxsplwzcornh.supabase.co',
    anonKey: 'sb_publishable_kWGFCXmyYR-VJTRsRLNWA_YP_lh41IH',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOŞBOÝ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen e-posta adresinizi girin.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithOtp(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doğrulama kodu e-postanıza gönderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOŞBOÝ Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Giriş Yap / Kod Gönder', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
