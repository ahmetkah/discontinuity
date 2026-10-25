# Adım Adım Geliştirme

> Adımları uygularken [docs/Ogrenci_Akisi.pdf](Ogrenci_Akisi.pdf)'i takip et; bu doküman her adımın nedenini ve kodda ne değiştiğini anlatır.

Akış sana her adımda **ne yapacağını** ve **ne zaman bitmiş sayılacağını** söylüyor. Bu doküman ise her adım için şunları anlatıyor:

- **Amaç ve neden:** Bu adımı neden bu şekilde yaptık?
- **Kullanılan prompt:** AI kod agent'ına verdiğimiz görev tanımının tam metni.
- **Commit:** Commit numarası, etiketi ve hash'i (adım başlığının altında).
- **Değişen dosyalar:** Adımın commit'inde neyin değiştiği (`git show --stat` çıktısından).
- **Kod açıklaması:** Kodda ne oldu ve nasıl çalışıyor?

Genel bakış için [README](../README.md)'ye dön. Kurulum için [Flutter Kurulum Rehberi](Flutter_Kurulum_Rehberi.pdf)'ne bak.

## İçindekiler

- [Ders öncesi: Tasarım görselleri](#ders-öncesi-tasarım-görselleri)
- [Adım 1 · Problem → MVP](#adım-1--problem--mvp)
- [Adım 2 · Context, plan ve tasarım](#adım-2--context-plan-ve-tasarım)
- [Adım 3 · Proje ve yapı](#adım-3--proje-ve-yapı)
- [Adım 4 · Model, liste, state](#adım-4--model-liste-state)
- [Adım 5 · Ders ekleme ve navigation](#adım-5--ders-ekleme-ve-navigation)
- [Adım 6 · Hata ve debugging](#adım-6--hata-ve-debugging)
- [Adım 7 · Arayüzü tasarıma yaklaştır](#adım-7--arayüzü-tasarıma-yaklaştır)
- [Adım 8 · Refactoring ve inceleme](#adım-8--refactoring-ve-inceleme)
- [Adım 9 · Son tur](#adım-9--son-tur)

## Prompt'ları nasıl okumalısın?

Prompt'ların çoğu aynı kalıbı izliyor:

| Bölüm | Ne işe yarar? |
|---|---|
| **Hedef** | Bu adımda tam olarak ne yapılacak? |
| **Context** | Agent'ın bilmesi gereken kural ve veriler. |
| **Kısıt** | Nasıl yapılacak, neye dokunulmayacak? |
| **Dışında** | Bu adımda bilerek yapılmayacak olanlar. |
| **Kabul** | İş bitince nasıl test edeceğin. |

Bir de sık tekrar eden bir cümle var: **"Henüz kod yazma."** Planlama adımlarında agent'ın hemen kod üretmesini engeller; önce fikri ve planı görür, onaylarsın.

Ayrıca kökteki [AGENTS.md](../AGENTS.md) her prompt'ta agent'ın arka planda okuduğu kalıcı bağlamdır. İş kuralını ya da "paket ekleme" kısıtını her prompt'ta tekrar yazmak zorunda kalmamamızın nedeni bu.

---

## Ders öncesi: Tasarım görselleri

**Slayt:** — · **Prompt:** PROMPT 0 · **Commit:** yok (görseller COMMIT 1 ile repoya girdi)

### Amaç ve neden

Canlı geliştirmede agent'a "hedef görünüm" olarak verilecek ekran tasarımlarını hazırlamak. Bu adımı eğitmen ders öncesinde yaptı; numaralı adımlardan biri sayılmıyor. Sonuç [design/](../design/) klasöründe: [screen1.png](../design/screen1.png) Ders Listesi, [screen2.png](../design/screen2.png) Ders Ekle, [screen3.png](../design/screen3.png) Ders Detayı.

Prompt'un **Kısıtlar** bölümüne dikkat et: hangi bileşenlerin kullanılabileceği tek tek sayılmış. Tasarımı bir AI kod agent'ına referans olarak vereceksen, tasarımın kodla gerçekten yapılabilir olması gerekir. Gradient ya da özel ikon içeren bir tasarım, agent'ı ya paket eklemeye ya da tasarımdan uzaklaşmaya zorlardı. Örnek verilerin iş kuralıyla tutarlı olması da (3 saat → 12 saat hak) aynı nedenle önemli: görsel, kodun doğru çalışıp çalışmadığını kontrol etmek için de kullanılıyor.

### Kullanılan prompt

[prompts/Prompt_0_Claude_Design_dersten_once.txt](prompts/Prompt_0_Claude_Design_dersten_once.txt)

```text
Bir üniversite öğrencisinin ders devamsızlığını takip ettiği basit bir mobil uygulama için 3 ekranlık tasarım hazırla. Bu tasarım canlı bir eğitimde Flutter ile kodlanacak ve bir AI kod ajanına referans görsel olarak verilecek. Bu yüzden sade olmalı ve Flutter'ın standart Material 3 bileşenleriyle birebir yapılabilmeli.

Format: Android telefon ölçüsünde, açık tema. Üç ekranı aynı boyutta telefon çerçevelerinde yan yana göster, her birinin üstüne ekran adını yaz. Tüm metinler Türkçe.

İş kuralı: Dönem 14 hafta. Devamsızlık hakkı = haftalık saat × 14 × 0,3, aşağı yuvarlanır (2 saat → 8, 3 saat → 12, 4 saat → 16).

Durumlar (renk tek başına anlam taşımasın, her durumda yazı da olsun):
- Normal: kullanılan saat hakkın yarısından az → yeşil, "Kalan hak: X saat"
- Dikkat: hakkın yarısı veya fazlası kullanıldı → turuncu, "Dikkat: X saat kaldı"
- Doldu: hakkın tamamı kullanıldı → kırmızı, "Devamsızlık hakkın doldu!"

EKRAN 1 – Ders Listesi
- AppBar başlığı: "Devamsızlık"
- Her ders bir Card: ders adı, "Haftalık X saat", büyük yazıyla "kullanılan / hak" (ör. 4 / 8), durum satırı, ince bir ilerleme çubuğu, sağda −1 ve +1 butonları.
- Üç örnek ders:
  • Veri Tabanı Yönetimi · haftalık 3 saat · 2 / 12 · normal
  • İstatistik · haftalık 2 saat · 4 / 8 · dikkat
  • Yönetim Bilişim Sistemleri · haftalık 4 saat · 16 / 16 · doldu
- Sağ altta genişletilmiş FAB: "+ Ders ekle"

EKRAN 2 – Ders Ekle
- AppBar: geri oku ve "Ders Ekle"
- İki alan: "Ders adı" (dolu: Pazarlama) ve "Haftalık saat" (sayısal).
- "Haftalık saat" alanını hata durumunda göster; altında kırmızı "Geçerli bir saat gir (1–20)" yazısı olsun.
- Altta tam genişlikte "Kaydet" butonu.

EKRAN 3 – Ders Detayı (sonraki sürüm hedefi)
- AppBar: geri oku ve "İstatistik"
- Ortada büyük dairesel ilerleme göstergesi: 4 / 8, altında "Dikkat: 4 saat kaldı"
- Bilgi satırları: Haftalık saat 2 · Dönem 14 hafta · Devamsızlık hakkı 8 saat

Kısıtlar:
- Yalnızca şu bileşenler: AppBar, Card, ListView, FloatingActionButton.extended, TextFormField, FilledButton, IconButton, LinearProgressIndicator, CircularProgressIndicator.
- Varsayılan Roboto yazı tipi, tek bir ana renk ve yukarıdaki üç durum rengi.
- Gradient, illüstrasyon, özel ikon, alt menü, arama, giriş ekranı, grafik veya ayarlar ekleme. Burada yazmayan hiçbir özellik ekleme.
```

### Değişen dosyalar

Bu adımda commit yok. Üç görsel, Adım 3'teki ilk commit'le (`beecf44`) repoya girdi.

---

## Adım 1 · Problem → MVP

**Slayt:** S12 · **Prompt:** PROMPT 1 · **Commit:** yok

### Amaç ve neden

Problemi tanımlamak ve kapsamı küçültmek: 40 dakikada geliştirilebilecek, en fazla 4 özellikli bir MVP seçmek. Kalan fikirleri silmek yerine "Sonra" listesine almak.

"Bana bir uygulama yap" demek yerine önce kapsamı daraltıyoruz. "Sonra" listesi önemli: fikirleri kaybetmiyoruz ama bu turda da yapmıyoruz. Eğitimde seçtiğimiz sonuç:

| | |
|---|---|
| **MVP** | Ders ekleme, ders listesi, +1/−1 sayaç ve renkli uyarı. |
| **Sonra** | Bildirim, bulut senkronizasyonu, not ortalaması ve detay ekranı. |

Buradaki karar, bir sonraki adımda [AGENTS.md](../AGENTS.md)'nin **Kapsam dışı** bölümüne dönüşüyor.

### Kullanılan prompt

[prompts/Prompt_1_MVP.txt](prompts/Prompt_1_MVP.txt)

```text
Henüz kod yazma ve dosya oluşturma.

Problem: Üniversite öğrencileri devamsızlık hakkının bittiğini çoğu zaman iş işten geçince fark ediyor. Haftalık 5–6 dersi olan bir öğrenci için Flutter ile çalışan bir prototip yapacağız.

40 dakikada geliştirilebilecek bir MVP öner: en fazla 4 özellik. Diğer fikirleri ayrı bir "Sonra" listesine yaz. Cevabın kısa olsun.
```

### Değişen dosyalar

Bu adımda commit yok; agent'tan yalnızca yazılı bir öneri istedik. Agent'ın verdiği cevabın tam metni repoda saklanmıyor.

---

## Adım 2 · Context, plan ve tasarım

**Slayt:** S13 · **Prompt:** PROMPT 2–3 · **Commit:** yok

### Amaç ve neden

Agent'ın her adımda uyacağı kalıcı bağlamı ([AGENTS.md](../AGENTS.md)) yazdırmak ve MVP'yi, her biri çalışan bir uygulamayla biten küçük adımlara böldürmek.

`AGENTS.md`, agent'ın her oturumda okuduğu proje kuralları dosyası. İçine yazdığın her kural sonraki tüm prompt'larda geçerli olur. Örneğin "State için yalnızca StatefulWidget ve setState" kuralı sayesinde agent kendi başına bir state yönetim paketi eklemiyor; "Commit atma" kuralı sayesinde de kayıt noktalarını sen belirliyorsun.

PROMPT 3'te agent'a görselleri de inceletiyoruz. Böylece plan, "nasıl görünmeli" sorusunu baştan biliyor. "Her adımın sonunda uygulama çalışıyor olsun" şartı da her adımın sonunda bir commit atabilmemizi sağlıyor.

### Kullanılan prompt'lar

**PROMPT 2:** [prompts/Prompt_2_AGENTS_md.txt](prompts/Prompt_2_AGENTS_md.txt)

```text
Henüz kod yazma ve Flutter projesi oluşturma. Seçtiğimiz MVP'ye göre bu klasörün köküne bir AGENTS.md dosyası oluştur. Kısa olsun (en fazla 30 satır), Türkçe yaz ve şu başlıkları kullan:

## Ürün
Üniversite öğrencileri için devamsızlık takip prototipi. 2 ekran: Ders Listesi ve Ders Ekle. MVP: ders ekleme, ders listesi, +1/−1 sayaç ve renkli uyarı. Tasarım referansı: design/screen1.png (Ders Listesi) ve design/screen2.png (Ders Ekle).

## İş kuralı
Dönem 14 hafta. Devamsızlık hakkı = haftalık saat × 14 × 0,3, aşağı yuvarlanır (3 saat → 12). Kullanılan saat sıfırın altına inmez.
Durumlar: normal; hakkın yarısı veya fazlası kullanıldıysa "dikkat" (turuncu); hak dolduysa "doldu" (kırmızı).

## Teknik
Flutter ve Dart. State için yalnızca StatefulWidget ve setState. Harici paket ekleme. Veriler şimdilik bellekte tutulur. Arayüz metinleri Türkçe.

## Kapsam dışı
Kalıcı veri, hesap ve bulut, bildirim, not ortalaması, Ders Detayı ekranı.

## Çalışma şekli
- Onaylanan planı adım adım uygula; her seferinde yalnızca istenen adımı yap, kendi başına özellik ekleme.
- Değişiklikten sonra flutter analyze çalıştır.
- Commit atma; commit'leri geliştirici atar.

Dosyayı oluşturduktan sonra başka bir şey yapma, yalnızca içeriğini 3 cümleyle özetle.
```

**PROMPT 3:** [prompts/Prompt_3_Plan.txt](prompts/Prompt_3_Plan.txt)

```text
Henüz kod yazma. AGENTS.md'yi ve design/ klasöründeki screen1.png ile screen2.png görsellerini incele. MVP'yi küçük adımlara bölen bir plan çıkar: en fazla 5 adım ve her adımın sonunda uygulama çalışıyor olsun. Her adım için ne yapılacağını ve nasıl test edileceğini birer cümleyle yaz. Paket, mimari katman veya ek ekran önerme.
```

### Değişen dosyalar

Bu adımda commit yok. Oluşan [AGENTS.md](../AGENTS.md), Adım 3'teki ilk commit'e girdi ve o günden beri değişmedi. Agent'ın çıkardığı planın metni repoda saklanmıyor.

---

## Adım 3 · Proje ve yapı

**Slayt:** S14 · **Prompt:** PROMPT 4 · **Commit:** COMMIT 1 “Boş proje oluşturuldu.” · **Etiket:** `adim-3` · **Hash:** `beecf44`

### Amaç ve neden

Boş bir Flutter projesi oluşturup çalıştırmak, proje yapısını anlamak ve ilk kayıt noktasını (commit) atmak. Bu andan itibaren bir şey ters giderse her zaman buraya dönebilirsin.

PROMPT 4 bir "kodu anlat" prompt'u: AI'dan her zaman kod istemek zorunda değilsin; açıklama istemek de çok değerli. "Hiçbir dosyayı değiştirme" cümlesi, agent'ın açıklarken projeye dokunmamasını garanti ediyor.

### Kullanılan prompt

[prompts/Prompt_4_Proje_Yapisi.txt](prompts/Prompt_4_Proje_Yapisi.txt)

```text
Bu Flutter projesinin yapısını yeni başlayan biri için 5 maddede açıkla: hangi klasör ne işe yarar ve uygulama nereden başlar? Hiçbir dosyayı değiştirme.
```

### Değişen dosyalar

```bash
git show --stat adim-3
```

Bu commit toplam **70 dosya** ekliyor (1796 satır). Bunların 59'u Flutter'ın oluşturduğu platform dosyaları:

| Dosya | Eklenen satır |
|---|---|
| `.gitignore` | 48 |
| `.metadata` | 33 |
| [AGENTS.md](../AGENTS.md) | 27 |
| `README.md` | 3 |
| `analysis_options.yaml` | 7 |
| `design/screen1.png`, `design/screen2.png`, `design/screen3.png` | ikili dosya |
| `lib/main.dart` | 16 |
| `pubspec.lock` | 205 |
| `pubspec.yaml` | 19 |
| `android/` altında 19 dosya | platform dosyaları |
| `ios/` altında 40 dosya | platform dosyaları |

Eğitmen reposunda hem `android/` hem `ios/` klasörü var. Yalnızca Android için oluşturduğun bir projede `ios/` klasörü olmaz.

### Kod açıklaması

Bu adımdaki tek Dart kodu, boş proje şablonunun (`flutter create --empty`) ürettiği 16 satırlık `lib/main.dart`. Varsayılan sayaç örneği yerine yalnızca "Hello World!" yazan bir ekran:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
```

Uygulama `main()` fonksiyonundan başlar; `runApp` ekrana ilk widget'ı koyar. `MaterialApp` → `Scaffold` → `Center` → `Text` zinciri, slayt S9'daki "her şey widget" fikrinin en küçük örneği.

Commit'e `AGENTS.md` ve `design/` görselleri de girdi; yani Adım 1–2'nin çıktıları da bu ilk kayıt noktasında.

---

## Adım 4 · Model, liste, state

**Slayt:** S15 · **Prompt:** PROMPT 5 · **Commit:** COMMIT 2 (Adım 5 ile ortak) · **Etiket:** `adim-5` · **Hash:** `03935af`

> Adım 4 ve Adım 5 ayrı prompt'larla uygulandı ama tek bir commit'le kaydedildi. Değişen dosyalar Adım 5'in altında.

### Amaç ve neden

`Ders` veri modelini ve iş kuralını yazmak, üç örnek dersi gösteren Ders Listesi ekranını ve +1/−1 sayacını yapmak.

Bu prompt, slayt S6'daki görev tanımı yapısının ilk tam örneği: hedef, context, kısıt, dışında, kabul. Üç örnek ders bilinçli seçildi: her biri farklı bir durumu (normal, dikkat, doldu) gösteriyor, böylece iş kuralının üç dalı da ilk açılışta görünüyor. **Dışında** satırı ise agent'ın ders ekleme ekranına şimdiden girişmesini engelliyor.

### Kullanılan prompt

[prompts/Prompt_5_Liste_ve_Sayac.txt](prompts/Prompt_5_Liste_ve_Sayac.txt)

```text
Hedef: Ders veri modelini ve Ders Listesi ekranını yap.
Context: AGENTS.md'deki iş kuralı geçerli. Başlangıçta 3 örnek ders olsun: Veri Tabanı Yönetimi (haftalık 3 saat, 2 saat kullanılmış), İstatistik (haftalık 2 saat, 4 saat kullanılmış), Yönetim Bilişim Sistemleri (haftalık 4 saat, 16 saat kullanılmış).
Kısıt: StatefulWidget ve setState kullan, paket ekleme. Her kartta ders adı, "kullanılan / hak" ve +1, −1 butonları olsun. Durum rengini AGENTS.md'deki kurala göre göster.
Dışında: Bu adımda ders ekleme ekranı yok.
Kabul: Bitince nasıl test edeceğimi madde madde yaz.
```

### Kod açıklaması

İş kuralı `Ders` sınıfında tek satır:

```dart
// haftalık saat × 14 × 0,3; tamsayı bölmesiyle aşağı yuvarlanır.
int get hak => haftalikSaat * 14 * 3 ~/ 10;
```

`× 0,3` yerine `× 3 ~/ 10` kullanılmış. `~/` Dart'ta tamsayı bölmesidir ve sonucu aşağı yuvarlar; böylece ondalık sayılarla uğraşmadan `3 × 14 × 0,3 = 12,6 → 12` elde edilir.

Durum hesabı da modelde:

```dart
DersDurumu get durum {
  if (kullanilan >= hak) return DersDurumu.doldu;
  if (kullanilan * 2 >= hak) return DersDurumu.dikkat;
  return DersDurumu.normal;
}
```

+1 ve −1 butonları `setState` çağırır. `setState`, Flutter'a "ekranın hafızası değişti, yeniden çiz" der; `build` yeniden çalışır ve kart yeni sayıyla, gerekirse yeni renkle çizilir. "Sıfırın altına inmez" kuralı `_azalt` metodundaki erken dönüşle sağlanıyor:

```dart
void _azalt(Ders ders) {
  if (ders.kullanilan == 0) return;
  setState(() => ders.kullanilan--);
}
```

---

## Adım 5 · Ders ekleme ve navigation

**Slayt:** S16 · **Prompt:** PROMPT 6 · **Commit:** COMMIT 2 “Ders Listesi sayfası ve Ders ekleme sayfası” · **Etiket:** `adim-5` · **Hash:** `03935af`

### Amaç ve neden

Ders Ekle ekranını yapmak; listeden `Navigator.push` ile açıp Kaydet'te yeni dersi `Navigator.pop` ile listeye geri döndürmek.

Prompt'taki iki karar bilinçli: **"int.parse ile sayıya çevir"** ve **"Form doğrulaması bu adımda yok"**. Bu ikisi birlikte, bir sonraki adımda inceleyeceğimiz hatayı hazırlıyor. Hata ayıklamayı gerçek bir hata üzerinde öğrenmek için doğrulamayı bilerek sonraya bıraktık. "Mevcut liste ve +1/−1 davranışı değişmesin" kısıtı ise yeni özelliğin eskisini bozmamasını güvence altına alıyor.

### Kullanılan prompt

[prompts/Prompt_6_Ders_Ekleme.txt](prompts/Prompt_6_Ders_Ekleme.txt)

```text
Hedef: Ders Ekle ekranını yap. Listeye bir "+ Ders ekle" butonu ekle; bu buton ekranı Navigator.push ile açsın. Kaydet'e basınca yeni ders listeye eklensin ve Navigator.pop ile listeye dönülsün.
Context: Formda iki alan var: Ders adı ve Haftalık saat. Yeni dersin kullanılan saati 0 ile başlar.
Kısıt: Haftalık saati int.parse ile sayıya çevir. setState ile devam et, paket ekleme. Mevcut liste ve +1/−1 davranışı değişmesin.
Dışında: Form doğrulaması ve hata mesajları bu adımda yok; sonraki adımda ekleyeceğiz.
Kabul: Bitince nasıl test edeceğimi yaz.
```

### Değişen dosyalar

```bash
git show --stat adim-5
```

| Dosya | Değişiklik |
|---|---|
| `lib/main.dart` | 234 ekleme, 2 silme |

Bu commit Adım 4 ve Adım 5'in ikisini de içeriyor.

### Kod açıklaması

Ekranlar arası geçiş iki noktada yapılıyor. Listede:

```dart
final yeniDers = await Navigator.push<Ders>(
  context,
  MaterialPageRoute(builder: (context) => const DersEkleEkrani()),
);
if (yeniDers == null) return;
setState(() => _dersler.add(yeniDers));
```

Ders Ekle ekranında:

```dart
Navigator.pop(context, ders);
```

`push` yeni ekranı açar ve kapanmasını bekler (`await`). `pop` ekranı kapatırken yeni dersi geri gönderir. Kullanıcı geri okuyla çıkarsa sonuç `null` gelir ve listeye hiçbir şey eklenmez. Yeni ders gelirse `setState` ile listeye eklenir ve liste yeniden çizilir.

---

## Adım 6 · Hata ve debugging

**Slayt:** S17 · **Prompt:** PROMPT 7–8 · **Commit:** COMMIT 3 “Form doğrulaması” · **Etiket:** `adim-6` · **Hash:** `a16e659`

### Amaç ve neden

Bir hatayı önce **anlamak**, sonra **düzeltmek**. Agent'tan önce yalnızca açıklama istiyoruz; nedeni anladıktan sonra hedefli bir düzeltme yaptırıyoruz.

Bu adımın dersi slayttaki formülde: **Hata + doğru context + kontrol = güvenilir düzeltme.**

- **PROMPT 7**, agent'a hatanın metnini verip **"Henüz kod değiştirme"** diyor. Önce nedeni ve satırı sen de anlıyorsun.
- **PROMPT 8**, düzeltmeyi tek dosyayla sınırlıyor ve "doğru" davranışı somut olarak tarif ediyor: hangi durumda hangi mesaj.
- **Kontrol**, düzeltmenin yalnızca boş alanı değil, aşağıdaki tablodaki tüm hatalı girişleri yakaladığını doğrulamak demek.

Hata mesajını yapıştırmadan "çalışmıyor, düzelt" demek, agent'ı tahmin yürütmeye zorlar. Hatanın ilk birkaç satırı genellikle dosya ve satır bilgisini içerir; agent'a en değerli context budur.

### Kullanılan prompt'lar

**PROMPT 7 (anla):** [prompts/Prompt_7_Hata_Aciklama.txt](prompts/Prompt_7_Hata_Aciklama.txt)

```text
Ders Ekle ekranında saat alanını boş bırakıp Kaydet'e bastım, hiçbir şey olmadı. Debug Console'daki hata şu:
[hatanın ilk 3-4 satırını buraya yapıştır]
Henüz kod değiştirme. Hatanın nedenini ve hangi dosyanın hangi satırında oluştuğunu kısaca açıkla.
```

**PROMPT 8 (düzelt):** [prompts/Prompt_8_Hata_Duzeltme.txt](prompts/Prompt_8_Hata_Duzeltme.txt)

```text
Şimdi yalnızca bu dosyayı düzelt. Kaydet'e basınca form doğrulansın: ders adı boşsa "Ders adı gir", haftalık saat boşsa, sayı değilse ya da 1–20 aralığında değilse "Geçerli bir saat gir (1–20)" uyarısı alanın altında görünsün ve ders kaydedilmesin. Başka hiçbir dosyayı değiştirme. Bitince test adımlarını yaz.
```

### Değişen dosyalar

```bash
git show --stat adim-6
```

| Dosya | Değişiklik |
|---|---|
| `lib/main.dart` | 45 ekleme, 25 silme |

Silinen satırların çoğu gerçek bir silme değil: alanlar `Form` widget'ının içine alındığı için girintileri değişti.

### Kod açıklaması: FormatException neden oluştu?

Adım 5'teki kodda (`adim-5`, `lib/main.dart`, satır 200–206) Kaydet'e basınca şu metot çalışıyordu:

```dart
void _kaydet() {
  final ders = Ders(
    ad: _adController.text.trim(),
    haftalikSaat: int.parse(_saatController.text.trim()),   // satır 203
  );
  Navigator.pop(context, ders);
}
```

Olayların sırası:

1. Saat alanı boş olduğu için `_saatController.text.trim()` boş metin (`''`) döndürür.
2. `int.parse('')` boş metni sayıya çeviremez ve `FormatException` fırlatır. Yani **boş metni sayıya çevirmeye çalıştık**.
3. Hata `_kaydet` metodunun ortasında fırladığı için sonraki satıra hiç geçilmez: `Navigator.pop` çalışmaz, ders oluşturulmaz.
4. Flutter, butonun `onPressed` geri çağrısında oluşan bu hatayı yakalar ve `FormatException: Invalid number` ile başlayan bir mesajla Debug Console'a yazar, ama uygulamayı kapatmaz. Kullanıcı açısından sonuç: **"hiçbir şey olmadı"**.

Aynı sorun yalnızca boş alanla sınırlı değil. Slayttaki beklentiyle Adım 5'teki davranışı karşılaştır:

| Saat alanına girilen | Beklenen | Adım 5'te gerçekleşen |
|---|---|---|
| boş | Uyarı | `FormatException`, ekran sessizce kalır |
| `abc` | Uyarı | `FormatException`, ekran sessizce kalır |
| `0` | Uyarı | Hata yok; ders `0 / 0` hakla eklenir ve hemen "doldu" görünür |
| `25` | Uyarı | Hata yok; iş kuralının izin vermediği bir değer kaydedilir |

Son iki satır, hatanın yalnızca bir "çökme" değil bir **doğrulama eksikliği** olduğunu gösteriyor. `0` girildiğinde hak `0 × 14 × 3 ~/ 10 = 0` olur ve karttaki ilerleme çubuğu `kullanilan / hak` hesabında sıfıra böler.

Ders adı için de durum aynıydı: boş ad hiç kontrol edilmiyordu, yalnızca saat geçerliyse adsız bir ders listeye eklenebiliyordu.

### Kod açıklaması: Nasıl düzeltildi?

```bash
git diff adim-5 adim-6
```

Değişiklik yalnızca `lib/main.dart`'ta, `DersEkleEkrani`'nin state sınıfında. Dört parça var:

**1. Formun anahtarı.** Formu dışarıdan doğrulayabilmek için bir `GlobalKey` eklendi:

```dart
final _formKey = GlobalKey<FormState>();
```

**2. Doğrulama fonksiyonları.** Her alan için, hata varsa mesajı, yoksa `null` döndüren birer fonksiyon:

```dart
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
```

Buradaki kilit fark `int.parse` yerine **`int.tryParse`**: çeviremediği metinde hata fırlatmak yerine `null` döndürür. Boş metin, `abc`, `0` ve `25` tek bir koşulla yakalanıyor.

**3. `TextField` → `TextFormField` ve `Form`.** İki alan bir `Form` widget'ının içine alındı, `TextField`'lar `validator` parametresi olan `TextFormField`'a çevrildi:

```dart
child: Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _adController,
        // ...
        validator: _adDogrula,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _saatController,
        // ...
        validator: _saatDogrula,
      ),
      // ...
```

**4. Kaydetmeden önce doğrula.** `_kaydet` metodunun başına tek satır eklendi:

```dart
void _kaydet() {
  if (!_formKey.currentState!.validate()) return;
  final ders = Ders(
    ad: _adController.text.trim(),
    haftalikSaat: int.parse(_saatController.text.trim()),
  );
  Navigator.pop(context, ders);
}
```

`validate()` formdaki her alanın `validator`'ını çalıştırır, hata mesajlarını alanların altında gösterir ve herhangi bir alan geçersizse `false` döner. O durumda `_kaydet` erken çıkar; `int.parse` hiç çalışmaz.

`int.parse` satırının hâlâ yerinde durduğuna dikkat et. Artık güvenli, çünkü bu satıra yalnızca `_saatDogrula` metnin 1–20 arası geçerli bir sayı olduğunu onayladıktan sonra gelinebiliyor.

---

## Adım 7 · Arayüzü tasarıma yaklaştır

**Slayt:** S18 · **Prompt:** PROMPT 9 · **Commit:** COMMIT 4 “Tasarıma yaklaştırma” · **Etiket:** `adim-7` · **Hash:** `b9f679e`

### Amaç ve neden

Tasarım görselini context olarak verip mevcut ekranla farkları buldurmak ve **yalnızca bir farkı**, kontrollü biçimde düzelttirmek.

Prompt'taki **"yalnızca ilkini düzelt"** ifadesi önemli. Agent birden fazla farkı aynı anda düzeltmeye çalışsaydı farkı okumak ve sonucu test etmek zorlaşırdı. Tek değişiklik, tek kontrol: kaydet, hot reload ile saniyeler içinde gör, beğenmezsen geri al.

### Kullanılan prompt

[prompts/Prompt_9_Tasarim.txt](prompts/Prompt_9_Tasarim.txt)

```text
design/screen1.png görselini mevcut Ders Listesi ekranıyla karşılaştır. Farkları en fazla 3 madde halinde listele, sonra yalnızca ilkini düzelt. Başka hiçbir şeyi değiştirme.
```

### Değişen dosyalar

```bash
git show --stat adim-7
```

| Dosya | Değişiklik |
|---|---|
| `lib/main.dart` | 4 ekleme, 3 silme |

### Kod açıklaması

Commit farkına göre düzeltilen fark durum renkleri. Flutter'ın hazır renk tonları yerine tasarım görselindeki renkler kullanıldı:

```diff
+  // Renkler design/screen1.png'den alındı.
   Color get _renk => switch (ders.durum) {
-    DersDurumu.normal => Colors.green.shade800,
-    DersDurumu.dikkat => Colors.orange.shade800,
-    DersDurumu.doldu => Colors.red.shade800,
+    DersDurumu.normal => const Color(0xFF2E7D32),
+    DersDurumu.dikkat => const Color(0xFFC05600),
+    DersDurumu.doldu => const Color(0xFFBA1A1A),
   };
```

`Color(0xFF2E7D32)` gibi değerler renkleri tam olarak tanımlar: `FF` opaklık, sonraki altı hane kırmızı, yeşil ve mavi bileşenleri. Eklenen yorum satırı, renklerin nereden geldiğini bir sonraki okura anlatıyor.

---

## Adım 8 · Refactoring ve inceleme

**Slayt:** S19 · **Prompt:** PROMPT 10–12 · **Commit:** COMMIT 5 “Refactoring” · **Etiket:** `adim-8` · **Hash:** `43dcec7`

### Amaç ve neden

Çalışan davranışı değiştirmeden kodu toparlamak ve ardından projeyi ikinci bir agent'a (Codex) inceletip bulguları tek tek değerlendirmek.

Slayttaki tanım: **Refactoring, çalışan davranışı değiştirmeden kodu toparlamaktır.** PROMPT 10'daki "Bitince flutter analyze çalıştır" cümlesi, toparlamanın yeni bir uyarı ya da hata getirmediğini agent'ın kendisine kontrol ettiriyor.

PROMPT 11'de projeyi kodu yazan agent'tan farklı bir agent'a inceletiyoruz ve kod değiştirmesini yasaklıyoruz. Her bulguyu körü körüne uygulamıyoruz; slayta göre Codex'in üç bulgusu şöyle değerlendirildi:

1. Sıfıra bölme riski kabul edildi.
2. Gereksiz katman önerisi reddedildi.
3. Eksik kenar durumu sonraki tura not edildi.

Kararı veren yine sensin. PROMPT 12 ise kabul edilen bulguyu, Adım 7'deki gibi tek ve sınırlı bir değişiklikle düzelttiriyor.

<!-- TODO: COMMIT 5'in farkında, kabul edilen "sıfıra bölme" bulgusu için ayrı bir kod değişikliği görünmüyor (ilerleme çubuğundaki `ders.kullanilan / ders.hak` ifadesi aynı kaldı). PROMPT 12 ile yapılan düzeltmenin hangi commit'te olduğu ya da hiç commit'lenip commit'lenmediği netleştirilmeli. -->

### Kullanılan prompt'lar

**PROMPT 10 (refactoring):** [prompts/Prompt_10_Refactoring.txt](prompts/Prompt_10_Refactoring.txt)

```text
Davranışı değiştirmeden refactoring yap: ders kartını ayrı bir dosyada CourseCard adlı bir widget'a taşı ve modeldeki durum hesabını okunur hale getir. Yeni paket veya katman ekleme. Bitince flutter analyze çalıştır.
```

**PROMPT 11 (ikinci göz):** [prompts/Prompt_11_Codex_Inceleme.txt](prompts/Prompt_11_Codex_Inceleme.txt)

```text
Bu projeyi AGENTS.md'ye göre incele. En önemli 3 bulguyu önem sırasıyla yaz; her biri için neden önemli olduğunu bir cümleyle açıkla. Kod değiştirme.
```

**PROMPT 12 (tek bulguyu düzelt):** [prompts/Prompt_12_Bulgu_Duzeltme.txt](prompts/Prompt_12_Bulgu_Duzeltme.txt)

```text
Codex şu bulguyu verdi: [bulguyu buraya yapıştır]. Yalnızca bunu düzelt, başka hiçbir şeyi değiştirme. Bitince flutter analyze çalıştır.
```

### Değişen dosyalar

```bash
git show --stat adim-8
```

| Dosya | Değişiklik |
|---|---|
| `lib/course_card.dart` | 87 ekleme (yeni dosya) |
| `lib/main.dart` | 10 ekleme, 87 silme |

### Kod açıklaması

**Kartın taşınması.** `lib/main.dart` içindeki `DersKarti` sınıfı, içeriği aynı kalarak `lib/course_card.dart` dosyasına `CourseCard` adıyla taşındı. `main.dart`'tan 87 satır çıkıp `course_card.dart`'a 87 satır girmesi bunu doğruluyor. `main.dart` artık kartı içe aktarıyor:

```dart
import 'course_card.dart';
```

**Durum hesabının okunur hale gelmesi.** Koşullar isimli getter'lara çıkarıldı:

```diff
+  bool get hakDoldu => kullanilan >= hak;
+
+  // "kullanilan >= hak / 2" ile aynı; ×2 tek sayılı haklarda kesirli bölmeyi önler.
+  bool get yarisiKullanildi => kullanilan * 2 >= hak;
+
   DersDurumu get durum {
-    if (kullanilan >= hak) return DersDurumu.doldu;
-    if (kullanilan * 2 >= hak) return DersDurumu.dikkat;
+    if (hakDoldu) return DersDurumu.doldu;
+    if (yarisiKullanildi) return DersDurumu.dikkat;
     return DersDurumu.normal;
   }
```

Mantık birebir aynı; yalnızca okunuşu değişti. `durum` artık neredeyse cümle gibi okunuyor: "hak dolduysa doldu, yarısı kullanıldıysa dikkat, değilse normal."

---

## Adım 9 · Son tur

**Slayt:** S20 · **Prompt:** yok · **Commit:** yok

### Amaç ve neden

Geliştirme geçmişine bakıp her commit'in bir adıma, her adımın çalışan bir sürüme karşılık geldiğini görmek. Commit'ler eğitim boyunca birer kayıt noktası işlevi gördü: bir adımda işler ters giderse son commit'e dönmek her zaman mümkündü.

Bu adımda prompt yok; geçmişi doğrudan Git ile inceliyoruz. Eğitmen reposundaki `git log --oneline` çıktısı:

```text
43dcec7 Refactoring
b9f679e Tasarıma yaklaştırma
a16e659 Form doğrulaması
03935af Ders Listesi sayfası ve Ders ekleme sayfası
beecf44 Boş proje oluşturuldu.
```

<!-- TODO: Slayt S20'deki örnek çıktı 6 commit gösteriyor ("Liste ve sayaç" ile "Ders ekleme" ayrı commit'ler), S21'de de "6 commit" yazıyor. Repoda bu ikisi tek commit (03935af). Slayt mı güncellenecek, yoksa bu farka dair bir not mu eklenecek? -->

İki adım arasındaki kod farkını görmek için:

```bash
git diff adim-6 adim-7
```

### Değişen dosyalar

Bu adımda commit yok.

Slayttaki kapanış: **Sıradaki tur: verilerin kalıcı olması.** Bunun ve diğer alıştırmaların ayrıntısı [README](../README.md#ders-sonrası-alıştırmalar)'de.
