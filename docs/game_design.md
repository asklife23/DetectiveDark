# DetectiveDark — Oyun Tasarımı

> Bu doküman oyunun **nasıl oynandığını** tanımlar ve mekanik kararların tek kaynağıdır.
> Hikaye metni (olay örgüsü, karakterler, diyaloglar) ayrıca yazılır.
> Durum: Taslak v2 — 2026-11-15. Her değişiklik en alttaki "Değişiklik geçmişi"ne tarih ve gerekçeyle yazılır.

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
- İç ses **tek yönlüdür**: oyuncu cevap yazmaz. İç ses oyuncuya soru sormaz, oyuncu da ona bir şey söylemez.
- **Diğer karakterler sahnede silüet olarak görünür ve onlarla konuşulur** (bkz. 5.9). Sahnede yüzleri seçilmez;
  noir bir gölge, bir duruş. Konuşma kutusunda ve kişi dosyasında ise karakterin **çizilmiş portresi** görünür.
  Her karakterin not defterinde bir dosyası olur (isim, portre, öğrenilenler).
- **Villada hiç kimse yoktur** (silüet de yok). Villayla ilgili kişiler belgelerden ve başkalarının anlattıklarından
  tanınır. Silüetler yalnızca çarşı mekanlarındadır (bkz. 5.12).
- Konuşmada oyuncu yalnızca **önceden yazılmış soruları seçer**; serbest metin yazmaz. Hikaye dallanmaz: sorular
  yalnızca bilgi ortaya çıkarır, hiçbir soru bir yolu kapatmaz (ilke 2).
- Dedektifin karakterlere söylediği cümleler ekranda soru olarak görünür; duyduğu şey hakkındaki düşüncesi yine iç
  sesle, mesaj barından gelir.

## 4. Temel döngü

**Keşfet → Topla → Sorgula → Çöz → İlerle**; vaka **Suçlama** ile biter. Bölümler arasında oyun durmaz (bkz. 6).

- **Keşfet:** Mekanlara gir, yakın planlara bak; mekanlar arasındaki yolu sahnede bul (5.11).
- **Topla:** Eşyalar (kullanılır) ve belgeler/gözlemler (okunur, kanıt olur).
- **Sorgula:** Karakterlere soru sor, kanıt göster, eşya ver (5.9, 5.10). Söyledikleri kişi dosyalarına işlenir.
- **Çöz:** Eşyayı doğru yerde kullan, eşyaları birleştir, şifreyi kır, çelişkiyi yakala.
- **İlerle:** Yeni mekanlar, yeni kişiler ve yeni bölümler açılır.

## 5. Mekanikler

### 5.1 Sahneler
- Ana mekanlar ve onların yakın planları (çekmece, masa, kasa...). Hiyerarşiktir; yakın plandan Geri ile çıkılır.
- **Sahne kuralı: dokunulan her şey ayrı bir sahnedir**, yalnızca bakılan bir ayrıntı bile (duvardaki saat, bir
  plaket). Üç istisna vardır: **toplanan nesneler** (alınır, sahne açmaz), **geçiş noktaları** (başka bir mekana
  götürür) ve **karakterler** (konuşma panelini açar).
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
    - **Belgeler:** mektup, gazete kupürü, günlük (çok sayfalı), fotoğraf arkası. Hepsi deftere not olarak
      girer; çok sayfalı belgeler defterde sayfa sayfa çevrilir.
    - **Gözlemler:** dedektifin çıkarımları; yakalanan çelişkiler de buraya yazılır (5.10).
    - **Kişiler:** şüphelilerin ve tanıkların dosyaları. Kimin şüpheli olduğunu defter söylemez; o, finalde
      ortaya çıkar (5.6).
- **Dosyalar oyun ilerledikçe güncellenir:** bir karakterin söylediği önemli şey, dosyasına yeni bir satır olarak
  eklenir. Satır eklenen dosya yeniden "okunmamış" olur.
