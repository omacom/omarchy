# Ekran Görüntüleri ve Kayıt

Ekranından koparabileceğin her şey Print Screen tuşuna bağlı. Tek başına bir tuş fotoğraf çeker; değiştiriciler ise kayıt, bir renk ya da bir bölgenin içindeki metni alır. Klavyende hiç Print Screen tuşu yoksa `Super + Ctrl + Alt + C` aynı ekran görüntüsünü çeker, `Super + Ctrl + C` ise tüm seti bir menü olarak açar.

| Kısayol | İşlev |
| ------ | -------- |
| `Print Screen` | Ekran görüntüsü |
| `Super + Ctrl + Alt + C` | Ekran görüntüsü |
| `Alt + Print Screen` | Ekran kaydı (veya çalışan kaydı durdur) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Bir bölgeden metin çıkar |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Super + Ctrl + .` | Bir resmi veya videoyu dönüştür |

## Ekran Görüntüleri

`Print Screen` (veya `Super + Ctrl + Alt + C`) tuşuna bas; Omasnap, katmanı belirmeden önce odaklanılan monitörü yakalar, böylece sen nişan alırken altında hiçbir şey kaymaz. Serbest biçimli bir bölge sürükle, yakalamak için bir pencereye tıkla ya da tüm monitörü yakalamak için boş alana tıkla. Kayan bir bölge yakalamak için çizmeden önce `S` tuşuna bas. Fikrini mi değiştirdin? Omasnap'i kapatmak için aynı tuşa tekrar bas.

Bir alan seçtikten sonra Omasnap yakalamayı kaydeder, panoya kopyalar ve kaydedilmiş bir ekran kaydında olduğu gibi küçük resmiyle birlikte bir bildirim gösterir. Kaydedilen görüntüyü resim görüntüleyicinde görüntülemek için Aç'ı, üzerine not eklemek için Düzenle'yi seç.

Not ekleme düzenleyicisi oklar, çizgiler, şekiller, vurgular, numaralı işaretler, metin ve güvenli sansürler çizebilir; resmin bir kısmını kırpabilir veya kesip çıkarabilir; metnini OCR ile çıkarabilir ve bir arka plan ekleyebilir. Düzenleyicide bitmiş PNG'yi kopyalayıp kaydetmek için `Enter`, kaydetmeden kopyalamak için `Ctrl + C` veya kopyalamadan kaydetmek için `Ctrl + S` tuşuna bas.

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` klasörüne, `screenshot-2026-08-13_14-22-05-firefox.png` gibi bir adla düşer. Başka bir dizin kullanmak için `OMASNAP_SCREENSHOT_DIR` değişkenini ayarla — oturum ortam değişkenlerini nereye koyacağını görmek için [SSS](46-faq.md) sayfasına bak. Omasnap ilk görüntüyü kaydettiğinde dizini oluşturur. Otomatik kaydetmeyi devre dışı bırakmak için `~/.config/omasnap/omasnap.conf` içinde `[output] autosave = false` ayarla; yakalamalar o zaman yalnızca kopyalanır ve 10 saniye boyunca bir önizlemede gösterilir, bunu raptiye düğmesiyle veya `Ctrl + P` ile ekranda tutabilirsin.

Terminalden `omarchy screenshot` aynı katmanı açar ve başlangıç modunu seçebilirsin: `omarchy capture screenshot region`, `windows`, `fullscreen` veya `scroll`. İkinci bir `copy` veya `save` argümanı görüntüyü doğrudan o hedefe gönderir. Çıktıdan önce düzenlemek için tam ekran bir düzenleyici için `omarchy screenshot --editor=overlay` veya ayrı bir pencere için `omarchy screenshot --editor=window` kullan.

### Seçiciyi klavyeden kullanmak

Seçim açıkken fareyi hiç kullanmak zorunda değilsin:

| Tuş | İşlev |
| --- | -------- |
| `S` | Kayan bölge modunu aç/kapat |
| `Super + Arrow keys` | Pencere modunda pencereler arasında gezin |
| `Return` | Vurgulanan pencereyi yakala |
| `Ctrl + A` | Odaklanılan monitörün tamamını yakala |
| `R` | Bu oturumda çizilen son bölgeyi geri getir |
| `Esc` | Omasnap'i kapat |

Bu bağlamalar yalnızca Omasnap açıkken var olur, dolayısıyla kendi yapılandırmanındaki hiçbir şeyle çakışamazlar.

## Ekran kaydı

`Alt + Print Screen`, film müziğinde ne istediğini soran _Trigger > Capture > Screenrecord_ menüsünü açar: ses yok, masaüstü sesi, masaüstü artı mikrofon veya masaüstü artı mikrofon artı web kamerası. Bu sonuncusu yalnızca gerçekten takılı bir kameran varsa görünür. Birini seç; Omarchy'nin kayıt seçicisi bir bölge sürüklemene ya da bir pencereye veya monitöre tıklamana izin verir.

