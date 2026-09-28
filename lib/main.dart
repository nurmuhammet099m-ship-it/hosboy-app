import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://steep-grass-510a.nurmuhammetmerdanov49.workers.dev';
const supabaseAnonKey = 'Sb_publishable_KW5FCXCmyYR-VJTRoRLWUA_YPJh4ljH';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  runApp(const HosboyApp());
}

Future<void> sendGmailOTP(String email) async {
  await Supabase.instance.client.auth.signInWithOtp(
    email: email.trim(),
  );
}

Future<void> verifyGmailOTP(String email, String token) async {
  final response = await Supabase.instance.client.auth.verifyOTP(
    email: email.trim(),
    token: token.trim(),
    type: OtpType.email,
  );

  if (response.session != null) {
    // Giriş başarılı
  }
}

class HosboyApp extends StatelessWidget {
  const HosboyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOSBOY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('HOSBOY Uygulamasına Hoş Geldiniz'),
        ),
      ),
    );
  }
}