- HUD'daki defter düğmesiyle açılır; yeni not geldiğinde veya bir dosya güncellendiğinde rozet görünür.
- Bulmacaların cevapları çoğu zaman buradadır; finalde kanıtlar buradan seçilir.

### 5.4 Bulmacalar
Bulmaca türleri (hepsi dokunmayla, sürüklemesiz oynanır):
- **Eşya kullanma:** anahtar → kapı.
- **Eşya birleştirme:** iki eşya bir araya gelince yeni bir eşya veya bilgi çıkar.
- **Rakamlı tuş takımı:** şifreli kilit. Başka kilit türleri (döner kilit, harf kilidi...) yalnızca hikaye isterse eklenir.
- **Sembol eşleştirme:** bir yerde görülen sembollerin başka bir yerdeki karşılığını bulmak. Ayrı bir arayüzü
  yoktur; içerikle kurulur.
- **Karanlık sahnede ışık kaynağı:** karanlık bir sahnede bir şey görmek için ışık kaynağı (fener, lamba) kullanmak.
- **Yön bulmacası:** birkaç nesnenin yönünü bir metindeki tarife göre ayarlamak.
- **Delikli kağıt:** delikli bir şablon seçilip hedef yazıya dokunulur; yalnızca deliklerin altında kalan yazı
  okunur. Şablon sürüklenmez.
- **Çelişki yakalama:** bir karakterin söylediğiyle çelişen kanıtı ona göstermek (5.10).
- **Kayıt inceleme (yalnızca hikaye isterse):** döneme uyar; güvenlik kamerası yoktur. Gerekirse makaralı ses bandı
  veya film şeridi incelenir.

Kurallar:
- Bulmacalar zincir kurar: bir belgedeki ipucu → kasa şifresi → kasadaki mektup → yeni bir kişi.
- Her bulmacanın cevabı oyun içinde adil biçimde bulunabilir olmalıdır.
- **Zaman baskısı yoktur:** hiçbir bulmaca süreye bağlı değildir (bkz. 9, "Ortam").

### 5.5 İpucu sistemi
- Uzun süre ilerleme olmazsa dedektif kendiliğinden hafifçe yönlendirir.
- Oyuncu istediğinde **kademeli ipucu** alır:
    1. **Dokunulabilir yerleri göster:** sahnedeki dokunulabilir yerler kısa süre işaretlenir.
    2. Yön ("Holdeki saat garip duruyor.")
    3. Net ("Saatin gösterdiği zaman bir şifre olabilir.")
    4. Cevap
- **İpuçları sınırsız ve ücretsizdir.** İki ipucu arasında kısa bir bekleme vardır (öneri: 60 sn); bekleme, ipucunu
  düşünmeden art arda açmayı frenler, başka hiçbir şeyi kısıtlamaz.
- Kullanılan ipucu sayısı sonuç ekranında görünür (5.6).
- Reklam yoktur; ipucu satılmaz (bkz. 7.1).

### 5.6 Final: Suçlama
- Suçlama **karakolda** yapılır.
- Vaka sonunda **9 şüpheli** vardır. Tanıkların da defterde dosyası olur, ama suçlama ekranında yalnızca
  şüpheliler görünür.
- Oyuncu polise bir **isim** ve onu destekleyen **2–3 kanıt** (not defterinden) sunar.
- Doğru isim + yeterli kanıt → tutuklama, doğru son.
- Yanlışsa polis ikna olmaz; **1 hak daha** verilir (toplam 2 hak).
- İkinci deneme de yanlışsa iki seçenek sunulur: **Baştan oyna** veya **Çözümü gör**.
- **Kaçırılabilen kanıt yoktur:** önemli her kanıt ilerlemek için zorunludur. Suçlamaya gelen oyuncunun defterinde
  gereken bütün kanıtlar bulunur; zorluk onları bulmakta değil, doğru olanları seçmektedir.
- **Sonuç ekranı:** kaç denemede çözüldüğü, toplam süre, kullanılan ipucu sayısı. Paylaşılabilir.

