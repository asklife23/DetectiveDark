# DetectiveDark — Oyun Tasarımı

> Bu doküman oyunun **nasıl oynandığını** tanımlar ve mekanik kararların tek kaynağıdır.
> Hikaye metni (olay örgüsü, karakterler, diyaloglar) ayrıca yazılır.
> Durum: Taslak v1 — 2026-11-11. Her değişiklik en alttaki "Değişiklik geçmişi"ne tarih ve gerekçeyle yazılır.

---

## 1. Tek cümlede

Oyuncunun yönettiği bir dedektifin, noir bir atmosferde tek büyük bir vakayı 4 bölüm boyunca araştırdığı;
mekanları keşfedip eşya ve belge topladığı, bulmacalar çözdüğü ve sonunda polisi kanıtlarla ikna etmeye
çalıştığı, yatay ekranlı bir point-and-click oyun. **Platformlar:** Android, iOS ve Steam (Windows).

## 2. Temel ilkeler

1. **Kullanımı kolay, düşündüren bulmacalar.** Arayüz hiçbir zaman zorluk kaynağı değildir; zorluk yalnızca akıl yürütmededir.
2. **Tek yol.** Hikaye dallanmaz. Oyuncunun becerisi sonucu değil, çözüm hızını ve finaldeki başarıyı belirler.
3. **Önce atmosfer.** Karanlık, yağmur, sis, sessizlik, daktilo.
4. **Oyuncu asla çaresiz kalmaz.** Dedektifin iç sesi gerektiğinde yön gösterir.
5. **İzlenmeye uygun final.** İzleyen birinin de tahmin yürütüp tartışabileceği bir suçlama anı (yayıncılar, sosyal medya).

## 3. Oyuncu ve dedektif

- Oyuncu dedektifi yönetir. Bakış birinci şahıstır; dedektif ekranda görünmez.
- **Dedektifin iç sesi**, ekranın altındaki mesaj barından oyuncuya konuşur: gördüğüne yorum yapar,
  bulduğunu değerlendirir, oyuncu takıldığında ipucu verir.
- İç ses **tek yönlüdür**: oyuncu cevap yazmaz ve seçim yapmaz.
- Diğer karakterler görünmez. Şüpheliler not defterindeki dosyalarla (isim, fotoğraf veya silüet, notlar) tanınır.
  Gerekirse çok nadiren silüet kullanılır.

## 4. Temel döngü

**Keşfet → Topla → Çöz → İlerle**; her bölüm gerilimli bir kapanışla, vaka ise **Suçlama** ile biter.

- **Keşfet:** Mekanlara gir, yakın planlara bak.
- **Topla:** Eşyalar (kullanılır) ve belgeler/gözlemler (okunur, kanıt olur).
- **Çöz:** Eşyayı doğru yerde kullan, şifreyi kır, kaydı incele.
- **İlerle:** Yeni mekanlar ve yeni bölümler açılır.

## 5. Mekanikler

### 5.1 Sahneler
- Ana mekanlar ve onların yakın planları (çekmece, masa, kasa...). Hiyerarşiktir; yakın plandan Geri ile çıkılır.
- Geçişler zoom değildir: 150 ms kararma ve açılma. Ses efektiyle karanlık uzayabilir.
- Sahneler duruma göre görünüm değiştirir (kapı açık/kapalı, çekmece dolu/boş).

### 5.2 Eşyalar (sağ panel)
- Kullanılabilir nesneler: anahtar, levye, fener...
- Ekranın sağındaki panelde durur.
- **Kullanım:** Eşyaya dokun → seçili olur → sahnede hedefe dokun.
- Doğru yerde kullanılınca etki olur (kapı açılır). Yanlış yerde dedektif kısa bir yorum yapar; ceza yoktur.
- Bazı eşyalar kullanılınca tükenir (anahtar kilitte kalır), bazıları elde kalır (fener).
- Uzun basınca inceleme penceresi açılır (bkz. 5.8).

