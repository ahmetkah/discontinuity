import 'package:flutter/material.dart';

import 'course_card.dart';

void main() {
  runApp(const MainApp());
}

enum DersDurumu { normal, dikkat, doldu }

class Ders {
  Ders({required this.ad, required this.haftalikSaat, this.kullanilan = 0});

  final String ad;
  final int haftalikSaat;
  int kullanilan;

  // haftalık saat × 14 × 0,3; tamsayı bölmesiyle aşağı yuvarlanır.
  int get hak => haftalikSaat * 14 * 3 ~/ 10;

  int get kalan => hak - kullanilan;

  bool get hakDoldu => kullanilan >= hak;

  // "kullanilan >= hak / 2" ile aynı; ×2 tek sayılı haklarda kesirli bölmeyi önler.
  bool get yarisiKullanildi => kullanilan * 2 >= hak;

  DersDurumu get durum {
    if (hakDoldu) return DersDurumu.doldu;
    if (yarisiKullanildi) return DersDurumu.dikkat;
    return DersDurumu.normal;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devamsızlık',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const DersListesiEkrani(),
    );
  }
}

class DersListesiEkrani extends StatefulWidget {
  const DersListesiEkrani({super.key});

  @override
  State<DersListesiEkrani> createState() => _DersListesiEkraniState();
}

class _DersListesiEkraniState extends State<DersListesiEkrani> {
  final List<Ders> _dersler = [
    Ders(ad: 'Veri Tabanı Yönetimi', haftalikSaat: 3, kullanilan: 2),
    Ders(ad: 'İstatistik', haftalikSaat: 2, kullanilan: 4),
    Ders(ad: 'Yönetim Bilişim Sistemleri', haftalikSaat: 4, kullanilan: 16),
  ];

  void _artir(Ders ders) {
    setState(() => ders.kullanilan++);
  }

  void _azalt(Ders ders) {
    if (ders.kullanilan == 0) return;
    setState(() => ders.kullanilan--);
  }

  Future<void> _dersEkle() async {
    final yeniDers = await Navigator.push<Ders>(
      context,
      MaterialPageRoute(builder: (context) => const DersEkleEkrani()),
    );
    if (yeniDers == null) return;
    setState(() => _dersler.add(yeniDers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devamsızlık')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dersEkle,
        icon: const Icon(Icons.add),
        label: const Text('Ders ekle'),
      ),
      body: ListView.builder(
        // Alttaki boşluk, son kartın butonlarının FAB altında kalmaması için.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _dersler.length,
        itemBuilder: (context, index) {
          final ders = _dersler[index];
          return CourseCard(
            ders: ders,
            onArtir: () => _artir(ders),
            onAzalt: () => _azalt(ders),
          );
        },
      ),
    );
  }
}

class DersEkleEkrani extends StatefulWidget {
  const DersEkleEkrani({super.key});

  @override
  State<DersEkleEkrani> createState() => _DersEkleEkraniState();
}

class _DersEkleEkraniState extends State<DersEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _saatController = TextEditingController();

  @override
  void dispose() {
    _adController.dispose();
    _saatController.dispose();
    super.dispose();
  }

  String? _adDogrula(String? deger) {
    if (deger == null || deger.trim().isEmpty) return 'Ders adı gir';
    return null;
  }

  String? _saatDogrula(String? deger) {
    final saat = int.tryParse(deger?.trim() ?? '');
    if (saat == null || saat < 1 || saat > 20) {
      return 'Geçerli bir saat gir (1–20)';
    }
    return null;
  }

  void _kaydet() {
    if (!_formKey.currentState!.validate()) return;
    final ders = Ders(
      ad: _adController.text.trim(),
      haftalikSaat: int.parse(_saatController.text.trim()),
    );
    Navigator.pop(context, ders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ders Ekle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _adController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Ders adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: _adDogrula,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _saatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Haftalık saat',
                    border: OutlineInputBorder(),
                  ),
                  validator: _saatDogrula,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _kaydet,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
