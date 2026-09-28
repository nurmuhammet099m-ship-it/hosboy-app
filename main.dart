import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const HosboyApp());
}

final demoPerfumes = <Perfume>[
  Perfume(id: 'demo-1', name: 'Hoşboy Signature', category: 'Unisex',
      price: 1200, stock: 20,
      description: 'Zarif, kalıcı ve modern bir koku. Günlük kullanım ve özel anlar için.'),
  Perfume(id: 'demo-2', name: 'Hoşboy Femme', category: 'Kadın',
      price: 1100, stock: 15,
      description: 'Çiçeksi ve sofistike notalara sahip zarif kadın parfümü.'),
  Perfume(id: 'demo-3', name: 'Hoşboy Homme', category: 'Erkek',
      price: 1150, stock: 18,
      description: 'Güçlü, temiz ve modern karaktere sahip erkek parfümü.'),
];

class Perfume {
  final String id, name, category, description;
  final double price;
  final int stock;
  const Perfume({required this.id, required this.name, required this.category,
      required this.price, required this.stock, required this.description});
}

class HosboyApp extends StatelessWidget {
  const HosboyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hoşboy',
    theme: ThemeData(
      useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF171417),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F1D2C),
          brightness: Brightness.dark),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String category = 'Tümü', query = '';
  final cart = <Perfume>[];

  @override
  Widget build(BuildContext context) {
    final products = demoPerfumes.where((p) =>
      (category == 'Tümü' || p.category == category) &&
      p.name.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const BrandTitle(),
        actions: [IconButton(
          tooltip: 'Admin',
          icon: const Icon(Icons.admin_panel_settings_outlined),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminLoginPage())),
        )]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const BrandHero(),
        const SizedBox(height: 18),
        TextField(
          decoration: InputDecoration(
            hintText: 'Parfüm ara...', prefixIcon: const Icon(Icons.search),
            filled: true, fillColor: const Color(0xFF211E21),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none)),
          onChanged: (v) => setState(() => query = v)),
        const SizedBox(height: 14),
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: ['Tümü','Kadın','Erkek','Unisex'].map((c) =>
            Padding(padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(c), selected: category == c,
                onSelected: (_) => setState(() => category = c)))).toList())),
        const SizedBox(height: 20),
        const Text('Parfümler', style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...products.map((p) => Card(
          color: const Color(0xFF211E21), margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(width: 70, height: 82,
              decoration: BoxDecoration(color: const Color(0xFF3B1820),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8C6A21))),
              child: const Icon(Icons.local_florist, size: 34,
                  color: Color(0xFFD4AF37))),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(padding: const EdgeInsets.only(top: 6),
              child: Text('${p.category}\n${p.price.toStringAsFixed(0)} TMT • Stok: ${p.stock}')),
            trailing: FilledButton.tonal(
              onPressed: p.stock > 0 ? () => _openOrder(p) : null,
              child: const Text('Satın al')),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProductPage(perfume: p))),
          ))),
      ]),
    );
  }

  void _openOrder(Perfume p) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => OrderPage(perfume: p)));
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});
  @override Widget build(BuildContext context) => const Column(children: [
    Text('HOŞBOY', style: TextStyle(fontWeight: FontWeight.bold,
      letterSpacing: 3, color: Color(0xFFD4AF37))),
    Text('Bu sen we seniñ ysyñ', style: TextStyle(fontSize: 10,
      color: Color(0xFFD4AF37))),
  ]);
}

class BrandHero extends StatelessWidget {
  const BrandHero({super.key});
  @override Widget build(BuildContext context) => Container(
    height: 165, decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(colors: [Color(0xFF421B25), Color(0xFF171417)]),
      border: Border.all(color: const Color(0xFF8C6A21))),
    child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🐉  🐉', style: TextStyle(fontSize: 27)),
        SizedBox(height: 4),
        Text('HOŞBOY', style: TextStyle(fontSize: 30, letterSpacing: 6,
          color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        Text('🐉  🐉', style: TextStyle(fontSize: 27)),
      ])),
  );
}