### 5.7 Girdi: dokunma ve fare
- Mobilde dokunma, PC'de fare. İkisi de aynı etkileşimi tetikler; oyun mantığı hiçbir zaman fareyle üzerine
  gelmeye (hover) bağlı değildir, çünkü mobilde hover yoktur.
- PC'de fare imlecinin hotspot üzerinde değişip değişmeyeceği açık sorudur. Tür standardı imlecin değişmesidir;
  ama bu, PC'deki oyunu mobile göre kolaylaştırır.
- PC'de klavye kısayolları: `Esc` geri / menü; ileride eşya ve not defteri için kısayollar.

### 5.8 İnceleme penceresi
- Sahnenin üstünde açılan küçük bir pencere: bir görsel ve kısa bir metin. Sahne ve Geri yığını değişmez.
  Pencerenin dışına dokunmak, kapat düğmesi veya Geri onu kapatır. Pencerede dokunulacak nokta yoktur, sadece bakılır.
- **Gerçek içerikte yalnızca eşya kartı için kullanılır:** envanterdeki bir eşyaya uzun basınca açılan kart bu
  penceredir. Sahnedeki ayrıntılar (saat, plaket, fotoğraf) pencereyle değil, kendi sahneleriyle gösterilir (5.1).
- Motor, sahnedeki bir noktadan da bu pencereyi açabilir ve dikey dilimdeki heykel plaketi öyle kalır; bu yetenek
  silinmedi, yalnızca gerçek içerikte kullanılmıyor.

### 5.9 Konuşma
- Karakter sahnede bir silüettir. Dokununca konuşma paneli **doğrudan** açılır; arada "Konuş" adımı yoktur.
- Panelde karakterin adı, portresi, karşılama cümlesi ve **soru listesi** bulunur. İlk karşılaşmada ve sonraki
  gelişlerde karşılama cümlesi farklıdır.
- Soruya dokununca karakter cevap verir. Cevap satır satır, daktilo efektiyle gelir: dokunuş yazılan satırı hemen
  tamamlar, bir dokunuş daha sonraki satıra geçer; son satırdan sonra soru listesine dönülür.
- Sorulmuş soru işaretlenir ve **yeniden okunabilir**; ikinci kez sorunca yalnızca cevap tekrar okunur, oyunda
  başka bir şey değişmez. Henüz sorulmamış soru "yeni" etiketi taşır.
- Bazı sorular baştan görünmez; bir şey bulunduğunda veya öğrenildiğinde belirir (ilaç şişesi eldeyken "İlacı sor").
  **Bir kez sorulan soru, onu açan koşul sonradan bozulsa bile listede kalır.**
- Sahnedeki silüette "yeni soru var" işareti **yoktur**: kime neyi soracağını düşünmek oyunun parçasıdır.
- Önemli cevaplar karakterin dosyasına satır olarak işlenir (5.3). Konuşmanın dökümü mesaj geçmişine yazılmaz;
  orası yalnızca dedektifin iç sesidir.
- Panel açıkken sahneye dokunulamaz; Geri (sistem geri tuşu ve `Esc` dahil) önce paneli kapatır.
- Telefonda dört soru kaydırmadan görünür; fazlası kaydırılır.
- **Telefonla konuşma:** sahnedeki bir telefona dokununca aynı konuşma paneli açılır (hattın ucundaki kişinin
  portresiyle). Numara çevirme yoktur; kimin aranacağını telefonun kendisi belirler.

### 5.10 Kanıt gösterme ve eşya verme
- Karakterlere **eşya** ve **not** gösterilebilir. Doğru şeyi doğru kişiye göstermek yeni bir cevap açar; o cevap
  sonra soru listesinde sorulmuş olarak kalır ve yeniden okunabilir.
- **Eşya göstermek:** sahnede eşyayı seçip karaktere dokun (panel açılır ve eşya gösterilir) ya da panel açıkken
  sağ paneldeki eşyaya bir kez dokun.
