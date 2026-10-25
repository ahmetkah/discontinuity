import 'package:flutter/material.dart';

import 'main.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.ders,
    required this.onArtir,
    required this.onAzalt,
  });

  final Ders ders;
  final VoidCallback onArtir;
  final VoidCallback onAzalt;

  // Renkler design/screen1.png'den alındı.
  Color get _renk => switch (ders.durum) {
    DersDurumu.normal => const Color(0xFF2E7D32),
    DersDurumu.dikkat => const Color(0xFFC05600),
    DersDurumu.doldu => const Color(0xFFBA1A1A),
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
