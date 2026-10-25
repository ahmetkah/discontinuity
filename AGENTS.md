# AGENTS.md

## Ürün
Üniversite öğrencileri için devamsızlık takip prototipi. 2 ekran: Ders Listesi ve Ders Ekle.
MVP: ders ekleme, ders listesi, +1/−1 sayaç ve renkli uyarı.
Tasarım referansı: design/screen1.png (Ders Listesi) ve design/screen2.png (Ders Ekle).

## İş kuralı
- Dönem 14 hafta.
- Devamsızlık hakkı = haftalık saat × 14 × 0,3, aşağı yuvarlanır (3 saat → 12).
- Kullanılan saat sıfırın altına inmez.
- Durumlar: normal; hakkın yarısı veya fazlası kullanıldıysa "dikkat" (turuncu); hak dolduysa "doldu" (kırmızı).

## Teknik
- Flutter ve Dart.
- State için yalnızca StatefulWidget ve setState.
- Harici paket ekleme.
- Veriler şimdilik bellekte tutulur.
- Arayüz metinleri Türkçe.

## Kapsam dışı
Kalıcı veri, hesap ve bulut, bildirim, not ortalaması, Ders Detayı ekranı.

## Çalışma şekli
- Onaylanan planı adım adım uygula; her seferinde yalnızca istenen adımı yap, kendi başına özellik ekleme.
- Değişiklikten sonra flutter analyze çalıştır.
- Commit atma; commit'leri geliştirici atar.