- **Not göstermek:** paneldeki "Kanıt göster" düğmesi defteri seçim modunda açar; nottaki "Göster" düğmesiyle seçilir.
  Notlar yalnızca kişilere gösterilir; sahnedeki nesnelerde not kullanılmaz.
- **Vermek**, göstermenin bir sonucudur: karakter eşyayı alırsa eşya panelden düşer (ilaç şişesi eczacıda kalır).
- İlgisiz bir şey gösterilince karakter kısa, ilgisiz bir cevap verir. **Ceza yoktur**; yanlış deneme kaydedilmez.
- **Çelişki yakalama** yeni bir arayüz değildir: oyuncu, bir karakterin söylediğiyle çelişen kanıtı konuşmada
  "Kanıt göster" ile o karaktere gösterir. Karakterin cevabı ve dedektifin gözlem notu çelişkiyi kayda geçirir;
  o gözlem notu finalde kanıt olarak seçilebilir.

### 5.11 Mekanlar arası geçiş
- **Harita ve mekan listesi yoktur.** Bir mekandan diğerine yalnızca sahnedeki geçiş noktalarıyla gidilir: yol
  tabelası, bahçe kapısı, çıkış. Yolu bulmak keşfin parçasıdır.
- Yeni mekanlar hikayeyle açılır: mektup okununca villanın önünde çarşıyı gösteren tabela belirir.
- Bir mekana varıldığında Geri butonu görünmez (mekanın ana sahnesi bir yakın plan değildir); geri dönmek için
  sahnedeki dönüş noktası kullanılır. Yakın planlarda Geri her zaman bir üst sahneye döner.
- Oyuncu hiçbir mekanda mahsur kalmaz: her mekandan bölümün başladığı yere dönen bir yol vardır; her iç mekanın
  ana sahnesinde bir çıkış bulunur.
- Tabela ve yön yazıları oyun tarafından çizilir (bkz. 9, "Yazı ve sayılar"), bu yüzden çevrilebilir.

### 5.12 Mekanlar
Hangi odanın ve dükkanın hangi bölümde açıldığı hikayeyle belirlenir.

- **Villa** (içinde kimse yoktur):
    - **Giriş holü:** solda iki, sağda iki oda kapısı; karşıda bodrum kapısı; sağ ileride üst kata çıkan merdiven.
    - **Üst kat:** iki oda ve banyo; tavanda çatı kapağı → katlanır merdiven → **çatı katı**.
    - **Bodrum** ve **bahçe**.
- **Çarşı:** tek kaçış noktalı (perspektifi dibe doğru daralan) bir sokak; iki yanda dükkanlar, dipte yetimhane.
  Dükkanlara kapılarından girilir; karakterler içeridedir.
- **Karakol:** suçlamanın yapıldığı yer (5.6).

## 6. Yapı ve süre

| Bölüm | Süre | Rolü |
|---|---|---|
| 1 | 30–45 dk | **Ücretsiz.** Yüksek gerilim; vakayı kurar ve güçlü bir kapanışla biter. |
| 2 | 45–60 dk | Ücretli bölümlerin başlangıcı. |
| 3 | 45–60 dk | |
| 4 | 45–60 dk | Final ve suçlama. |

Toplam yaklaşık 3–4 saat. **Vaka 2** ileride ayrı ve ücretli çıkar.

**Bölüm geçişi:** Bir bölüm bitince oyun **durmaz**; ekranın üstünde kısa bir bildirim çıkar
("Bölüm 1 tamamlandı — <bölümün adı>") ve oyuncu oynamaya devam eder. Ayrı bir bölüm sonu ekranı yoktur.

**Tek istisna Bölüm 1'in sonudur:** mobilde Bölüm 2–4 için **tek satın alım ekranı**, Steam demosunda **demo sonu
ekranı** çıkar. Bölüm 1 bu yüzden güçlü bir kapanışla biter.

Yeni kişiler ve yeni mekanlar bölümle açılır (bkz. 9, "Ortam").

