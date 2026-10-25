# Ekran Görüntüleri ve Kayıt

Ekrandan kapabileceğiniz her şey Print Screen tuşuna dayanıyor. Tuş tek başına bir fotoğraf çeker ve değiştiriciler bir kayıt, bir renk veya bir bölgenin içindeki metni alır. Klavyenizde hiç Print Screen tuşu yoksa, `Super + Ctrl + Alt + C` aynı ekran görüntüsünü çeker ve `Super + Ctrl + C` tüm seti bir menü olarak açar.

| Kısayol Tuşu | İşlev |
| ------ | -------- |
| `Print Screen` | Ekran görüntüsü |
| `Super + Ctrl + Alt + C` | Ekran görüntüsü |
| `Alt + Print Screen` | Ekran kaydı (veya çalışanı durdurur) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Bir bölgeden metin çıkar |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Super + Ctrl + .` | Bir resmi veya videoyu dönüştür |

## Ekran Görüntüleri

`Print Screen` (veya `Super + Ctrl + Alt + C`) tuşuna basın ve Omasnap, kendi katmanı görünmeden önce odaklanılan monitörü yakalar, böylece siz nişan alırken hiçbir şey altınızda kaymaz. Serbest biçimli bir bölge sürükleyin, yakalamak için bir pencereye tıklayın veya tüm monitörü yakalamak için boş alana tıklayın. Kayan bir bölge yakalamak için çizmeden önce `S` tuşuna basın. Fikrinizi mi değiştirdiniz? Omasnap'i kapatmak için aynı tuşa tekrar basın.

Bir alan seçtikten sonra Omasnap yakalamayı kaydeder, panoya kopyalar ve 10 saniye boyunca bir önizleme gösterir. Ekranda tutmak için önizlemenin sabitleme düğmesini veya `Ctrl + P` tuşlarını kullanın ya da açıklama eklemek için Edit'i seçin.

Açıklama düzenleyici oklar, çizgiler, şekiller, vurgular, numaralı işaretler, metin ve güvenli karartmalar çizebilir; görüntünün bir kısmını kırpabilir veya kesip çıkarabilir; metnini OCR ile çıkarabilir; ve bir arka plan ekleyebilir. Düzenleyicide, bitmiş PNG'yi kopyalayıp kaydetmek için `Enter` tuşuna, kaydetmeden kopyalamak için `Ctrl + C` tuşlarına veya kopyalamadan kaydetmek için `Ctrl + S` tuşlarına basın.

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` içine, `screenshot-2026-08-13_14-22-05-firefox.png` gibi bir adla gider. Başka bir dizin kullanmak için `OMASNAP_SCREENSHOT_DIR` ayarını yapın — oturum ortam değişkenlerini nereye koyacağınız için [SSS'ye](46-faq.md) bakın. Omasnap, ilk çekimi kaydederken dizini oluşturur. Otomatik kaydetmeyi devre dışı bırakmak için `~/.config/omasnap/omasnap.conf` içinde `[output] autosave = false` ayarını yapın.

Terminalden, `omarchy screenshot` aynı katmanı açar ve başlangıç modunu seçebilirsiniz: `omarchy capture screenshot region`, `windows`, `fullscreen` veya `scroll`. `copy` veya `save` ikinci argümanı önizlemeyi atlar ve çekimi doğrudan o hedefe gönderir. Çıktıdan önce düzenlemek için, tam ekran bir düzenleyici için `omarchy screenshot --editor=overlay` veya ayrı bir pencere için `omarchy screenshot --editor=window` kullanın.

### Seçiciyi klavyeden kullanmak

Seçim açıkken, fareyi hiç kullanmak zorunda değilsiniz:

| Tuş | İşlev |
| --- | -------- |
| `S` | Kayan bölge modunu aç/kapat |
| `Super + Arrow keys` | Window modunda pencereler arasında gezin |
| `Return` | Vurgulanan pencereyi yakala |
| `Ctrl + A` | Odaklanılan monitörün tamamını yakala |
| `R` | Bu oturumda çizilen son bölgeyi geri getir |
| `Esc` | Omasnap'i kapat |

Bu bağlamalar yalnızca Omasnap açıkken var olur, bu yüzden kendi yapılandırmanızdaki hiçbir şeyle çakışamazlar.

## Ekran kaydı

`Alt + Print Screen`, film müziğinde ne istediğinizi soran _Trigger > Capture > Screenrecord_'u açar: ses yok, masaüstü sesi, masaüstü artı mikrofon veya masaüstü artı mikrofon artı webcam. Sonuncusu yalnızca gerçekten takılı bir kameranız varsa görünür. Birini seçin ve Omarchy'nin kayıt seçicisi bir bölge sürüklemenize veya bir pencereye ya da monitöre tıklamanıza izin verir.

Kayıt, GPU üzerinde 60fps'de kodlama yapan ve gerekirse CPU'ya geri dönen gpu-screen-recorder üzerinde çalışır. Sonuç, `~/Videos` içinde `screenrecording-2026-08-13_14-22-05.mp4` adında bir MP4'tür. Bunu değiştirmek için `OMARCHY_SCREENRECORD_DIR` ayarını yapın — ancak şunu unutmayın: ekran görüntüsü dizininden farklı olarak, bu dizinin zaten var olması gerekir, yoksa kayıt başlamayı reddeder.

Kaydederken çubukta küçük bir gösterge belirir. Durdurmak için üzerine tıklayın. Ayrıca `Alt + Print Screen` tuşlarına tekrar basarak veya yalnızca bir şey gerçekten kaydederken görünen, _Trigger > Capture > Screenrecord_ altındaki _Stop Screenrecording_ girişini kullanarak da durdurabilirsiniz.

Durdurmak, dosyayı size vermeden önce biraz temizlik yapar: ilk kare kırpılır ve ses varsa -14 LUFS'ye normalize edilir, en baştaki PipeWire yakalama patlaması sessize alınır. Ardından kayıttan bir küçük resim içeren bir bildirim belirir. Dosyayı mpv içinde oynatmak için üzerine tıklayın.

### Webcam katmanı

Bir webcam ile kayıt yaptığınızda, kamera kaydettiğiniz şeyin sağ alt köşesinde sabitlenmiş, kırpılmış bir portre penceresi olarak görünür. İhtiyacınız olan bir şeyin üzerinde duruyorsa, anında yeniden boyutlandırın:

| Kısayol Tuşu | İşlev |
| ------ | -------- |
| `Super + Alt + [` | Webcam katmanını küçült |
| `Super + Alt + ]` | Webcam katmanını büyüt |

Üç boyut vardır — küçük, orta ve büyük — ve kısayol tuşları bunlar arasında adım adım geçiş yapar. Orta varsayılandır. Bunlar kayda oranlıdır, bu yüzden 1080p bir monitör de 6K bir monitör de kaydetseniz kamera karenin aynı payını kaplar. Ve tüm bir ekran yerine bir bölge kaydettiyseniz, katman monitörün köşesi yerine o bölgenin köşesine tutunur, böylece çekimin içinde kalır.

Bunu doğrudan `omarchy-capture-webcam-resize small` ile de çağırabilir veya ortaya dönmek için `reset` kullanabilirsiniz.

## Metin, QR kodları ve renkler

`Super + Ctrl + Print Screen` bir bölge seçer ve onu OCR ile panoya alır. Bu, [Metin Çıkarma ve Dikte](11-text-extraction-dictation.md) içinde düzgünce ele alınıyor.

_Trigger > Capture > QR Code_ aynı numarayı QR kodları için yapar. İçinde kod olan bölgeyi seçin ve çözülen değer panoya gider. Yalnızca QR kodlarına bakar — yoğun ekran içeriği aksi halde yanlışlıkla bir barkod olarak algılanma huyuna sahiptir. Bilmekte fayda var: çözülen değer panoya gider ve başka hiçbir yere gitmez. Yazdırılmaz, bildirimde yer almaz ve [pano geçmişinde](08-unified-clipboard-history.md) takılı kalmaması için hassas olarak işaretlenir. QR kodları düzenli olarak sırlar taşır — örneğin bir 2FA kurulum kodunun arkasındaki `otpauth://` URI'si — ve bunu bir günlükte istemezsiniz. Yapıştırmak yine de gayet iyi çalışır.

`Super + Print Screen` (veya _Trigger > Capture > Color_) imleci bir damlalığa dönüştürür. Ekrandaki herhangi bir şeye tıklayın ve renk panoya düşer. Seçmeden geri çıkmak için kısayol tuşuna tekrar basın.

## Paylaşmadan önce dönüştürme

4K bir ekran kaydı veya telefonunuzdan ham bir HEIC genellikle öylece göndermek için çok büyüktür. `Super + Ctrl + .` (veya _Trigger > Transcode_) bunu düzeltir. Size `~/Pictures` ve `~/Videos` üzerinde bulanık bir dosya seçici sunar, ardından bir format ve bir boyut sorar.

Resimler yüksek, orta veya düşük kalitede jpg veya png'ye gider; bunlar genişliği 3160, 2160 ve 1080 pikselde sınırlar. Videolar 4k, 1080p veya 720p'de mp4'e veya hareketli bir gif'e gider. Dönüştürülen dosya, adında çözünürlükle birlikte orijinalin yanına yazılır — `demo-1080p.mp4` — ve yol bir dosya URI'si olarak panoya kopyalanır, böylece dosya bırakmayı kabul eden bir uygulamaya doğrudan yapıştırabilirsiniz.

Ne istediğinizi zaten biliyorsanız terminalden de çalışır: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Bir görüntüyü ASCII sanatına dönüştüren `omarchy transcode ascii` de vardır — bu daha çok [markalama](41-branding.md) içindir.

## Bir yere göndermek

Dosyayı aldıktan sonra, `Super + Ctrl + S` Share menüsünü açar ve onu LocalSend aracılığıyla ağınızdaki başka bir cihaza gönderir. Bunun için [GUIs](22-guis.md) bölümüne bakın.
