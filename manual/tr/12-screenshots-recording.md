# Ekran Görüntüleri ve Kayıt

Ekrandan alabileceğiniz her şey Print Screen tuşuna bağlıdır. Tek başına bir tuş fotoğraf çeker ve değiştiriciler bir kayıt, bir renk ya da bir bölgenin içindeki metni alır. Klavyenizde Print Screen tuşu hiç yoksa, `Super + Ctrl + Alt + C` aynı ekran görüntüsünü alır ve `Super + Ctrl + C` tüm seti bir menü olarak açar.

| Kısayol tuşu | İşlev |
| ------ | -------- |
| `Print Screen` | Ekran görüntüsü |
| `Super + Ctrl + Alt + C` | Ekran görüntüsü |
| `Alt + Print Screen` | Ekran kaydı (veya çalışanı durdur) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Bir bölgeden metin çıkar |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Super + Ctrl + .` | Bir resmi veya videoyu dönüştür |

## Ekran görüntüleri

`Print Screen` (veya `Super + Ctrl + Alt + C`) tuşuna basın; Omasnap, katmanı belirmeden önce odaklanılan monitörü yakalar, böylece siz nişan alırken hiçbir şey altınızda kaymaz. Serbest biçimli bir bölge sürükleyin, yakalamak için bir pencereye tıklayın veya monitörün tamamını yakalamak için boş alana tıklayın. Kaydırmalı bir bölge yakalamak için çizmeden önce `S` tuşuna basın. Fikrinizi mi değiştirdiniz? Omasnap'i kapatmak için aynı tuşa tekrar basın.

Bir alan seçtikten sonra Omasnap yakalamayı kaydeder, panoya kopyalar ve küçük resmiyle birlikte bir bildirim gösterir, tıpkı kaydedilmiş bir ekran kaydının yaptığı gibi. Kaydedilen görüntüyü resim görüntüleyicinizde görmek için Open'ı veya açıklama eklemek için Edit'i seçin.

Açıklama düzenleyicisi oklar, çizgiler, şekiller, vurgular, numaralı işaretler, metin ve güvenli karartmalar çizebilir; görüntünün bir bölümünü kırpabilir veya kesip çıkarabilir; metnine OCR uygulayabilir; ve bir arka plan ekleyebilir. Düzenleyicide, bitmiş PNG'yi kopyalayıp kaydetmek için `Enter` tuşuna, kaydetmeden kopyalamak için `Ctrl + C` tuşuna veya kopyalamadan kaydetmek için `Ctrl + S` tuşuna basın.

Kaydedilen ekran görüntüleri varsayılan olarak, `screenshot-2026-08-13_14-22-05-firefox.png` gibi bir adla `~/Pictures/Screenshots` konumuna gider. Başka bir dizin kullanmak için `OMASNAP_SCREENSHOT_DIR` değişkenini ayarlayın — oturum ortam değişkenlerini nereye koyacağınız için [SSS'ye](46-faq.md) bakın. Omasnap, ilk görüntüyü kaydettiğinde dizini oluşturur. Otomatik kaydetmeyi devre dışı bırakmak için `~/.config/omasnap/omasnap.conf` içinde `[output] autosave = false` ayarını yapın; yakalamalar o zaman yalnızca kopyalanır ve sabitleme düğmesiyle veya `Ctrl + P` ile ekranda tutabileceğiniz, 7 saniyelik bir önizlemede gösterilir.

Terminalden, `omarchy screenshot` aynı katmanı açar ve başlangıç modunu seçebilirsiniz: `omarchy capture screenshot region`, `windows`, `fullscreen` veya `scroll`. `copy` veya `save` biçimindeki ikinci bir argüman, görüntüyü doğrudan o hedefe gönderir. Çıktıdan önce düzenlemek için, tam ekran düzenleyici için `omarchy screenshot --editor=overlay` veya ayrı bir pencere için `omarchy screenshot --editor=window` kullanın.

### Seçiciyi klavyeden kullanmak

Seçim açıkken, fareyi hiç kullanmak zorunda değilsiniz:

| Tuş | İşlev |
| --- | -------- |
| `S` | Kaydırmalı bölge modunu aç/kapat |
| `Super + Arrow keys` | Pencere modunda pencereler arasında gezin |
| `Return` | Vurgulanan pencereyi yakala |
| `Ctrl + A` | Odaklanılan monitörün tamamını yakala |
| `R` | Bu oturumda çizilen son bölgeyi geri getir |
| `Esc` | Omasnap'i kapat |

Bu bağlamalar yalnızca Omasnap açıkken vardır, bu yüzden kendi yapılandırmanızdaki hiçbir şeyle çakışamazlar.

## Ekran kaydı

`Alt + Print Screen`, film müziğinde ne istediğinizi soran _Trigger > Capture > Screenrecord_ öğesini açar: ses yok, masaüstü sesi, masaüstü artı mikrofon veya masaüstü artı mikrofon artı web kamerası. Bu sonuncusu yalnızca gerçekten takılı bir kameranız varsa görünür. Birini seçin; Omarchy'nin kayıt seçicisi bir bölge sürüklemenize veya bir pencereye ya da monitöre tıklamanıza izin verir.

Kayıt, GPU üzerinde 60fps'de kodlama yapan ve gerekirse CPU'ya geri dönen gpu-screen-recorder üzerinde çalışır; Apple Silicon'ınki gibi desteklemediği GPU'larda Omarchy bunun yerine wf-recorder ile kayıt yapar. Sonuç, `screenrecording-2026-08-13_14-22-05.mp4` adlı, `~/Videos` içinde bir MP4'tür. Bunu değiştirmek için `OMARCHY_SCREENRECORD_DIR` değişkenini ayarlayın — ancak ekran görüntüsü dizininden farklı olarak, bunun önceden var olması gerektiğini, yoksa kaydın başlamayı reddedeceğini unutmayın.

Kayıt yaparken, çubukta küçük bir gösterge belirir. Durdurmak için ona tıklayın. Ayrıca tekrar `Alt + Print Screen` ile veya _Trigger > Capture > Screenrecord_ altındaki, yalnızca gerçekten bir şey kayıt yaparken görünen _Stop Screenrecording_ girdisiyle de durdurabilirsiniz.

Durdurmak, dosyayı size vermeden önce biraz temizlik yapar: ilk kare kırpılır ve ses varsa, en baştaki PipeWire yakalama patlaması susturulmuş olarak -14 LUFS'ye normalize edilir. Sonra kayıttan bir küçük resimle birlikte bir bildirim belirir. Dosyayı Omaview'de oynatmak için _Open_'ı veya Omacut'ta kırpmak için _Cut_'ı seçin.

### Web kamerası katmanı

Bir web kamerasıyla kayıt yaptığınızda, kamera kaydettiğiniz şeyin sağ alt köşesinde sabitlenmiş, kırpılmış bir portre penceresi olarak belirir. İhtiyacınız olan bir şeyin üstünde duruyorsa, anında yeniden boyutlandırın:

| Kısayol tuşu | İşlev |
| ------ | -------- |
| `Super + Alt + [` | Web kamerası katmanını küçült |
| `Super + Alt + ]` | Web kamerası katmanını büyüt |

Üç boyut vardır — küçük, orta ve büyük — ve kısayol tuşları bunlar arasında adım adım geçiş yapar. Orta varsayılandır. Kayıtla orantılıdırlar, bu yüzden ister 1080p bir monitör ister 6K bir monitör kaydediyor olun, kamera karenin aynı payını kaplar. Ve tüm bir ekran yerine bir bölge kaydettiyseniz, katman monitörün köşesi yerine o bölgenin köşesine sabitlenir, böylece çekimin içinde kalır.

Ayrıca doğrudan `omarchy-capture-webcam-resize small` ile veya ortaya geri dönmek için `reset` ile de çağırabilirsiniz.

## Metin, QR kodları ve renkler

`Super + Ctrl + Print Screen` bir bölge seçer ve onu panoya OCR'lar. Bu, [Metin Çıkarma ve Dikte](11-text-extraction-dictation.md) içinde düzgünce ele alınmıştır.

_Trigger > Capture > QR Code_ aynı numara QR kodları için yapılır. İçinde kod olan bölgeyi seçin; çözülen değer panoya gider. Yalnızca QR kodlarını arar — yoğun ekran içeriği, aksi takdirde barkod olarak yanlış pozitif verme huyuna sahiptir. Bilmekte fayda var: çözülen değer panoya gider ve başka hiçbir yere gitmez. Yazdırılmaz, bildirimde yoktur ve [pano geçmişinde](08-unified-clipboard-history.md) kalmaması için hassas olarak işaretlenir. QR kodları rutin olarak sırlar taşır — örneğin bir 2FA kurulum kodunun arkasındaki `otpauth://` URI'si — ve bunu bir günlükte istemezsiniz. Yapıştırmak yine de sorunsuz çalışır.