## 7. Platformlar ve para kazanma (taslak)

Aynı oyun ve aynı içerik her platformda çalışır; yalnızca satış biçimi ve kayıt yöntemi platforma göre değişir.

### 7.1 Mobil (Android, iOS)
- Bölüm 1 ücretsizdir.
- Bölüm 1 sonunda tek bir satın alımla Vaka 1'in kalan bölümleri açılır.
  (Öneri: bölüm bölüm satmak yerine tek seferde. "Her bölüm için tekrar ödeme" hissi kötü yorum getirir.)
- Vaka 2 ayrı bir satın alımdır.
- **Reklam yoktur ve ipucu satılmaz;** gelir yalnızca bölüm satışındandır (ipuçları ücretsiz: 5.5).
  Fiyat para kazanma aşamasında kararlaştırılır.
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

- **Tahmin (kesin değil; hikaye yazılırken belirlenir):** Bölüm başına 8–12 ana mekan + 20–40 yakın plan;
  Bölüm 1 için ~40–50 sahne, Vaka 1 için ~150–200 görsel. Bu tahmin sahne kuralından (5.1) önce yapıldı: yalnızca
  bakılan ayrıntılar da artık sahne olduğu için gerçek sayı daha yüksek çıkabilir; hikaye iskeletiyle güncellenir.
- **Kodda sahne sayısı sınırı yoktur.** Motor veri odaklıdır; yeni sahne yeni veri ve görsel demektir, yeni kod değil.
  Asıl iş sanat üretimidir.
- **Üretim ipucu:** Yakın planlar, ana mekanın yüksek çözünürlüklü görselinden kırpılıp detay eklenerek üretilebilir.
  Bu hem tutarlılık hem hız sağlar.

## 9. Ton ve sunum

- **Ortam:** 1950'ler, kurgusal küçük bir kasaba. **Oyun baştan sona gecedir.**
- **Saat veya zaman mekaniği yoktur:** oyun dünyasında hiçbir şey süreye bağlı değildir. Dükkanlar kapanmaz,
  karakterler yer değiştirmez, hiçbir fırsat kaçmaz. Dünya yalnızca oyuncunun yaptıklarıyla değişir; yeni kişiler
  ve mekanlar bölümle açılır.
- **Görsel:** Noir; gece, yağmur, sis, sokak lambası ve neon ışıkları, soluk renkler, film greni. Nesneler döneme
  uyar; güvenlik kamerası gibi dönem dışı nesne yoktur.
- **Tipografi:** Başlıklar daktilo, gövde okunaklı.
- **Ses:** Mekan başına bir ambiyans döngüsü (yağmur, rüzgar, barda uzaktan caz); kapı, adım ve gıcırtı efektleri.
  Müzik azdır.
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
- **Alınabilen nesneler ayrı görseldir:** Sahnede durup alınabilen nesneler (anahtar, mektup) arka plana çizilmez;
  şeffaf arka planlı küçük görseller olarak sahnenin üstüne yerleştirilir ve alınınca kaybolur. Böylece her sahne
  için tek arka plan yeter (nesneli / nesnesiz iki görsel gerekmez). Nesneler de noir filtrenin altında kalır.
- **Açıklık:** Steam, yapay zekâ ile üretilmiş içeriğin mağaza sayfasında açıklanmasını ister. Hangi görselin nasıl
  üretildiği üretim sırasında kayıt altına alınır.
- **Dil:** İlk çıkışta oyun yalnızca **İngilizce**dir. Türkçe ve diğer diller sonradan eklenebilir; altyapı hazırdır
  (yeni dil = yeni metin dosyaları). Bu yüzden fontlar Latin Extended karakterleri (ç, ğ, ş, ı, ä, ñ...) destekler.
  Görsellere metin gömülmez (tabela, belge başlığı gibi okunması gereken yazılar metin katmanı olarak eklenir);
  böylece yeni dil yeni görsel gerektirmez.

## 10. Açık sorular