Kayıt, 60fps'de GPU üzerinde kodlayan ve gerekirse CPU'ya geri düşen gpu-screen-recorder üzerinde çalışır. Sonuç, `screenrecording-2026-08-13_14-22-05.mp4` adıyla `~/Videos` içinde bir MP4 olur. Bunu değiştirmek için `OMARCHY_SCREENRECORD_DIR` değişkenini ayarla — ama şunu unutma: ekran görüntüsü dizininden farklı olarak bunun önceden var olması gerekir, yoksa kayıt başlamayı reddeder.

Kaydederken çubukta küçük bir gösterge belirir. Durdurmak için ona tıkla. Ayrıca `Alt + Print Screen` tuşuna tekrar basarak ya da yalnızca bir şey gerçekten kaydedilirken görünen _Trigger > Capture > Screenrecord_ altındaki _Stop Screenrecording_ girdisiyle de durdurabilirsin.

Durdurmak, dosyayı sana vermeden önce biraz toparlama yapar: ilk kare kırpılır ve ses varsa en baştaki PipeWire yakalama patlaması susturularak -14 LUFS'ye normalize edilir. Sonra kayıttan bir küçük resimle birlikte bir bildirim belirir. Dosyayı mpv içinde oynatmak için ona tıkla.

### Web kamerası katmanı

Web kamerasıyla kayıt yaptığında kamera, kaydettiğin şeyin sağ alt köşesinde sabitlenmiş, kırpılmış bir portre penceresi olarak görünür. İhtiyacın olan bir şeyin üzerinde duruyorsa anında yeniden boyutlandır:

| Kısayol | İşlev |
| ------ | -------- |
| `Super + Alt + [` | Web kamerası katmanını küçült |
| `Super + Alt + ]` | Web kamerası katmanını büyüt |

Üç boyut var — küçük, orta ve büyük — ve kısayollar aralarında adım adım gezinir. Varsayılan ortadır. Kayıtla orantılıdırlar, dolayısıyla ister 1080p bir monitörü ister 6K bir monitörü kaydet, kamera karenin aynı payını kaplar. Ve tüm bir ekran yerine bir bölge kaydettiysen katman monitörün köşesi yerine o bölgenin köşesine sabitlenir, böylece çekimin içinde kalır.

Ayrıca `omarchy-capture-webcam-resize small` ile doğrudan çağırabilir ya da ortaya dönmek için `reset` kullanabilirsin.

## Metin, QR kodları ve renkler

`Super + Ctrl + Print Screen` bir bölge seçer ve onu OCR ile panoya aktarır. Bu, [Metin Çıkarma ve Dikte](11-text-extraction-dictation.md) içinde düzgünce anlatılıyor.

_Trigger > Capture > QR Code_ aynı numara QR kodları için yapar. Kodu içeren bölgeyi seç; çözülen değer panoya gider. Yalnızca QR kodlarına bakar — yoğun ekran içeriğinin aksi halde barkod olarak yanlış pozitif verme huyu vardır. Bilmekte fayda var: çözülen değer panoya gider ve başka hiçbir yere gitmez. Yazdırılmaz, bildirimde yer almaz ve [pano geçmişi](08-unified-clipboard-history.md) içinde takılı kalmaması için hassas olarak işaretlenir. QR kodları rutin olarak sırlar taşır — örneğin bir 2FA kurulum kodunun arkasındaki `otpauth://` URI'si — ve bunu bir günlükte istemezsin. Yapıştırma yine de gayet iyi çalışır.

`Super + Print Screen` (veya _Trigger > Capture > Color_) imleci bir damlalığa dönüştürür. Ekrandaki herhangi bir şeye tıkla; renk panoya düşer. Seçmeden geri çıkmak için kısayola tekrar bas.

## Paylaşmadan önce dönüştürme

4K bir ekran kaydı veya telefonundan gelen ham bir HEIC çoğu zaman öylece göndermek için fazla büyüktür. `Super + Ctrl + .` (veya _Trigger > Transcode_) bunu çözer. Sana `~/Pictures` ve `~/Videos` üzerinde bulanık bir dosya seçici sunar, sonra bir format ve bir boyut sorar.

Resimler yüksek, orta veya düşük kalitede jpg veya png'ye gider; bunlar genişliği 3160, 2160 ve 1080 pikselde sınırlar. Videolar 4k, 1080p veya 720p'de mp4 veya animasyonlu bir gif'e gider. Dönüştürülen dosya, adında çözünürlükle birlikte orijinalin yanına yazılır — `demo-1080p.mp4` — ve yol, bir dosya URI'si olarak panoya kopyalanır, böylece onu dosya bırakmalarını kabul eden bir uygulamaya doğrudan yapıştırabilirsin.

Ne istediğini zaten biliyorsan terminalden de çalışır: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ayrıca bir resmi ASCII sanatına dönüştüren `omarchy transcode ascii` de var — o daha çok [markalama](41-branding.md) için.

## Bir yere gönderme

Dosyayı aldıktan sonra `Super + Ctrl + S`, Share menüsünü açar ve onu LocalSend aracılığıyla ağındaki başka bir cihaza gönderir. Bunun için [GUI'ler](22-guis.md) sayfasına bak.