`Super + Print Screen` (veya _Trigger > Capture > Color_) imleci bir damlalığa dönüştürür. Ekrandaki herhangi bir şeye tıklayın; renk panoya gider. Seçmeden geri çıkmak için kısayol tuşuna tekrar basın.

## Paylaşmadan önce dönüştürme

Bir 4K ekran kaydı veya telefonunuzdan ham bir HEIC çoğu zaman öylece göndermek için fazla büyüktür. `Super + Ctrl + .` (veya _Trigger > Transcode_) bunu düzeltir. Size `~/Pictures` ve `~/Videos` üzerinde bulanık bir dosya seçici sunar, sonra bir biçim ve bir boyut sorar.

Resimler, genişliği 3160, 2160 ve 1080 pikselde sınırlayan yüksek, orta veya düşük kalitede jpg veya png'ye gider. Videolar 4k, 1080p veya 720p'de mp4 veya animasyonlu bir gif'e gider. Dönüştürülen dosya, adında çözünürlükle birlikte orijinalin yanına yazılır — `demo-1080p.mp4` — ve yol, dosya bırakmalarını kabul eden bir uygulamaya doğrudan yapıştırabilmeniz için bir dosya URI'si olarak panoya kopyalanır.

Terminalden de çalışır, zaten ne istediğinizi biliyorsanız: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ayrıca bir görüntüyü ASCII sanatına dönüştüren `omarchy transcode ascii` de vardır — o çoğunlukla [markalama](41-branding.md) içindir.

## Bir yere gönderme

Dosyayı aldıktan sonra, `Super + Ctrl + S` Paylaş menüsünü açar ve onu LocalSend aracılığıyla ağınızdaki başka bir cihaza gönderir. Bunun için [GUI'ler](22-guis.md) bölümüne bakın.