| Konu | Ne zaman |
|---|---|
| Kayıt inceleme gerekecek mi; gerekirse makaralı ses bandı mı, film şeridi mi? (Hikaye istemezse ertelenir.) | Bulmaca aşaması |
| İsim doğru ama kanıt yetersizse hak düşer mi? (Öneri: düşer; polis "kanıtlar zayıf" der.) | Bulmaca aşaması |
| İki ipucu arasındaki bekleme süresi (öneri: 60 sn) | Bulmaca aşaması |
| Mobil fiyat | Para kazanma aşaması |
| Steam fiyatı; başarımlar olacak mı? | Steam aşaması |
| PC'de imleç hotspot üzerinde değişsin mi? | Steam aşaması |
| Steam Deck (kontrolcü) ve macOS desteği | Steam çıkışından sonra |
| Vaka 2 dağıtımı: uygulama güncellemesi mi, sonradan indirilen içerik mi? | Yayın sonrası |
| Kasabanın adı, dedektifin kimliği, olay örgüsü ve kişiler | Hikaye yazımı (bu belgeye yazılmaz) |

**Kapanan sorular:**
- 50+ sahnede yön bulma → harita ve mekan listesi yok; mekanlara sahnedeki geçiş noktalarıyla gidilir (5.11,
  2026-11-14). Oyun testinde (Bölüm 1) yollar uzun gelirse çözüm yeni bir geçiş noktasıdır, harita değil.
- Dönem ve ortam → 1950'ler, kurgusal küçük kasaba, hep gece (9, 2026-11-15).
- İpucu ve reklam modeli → ipuçları sınırsız ve ücretsiz, aralarında kısa bekleme; reklam yok (5.5, 7.1, 2026-11-15).
- Kayıt inceleme biçimi (kare dizisi mi, video mu) → soru değişti: güvenlik kamerası yok; gerekirse ses bandı veya
  film şeridi (5.4, 2026-11-15).

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
- 2026-11-14: Nesne katmanı eklendi: alınabilen nesneler arka plandan ayrı, şeffaf arka planlı görsellerdir. Gerekçe:
  alınan her nesne için ikinci bir tam sahne görseli üretmek (n nesnede 2ⁿ görsel) sanat bütçesini katlıyordu ve AI
  ile üretilen görsellerde tutarlılığı bozuyordu. (ADR 0012)
- 2026-11-14: `Esc` = Geri (5.7) Steam aşamasını beklemeden Aşama 1'de eklendi; menü kısayolu Steam aşamasında.
- 2026-11-14 (motor incelemesi, kullanıcı onaylı):
  - **Karakterler artık görünür ve onlarla konuşulur** (3, 5.9). Önceki kural "diğer karakterler görünmez" idi.
    Gerekçe: Bölüm 1 planlanırken, kimseyi sorgulamayan bir dedektifin her şeyi kağıttan öğrenmesi hem inandırıcı
    değildi hem de oyunu tekdüze yapıyordu. İç ses tek yönlü kalır; oyuncu yalnızca önceden yazılmış soruları seçer,
    hikaye dallanmaz. (ADR 0016)
  - **Kanıt gösterme ve eşya verme** (5.10): karakterlere eşya ve not gösterilir; yanlış denemenin cezası yoktur.
    Gerekçe: toplanan şeylerin sorguda da işe yaraması; "doğru şeyi doğru kişiye göster" yeni bir bulmaca türüdür ve
    yeni arayüz öğretmez (eşya paneli ve defter aynen kullanılır). (ADR 0016)
  - **"Şüpheliler" sekmesi "Kişiler" oldu; dosyalar güncellenir** (5.3). Gerekçe: tanıkların da dosyası olur; bir
    dosyaya "şüpheli" etiketi koymak oyuncuya kimin önemli olduğunu söylerdi. İfadeler dosyaya satır olarak eklenir.
    (ADR 0015)
  - **Mekanlar arası geçiş: harita yok** (5.11); 10'daki yön bulma sorusu kapandı. Gerekçe: harita, sahne yığınının
    yanında ikinci bir gezinme modeli, ayrı görsel ve kilit kuralı demekti; yolu sahnede bulmak keşfi güçlendirir.
    (ADR 0017)
  - Temel döngüye **Sorgula** eklendi (4).