### 5.3 Not defteri
- Okunan şeyler üç bölümde toplanır:
    - **Belgeler:** mektup, gazete kupürü, fiş, fotoğraf.
    - **Gözlemler:** dedektifin çıkarımları ("Saat 23:40'ta ışıklar söndü").
    - **Şüpheliler:** her şüphelinin dosyası.
- HUD'daki defter düğmesiyle açılır; yeni not geldiğinde rozet görünür.
- Bulmacaların cevapları çoğu zaman buradadır; finalde kanıtlar buradan seçilir.

### 5.4 Bulmacalar
- **Eşya kullanma:** anahtar → kapı.
- **Şifre ve kilit:** rakamlı tuş takımı, döner kombinasyon kilidi, saat kadranı, harf kilidi.
- **Kayıt inceleme:** güvenlik kamerası veya kaset gibi bir kaydı izleyip içinden bilgi çıkarmak
  (ör. kayıttaki saatler → kasanın şifresi). Biçim (kare dizisi + ses ya da gerçek video) sanat yönüyle kararlaştırılır.
- Bulmacalar zincir kurar: kayıttaki saat → kasa şifresi → kasadaki mektup → yeni şüpheli.
- **Kural:** Her bulmacanın cevabı oyun içinde adil biçimde bulunabilir olmalıdır.

### 5.5 İpucu sistemi
- Uzun süre ilerleme olmazsa dedektif kendiliğinden hafifçe yönlendirir.
- Oyuncu istediğinde **kademeli ipucu** alır:
    1. Yön ("Holdeki saat garip duruyor.")
    2. Net ("Saatin gösterdiği zaman bir şifre olabilir.")
    3. Cevap
- İpuçlarının ücretli veya reklamlı olup olmayacağı para kazanma aşamasında kararlaştırılır.

### 5.6 Final: Suçlama
- Vaka sonunda **7 şüpheli** vardır.
- Oyuncu polise bir **isim** ve onu destekleyen **2–3 kanıt** (not defterinden) sunar.
- Doğru isim + yeterli kanıt → tutuklama, doğru son.
- Yanlışsa polis ikna olmaz; **1 hak daha** verilir.
- İkinci deneme de yanlışsa iki seçenek sunulur: **Vakayı baştan oyna** veya **Doğru cevabı ve çözümü gör**.
- **Sonuç ekranı:** kaç denemede çözüldüğü, toplam süre, kullanılan ipucu sayısı. Paylaşılabilir.

### 5.7 Girdi: dokunma ve fare
- Mobilde dokunma, PC'de fare. İkisi de aynı etkileşimi tetikler; oyun mantığı hiçbir zaman fareyle üzerine
  gelmeye (hover) bağlı değildir, çünkü mobilde hover yoktur.
- PC'de fare imlecinin hotspot üzerinde değişip değişmeyeceği açık sorudur. Tür standardı imlecin değişmesidir;
  ama bu, PC'deki oyunu mobile göre kolaylaştırır.
- PC'de klavye kısayolları: `Esc` geri / menü; ileride eşya ve not defteri için kısayollar.

### 5.8 İnceleme penceresi
- Bazı ayrıntılar ayrı bir yakın plan sahnesi gerektirmez: duvardaki saat, heykelin plaketi, bir fotoğrafın arkası.
  Bunlara dokununca sahne değişmez; sahnenin üstünde küçük bir **inceleme penceresi** açılır: bir görsel ve kısa bir metin.
- Sahne ve Geri yığını değişmez. Pencerenin dışına dokunmak, kapat düğmesi veya Geri onu kapatır.
- Yakın plan sahnesinden farkı: pencerede dokunulacak nokta yoktur, sadece bakılır. İçinde etkileşim gereken
  yerler (çekmece, kasa) yakın plan sahnesi olarak kalır.
- İnceleme tek başına bir şey toplamaz. Gerekirse aynı dokunuşla bir not da eklenir (mektubu oku + belgelere ekle).
- Envanterdeki bir eşyaya uzun basınca açılan kart da aynı penceredir.

## 6. Yapı ve süre