class ProductPage extends StatelessWidget {
  final Perfume perfume;
  const ProductPage({super.key, required this.perfume});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(perfume.name)),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(height: 260, decoration: BoxDecoration(
        color: const Color(0xFF3B1820), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF8C6A21))),
        child: const Icon(Icons.local_florist, size: 100, color: Color(0xFFD4AF37))),
      const SizedBox(height: 20),
      Text(perfume.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
      Text(perfume.category, style: const TextStyle(color: Color(0xFFD4AF37))),
      const SizedBox(height: 10),
      Text('${perfume.price.toStringAsFixed(0)} TMT',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      Text(perfume.description, style: const TextStyle(fontSize: 16, height: 1.5)),
      const SizedBox(height: 18),
      const Divider(),
      const ListTile(leading: Icon(Icons.verified_outlined),
        title: Text('Doğrulanmış satın alma yorumları'),
        subtitle: Text('Yorum yalnızca ürünü satın alan kullanıcı tarafından bırakılabilir.')),
      const ListTile(leading: Icon(Icons.question_answer_outlined),
        title: Text('Ürün hakkında soru sor'),
        subtitle: Text('Sorular siparişten sonra admin panelinden yanıtlanabilir.')),
      const SizedBox(height: 14),
      FilledButton.icon(
        icon: const Icon(Icons.shopping_bag_outlined),
        label: const Text('Satın al'),
        onPressed: perfume.stock > 0 ? () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => OrderPage(perfume: perfume))) : null),
    ]),
  );
}

class OrderPage extends StatefulWidget {
  final Perfume perfume;
  const OrderPage({super.key, required this.perfume});
  @override State<OrderPage> createState() => _OrderPageState();
}
class _OrderPageState extends State<OrderPage> {
  final name = TextEditingController(), phone = TextEditingController(),
      address = TextEditingController(), extra = TextEditingController();
  String city = 'Aşgabat';
  @override void dispose() { name.dispose(); phone.dispose(); address.dispose();
    extra.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sipariş')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(widget.perfume.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'İsim')),
      const SizedBox(height: 12),
      TextField(controller: phone, keyboardType: TextInputType.phone,
        maxLength: 8, decoration: const InputDecoration(
          labelText: 'Telnum', prefixText: '+993 ')),
      const SizedBox(height: 12),
      TextField(controller: address, decoration: const InputDecoration(labelText: 'Ew adresi')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: city, decoration: const InputDecoration(labelText: 'Şehir'),
        items: const ['Änew','Aşgabat'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
        onChanged: (x) => setState(() => city = x!)),
      const SizedBox(height: 12),
      TextField(controller: extra, maxLength: 100, maxLines: 3,
        decoration: const InputDecoration(labelText: 'Ek bilgi',
          hintText: 'Örn. Ew okulun arkasynda')),
      const SizedBox(height: 20),
      FilledButton(onPressed: _submit, child: const Text('Siparişi gönder')),
    ]),
  );
  void _submit() {
    final validPhone = RegExp(r'^\d{8}$').hasMatch(phone.text.trim());
    if (name.text.trim().isEmpty || address.text.trim().isEmpty || !validPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İsim, Ew adresi ve 8 haneli telefon numarası zorunludur.')));
      return;
    }
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Sipariş alındı'),
      content: Text('Teşekkürler ${name.text.trim()}. ${widget.perfume.name} siparişiniz kaydedildi.'),
      actions: [TextButton(onPressed: () {
        Navigator.pop(context); Navigator.pop(context);
      }, child: const Text('Tamam'))],
    ));
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override State<AdminLoginPage> createState() => _AdminLoginPageState();
}
class _AdminLoginPageState extends State<AdminLoginPage> {
  final phone = TextEditingController();
  bool loading = false;