- 2026-11-15 (tasarım kararları, kullanıcı onaylı; yalnızca mekanik, hikaye bu belgeye yazılmaz):
  - **Ortam** (9): 1950'ler, kurgusal küçük kasaba; oyun hep gecedir; **saat veya zaman mekaniği yok**. Gerekçe:
    süreye bağlı olaylar (kapanan dükkan, yer değiştiren karakter) oyuncuya bir şeyi kaçırma korkusu verir; "oyuncu
    asla çaresiz kalmaz" ilkesiyle ve tek yol hikayeyle çelişir. Sabit gece noir tonu korur ve aynı mekanın gündüz
    görselini gerektirmez.
  - **Sahne kuralı** (5.1, 5.8): dokunulan her şey ayrı sahnedir; istisnalar toplanan nesneler, geçiş noktaları ve
    karakterler. İnceleme penceresi gerçek içerikte yalnızca eşya kartı içindir. Önceki karar (2026-11-11) yalnızca
    bakılan ayrıntıları pencereyle gösteriyordu. Gerekçe: oyuncu için tek bir kural ("dokunursam oraya giderim").
    Bedeli daha çok sahne görselidir (8). Motor ve dikey dilim değişmez.
  - **Karakterler** (3, 5.9): villada kimse yok; silüetler yalnızca çarşı mekanlarında. Konuşma kutusunda ve kişi
    dosyasında **çizilmiş portre** (önceki karar: panelde ve dosyada da silüet). Gerekçe: boş villa yalnızlık ve
    gerilim verir; portre, kişileri akılda tutmayı ve finalde ayırt etmeyi kolaylaştırır. Telefonla konuşma aynı
    paneli kullanır; numara çevirme yok.
  - **Mekanlar** (5.12): villanın ve çarşının düzeni yazıldı; suçlama karakolda.
  - **Bölüm geçişi** (6): oyun durmaz, üstte kısa bildirim; ayrı bölüm sonu ekranı kalktı. Tek istisna Bölüm 1'in
    sonu (satın alma / demo sonu ekranı). Gerekçe: akışı kesen ekran yalnızca bir karar gerektiğinde çıkar.
  - **Suçlama** (5.6): 9 şüpheli (önceki karar 7); karakolda; kaçırılabilen kanıt yok. Gerekçe: finale eksik kanıtla
    gelip kaybetmek adil değildir; zorluk kanıtı seçmekte olmalı.
  - **Çelişki yakalama** (5.10): yeni arayüz yok, "Kanıt göster" ile. Gerekçe: oyuncu yeni bir arayüz öğrenmez;
    mevcut konuşma ve defter yeter.
  - **Bulmaca türleri** (5.4): liste kesinleşti (eşya kullanma ve birleştirme, rakamlı tuş takımı, sembol eşleştirme,
    ışık kaynağı, yön bulmacası, sürüklemesiz delikli kağıt). Döner kilit, saat kadranı ve harf kilidi yalnızca
    hikaye isterse. Kayıt inceleme döneme uyarlandı (güvenlik kamerası yok) ve hikaye istemezse yapılmaz.
  - **Belgeler** (5.3): mektup, gazete kupürü, çok sayfalı günlük, fotoğraf arkası.
  - **Yardım** (5.5, 7.1): ipuçları sınırsız ve ücretsiz, aralarında kısa bekleme; ilk kademe "dokunulabilir yerleri
    göster"; reklam yok, gelir yalnızca bölüm satışından. Gerekçe: ücretli ipucu veya reklam takılan oyuncuyu
    cezalandırır ve atmosferi böler.
  - **Ses** (9): mekan başına ambiyans döngüsü ve efektler; müzik az.