| Bölüm | Süre | Rolü |
|---|---|---|
| 1 | 30–45 dk | **Ücretsiz.** Yüksek gerilim; vakayı kurar ve merak uyandıran bir kapanışla biter. |
| 2 | 45–60 dk | Ücretli bölümlerin başlangıcı. |
| 3 | 45–60 dk | |
| 4 | 45–60 dk | Final ve suçlama. |

Toplam yaklaşık 3–4 saat. **Vaka 2** ileride ayrı ve ücretli çıkar.

## 7. Platformlar ve para kazanma (taslak)

Aynı oyun ve aynı içerik her platformda çalışır; yalnızca satış biçimi ve kayıt yöntemi platforma göre değişir.

### 7.1 Mobil (Android, iOS)
- Bölüm 1 ücretsizdir.
- Bölüm 1 sonunda tek bir satın alımla Vaka 1'in kalan bölümleri açılır.
  (Öneri: bölüm bölüm satmak yerine tek seferde. "Her bölüm için tekrar ödeme" hissi kötü yorum getirir.)
- Vaka 2 ayrı bir satın alımdır.
- İpucu ve reklam modeli ile fiyat para kazanma aşamasında kararlaştırılır.
- İlerleme ve satın alımlar hesapla birlikte korunur (silip yükleyince geri gelir).

### 7.2 Steam (Windows)
- **Demo:** Bölüm 1, Steam'de ayrı ve ücretsiz bir demo olarak yayınlanır (Steam Next Fest'e katılım dahil).
  Mobildeki "ücretsiz Bölüm 1" ile aynı içerik, Steam'in alışılmış biçiminde.
- **Tam oyun:** Vaka 1, peşin ücretli tek bir oyun olarak satılır.
- **Vaka 2:** DLC olarak satılır.
- Steam'de reklam yoktur.
- İlerleme Steam Cloud ile korunur; ayrı bir hesap gerekmez.
- Mağaza sayfası çıkıştan aylar önce açılır; istek listesi (wishlist) toplamak zaman ister.

### 7.3 Platformlar arası
- İlerleme ve satın alımlar platforma bağlıdır; mobil ile Steam arasında taşınmaz.
  Mağaza kuralları bunu zaten zorlaştırır, ayrıca sistem sade kalır.

## 8. İçerik ölçeği

- **Tahmin (kesin değil; hikaye yazılırken belirlenir):** Bölüm başına 8–12 ana mekan + 20–40 yakın plan.
  İnceleme pencereleri (5.8), yalnızca bakılan ayrıntılar için yakın plan ihtiyacını azaltır. Bölüm 1 için ~40–50 sahne, Vaka 1 için ~150–200 görsel.
- **Kodda sahne sayısı sınırı yoktur.** Motor veri odaklıdır; yeni sahne yeni veri ve görsel demektir, yeni kod değil.
  Asıl iş sanat üretimidir.
- **Üretim ipucu:** Yakın planlar, ana mekanın yüksek çözünürlüklü görselinden kırpılıp detay eklenerek üretilebilir.
  Bu hem tutarlılık hem hız sağlar.

## 9. Ton ve sunum

- **Görsel:** Noir; gece, yağmur, sis, sokak lambası ve neon ışıkları, soluk renkler, film greni.
- **Tipografi:** Başlıklar daktilo, gövde okunaklı.
- **Ses:** Yağmur, uzak trafik, caz ve ambiyans; geçişlerde efektler.
- **Kullanım:** Mobilde yatay, tam ekran, tek elle rahat dokunuşlar. PC'de pencere veya tam ekran, fare ve klavye.
- **Görsel çözünürlük:** PC'nin büyük ekranları düşünülerek üretilir; mobil için küçültülmüş sürümler kullanılır.
- **Görsel üretimi:** Görseller yapay zekâ destekli üretilir, ardından elle düzenlenir (temizlik, kırpma, tutarlılık).
  Yazılı bir stil rehberi (palet, ışık, dönem, kompozisyon) bütün görselleri aynı dünyaya bağlar.