  @override void dispose() { phone.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Özel Admin Girişi')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.lock_outline, size: 70, color: Color(0xFFD4AF37)),
      const SizedBox(height: 16),
      const Text('Bu panel yalnızca 2 yetkili kişi içindir.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Telefon numarası + OTP doğrulaması ile giriş yapılır.',
        textAlign: TextAlign.center),
      const SizedBox(height: 24),
      TextField(controller: phone, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Admin telefonu', prefixText: '+993 ')),
      const SizedBox(height: 16),
      FilledButton(onPressed: loading ? null : _login, child: loading
        ? const CircularProgressIndicator() : const Text('OTP gönder')),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        icon: const Icon(Icons.visibility_outlined),
        label: const Text('Demo admin panelini aç'),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage())),
      ),
    ]),
  );

  Future<void> _login() async {
    final p = phone.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(p)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('8 haneli admin telefon numarası girin.')));
      return;
    }
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerçek OTP için Supabase anahtarları eklenmeli. Demo paneli kullanılabilir.')));
      return;
    }
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: '+993$p');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP gönderildi. OTP doğrulama ekranı sonraki adımda açılacak.')));
      }
    } finally { if (mounted) setState(() => loading = false); }
  }
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hoşboy Admin')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const _AdminBanner(),
      const SizedBox(height: 16),
      _adminTile(context, Icons.people_outline, 'Uygulama kullanıcıları',
        'Kimlerin kayıt olduğunu, şehir ve telefon bilgilerini görüntüle.', const UserListPage()),
      _adminTile(context, Icons.shopping_bag_outlined, 'Siparişler',
        'Siparişleri, müşteri bilgilerini ve durumlarını yönet.', const OrderListPage()),
      _adminTile(context, Icons.inventory_2_outlined, 'Ürünler',
        'Ürün ekle, düzenle, sil; fiyat ve stok değiştir.', const ProductAdminPage()),
      _adminTile(context, Icons.question_answer_outlined, 'Sorular',
        'Müşterilerin sorularını gör ve yanıtla.', const QuestionsPage()),
      _adminTile(context, Icons.star_outline, 'Yorumlar',
        'Satın alma doğrulaması olan yorumları yönet.', const ReviewsPage()),
    ]),
  );
  Widget _adminTile(BuildContext c, IconData i, String title, String sub, Widget page) =>
    Card(child: ListTile(leading: Icon(i, color: const Color(0xFFD4AF37)),
      title: Text(title), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page))));
}

class _AdminBanner extends StatelessWidget {
  const _AdminBanner();
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF8C6A21)),
      gradient: const LinearGradient(colors: [Color(0xFF421B25), Color(0xFF211E21)])),
    child: const Row(children: [
      Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37), size: 42),
      SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('2 yetkili admin', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          SizedBox(height: 4), Text('Panel özel yetki ile korunur.')]))
    ]));
}

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});
  @override Widget build(BuildContext context) {
    final demoUsers = [
      ['Nurmuhammet', '+993 65••••••', 'Aşgabat', '18 Eyl 2026'],
      ['Müşteri 2', '+993 62••••••', 'Änew', '17 Eyl 2026'],
    ];
    return Scaffold(appBar: AppBar(title: const Text('Uygulama kullanıcıları')),
      body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: demoUsers.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(demoUsers[i][0]), subtitle: Text('${demoUsers[i][1]}\n${demoUsers[i][2]} • ${demoUsers[i][3]}'),
          isThreeLine: true)));
  }
}

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Siparişler')),
    body: const Center(child: Text('Gerçek siparişler Supabase bağlantısından listelenecek.')));
}

class ProductAdminPage extends StatelessWidget {
  const ProductAdminPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Ürün yönetimi')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ürün ekleme formu bağlanacak.'))),
      label: const Text('Ürün ekle'), icon: const Icon(Icons.add)),
    body: ListView(children: demoPerfumes.map((p) => ListTile(
      title: Text(p.name), subtitle: Text('${p.category} • ${p.price.toStringAsFixed(0)} TMT • Stok ${p.stock}'),
      trailing: const Icon(Icons.edit_outlined))).toList()));
}

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Müşteri soruları')),
    body: const Center(child: Text('Sorular ve admin cevapları Supabase bağlantısından listelenecek.')));
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Yorumlar')),
    body: const Center(child: Text('Sadece doğrulanmış satın alma yorumları gösterilecek.')));
}
