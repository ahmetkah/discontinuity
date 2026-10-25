import 'package:flutter/material.dart';

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

  DersDurumu get durum {
    if (kullanilan >= hak) return DersDurumu.doldu;
    if (kullanilan * 2 >= hak) return DersDurumu.dikkat;
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
          return DersKarti(
            ders: ders,
            onArtir: () => _artir(ders),
            onAzalt: () => _azalt(ders),
          );
        },
      ),
    );
  }
}

class DersKarti extends StatelessWidget {
  const DersKarti({
    super.key,
    required this.ders,
    required this.onArtir,
    required this.onAzalt,
  });

  final Ders ders;
  final VoidCallback onArtir;
  final VoidCallback onAzalt;

  Color get _renk => switch (ders.durum) {
    DersDurumu.normal => Colors.green.shade800,
    DersDurumu.dikkat => Colors.orange.shade800,
    DersDurumu.doldu => Colors.red.shade800,
  };

  String get _durumMetni => switch (ders.durum) {
    DersDurumu.normal => 'Kalan hak: ${ders.kalan} saat',
    DersDurumu.dikkat => 'Dikkat: ${ders.kalan} saat kaldı',
    DersDurumu.doldu => 'Devamsızlık hakkın doldu!',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ders.ad, style: textTheme.titleMedium),
                      Text(
                        'Haftalık ${ders.haftalikSaat} saat',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${ders.kullanilan} / ${ders.hak}',
                        style: textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _durumMetni,
                        style: textTheme.titleSmall?.copyWith(color: _renk),
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: onAzalt,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onArtir,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (ders.kullanilan / ders.hak).clamp(0.0, 1.0),
              color: _renk,
              backgroundColor: Colors.grey.shade300,
            ),
          ],
        ),
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
  final _adController = TextEditingController();
  final _saatController = TextEditingController();

  @override
  void dispose() {
    _adController.dispose();
    _saatController.dispose();
    super.dispose();
  }

  void _kaydet() {
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
          child: Column(
            children: [
              TextField(
                controller: _adController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Ders adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _saatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Haftalık saat',
                  border: OutlineInputBorder(),
                ),
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
    );
  }
}