- **Yazı ve sayılar oyun tarafından çizilir:** Bulmaca için kritik ya da okunması gereken yazı ve sayılar (saat, şifre,
  mektup metni, tabela) görsele gömülmez; oyun bunları görselin üstüne çizer. Yapay zekâ yazıyı çoğu zaman bozuk
  üretir; ayrıca cevabın her zaman net okunması adil bulmaca kuralının (5.4) gereğidir. Bu yazılar da çevrilebilir.
- **Ortak noir filtre:** Tüm sahne ve inceleme görsellerine aynı film greni, vinyet ve renk tonu uygulanır. Farklı
  zamanlarda üretilmiş görseller bu katman sayesinde tek bir filmden çıkmış gibi görünür. Oyunun çizdiği yazılar
  filtrenin altında kalır ki görsele kaynaşsın, ama her zaman okunur.
- **Açıklık:** Steam, yapay zekâ ile üretilmiş içeriğin mağaza sayfasında açıklanmasını ister. Hangi görselin nasıl
  üretildiği üretim sırasında kayıt altına alınır.
- **Dil:** İlk çıkışta oyun yalnızca **İngilizce**dir. Türkçe ve diğer diller sonradan eklenebilir; altyapı hazırdır
  (yeni dil = yeni metin dosyaları). Bu yüzden fontlar Latin Extended karakterleri (ç, ğ, ş, ı, ä, ñ...) destekler.
  Görsellere metin gömülmez (tabela, belge başlığı gibi okunması gereken yazılar metin katmanı olarak eklenir);
  böylece yeni dil yeni görsel gerektirmez.

## 10. Açık sorular

| Konu | Ne zaman |
|---|---|
| Kayıt inceleme biçimi: kare dizisi mi, video mu? | Bulmaca aşaması |
| İsim doğru ama kanıt yetersizse hak düşer mi? (Öneri: düşer; polis "kanıtlar zayıf" der.) | Bulmaca aşaması |
| 50+ sahnede yön bulma: harita veya mekan listesi gerekli mi? | İçerik aşaması |
| İpucu/reklam modeli ve mobil fiyat | Para kazanma aşaması |
| Steam fiyatı; başarımlar olacak mı? | Steam aşaması |
| PC'de imleç hotspot üzerinde değişsin mi? | Steam aşaması |
| Steam Deck (kontrolcü) ve macOS desteği | Steam çıkışından sonra |
| Vaka 2 dağıtımı: uygulama güncellemesi mi, sonradan indirilen içerik mi? | Yayın sonrası |
| Şehir, dönem, dedektifin kimliği, kurban, şüpheliler | Hikaye yazımı |

## Değişiklik geçmişi

- 2026-11-11: İlk taslak.
- 2026-11-11: Steam (Windows) platform olarak eklendi: Bölüm 1 demo, Vaka 1 peşin ücretli, Vaka 2 DLC; Steam Cloud ile kayıt.
- 2026-11-11: Dil kararı: ilk çıkış yalnızca İngilizce (önceki karar TR + EN idi). Gerekçe: global pazara tek dille
  daha hızlı çıkmak ve her metni iki dilde yazma yükünü içerik üretimi boyunca taşımamak. Yerelleştirme altyapısı
  ilk günden kurulur; Türkçe ve diğer diller sonradan dosya ekleyerek gelir.
- 2026-11-11: İnceleme penceresi (5.8) eklendi; görseller yapay zekâ destekli üretilecek; kritik yazı ve sayılar
  görsele gömülmez, oyun tarafından çizilir; tüm görsellere ortak noir filtre. Gerekçe: yalnızca bakılan ayrıntılar
  için sahne sayısını ve gezinmeyi azaltmak; AI'nın bozuk yazı üretmesine karşı bulmaca cevaplarını güvenceye almak;
  farklı zamanlarda üretilen görselleri tek bir görünümde birleştirmek. Sahne sayısı hikaye yazılırken belirlenecek.
  (ADR 0010, 0011)
