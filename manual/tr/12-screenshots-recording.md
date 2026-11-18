# Ekran Görüntüleri ve Kayıt

Ekrandan alabileceğiniz her şey Print Screen tuşuna bağlıdır. Tuş tek başına bir fotoğraf çeker ve değiştiriciler bir kayıt, bir renk veya bir bölgenin içindeki metni alır. Klavyenizde hiç Print Screen tuşu yoksa, `Super + Ctrl + Alt + C` aynı ekran görüntüsünü alır ve `Super + Ctrl + C` tüm seti bir menü olarak açar.

| Kısayol Tuşu | İşlev |
| ------ | -------- |
| `Print Screen` | Ekran görüntüsü |
| `Super + Ctrl + Alt + C` | Ekran görüntüsü |
| `Alt + Print Screen` | Ekran kaydı (veya çalışmakta olanı durdurma) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Bir bölgedeki metni çıkarma |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Super + Ctrl + .` | Bir resmi veya videoyu dönüştürme |

## Ekran Görüntüleri

`Print Screen` tuşuna (veya `Super + Ctrl + Alt + C` kombinasyonuna) basın; Omasnap, yerleşimi görünmeden önce odaklanılan monitörü yakalar, böylece siz nişan alırken altınızda hiçbir şey kaymaz. Serbest biçimli bir bölge sürükleyin, yakalamak için bir pencereye tıklayın veya tüm monitörü yakalamak için boş alana tıklayın. Kaydırmalı bir bölge yakalamak için çizmeden önce `S` tuşuna basın. Fikrinizi mi değiştirdiniz? Omasnap'ı kapatmak için aynı tuşa tekrar basın.

Bir alan seçtikten sonra Omasnap yakalamayı kaydeder, panoya kopyalar ve küçük resmiyle birlikte bir bildirim gösterir, tıpkı kaydedilmiş bir ekran kaydının yaptığı gibi. Kaydedilen görüntüyü resim görüntüleyicinizde görüntülemek için Open'ı, üzerine not eklemek için Edit'i seçin.

Not ekleme düzenleyicisi oklar, çizgiler, şekiller, vurgular, numaralı işaretler, metin ve güvenli redaksiyonlar çizebilir; resmin bir kısmını kırpabilir veya kesip çıkarabilir; metnini OCR ile çıkarabilir; ve bir arka plan ekleyebilir. Düzenleyicide, bitmiş PNG'yi kopyalayıp kaydetmek için `Enter` tuşuna, kaydetmeden kopyalamak için `Ctrl + C` kombinasyonuna veya kopyalamadan kaydetmek için `Ctrl + S` kombinasyonuna basın.

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` dizinine, `screenshot-2026-08-13_14-22-05-firefox.png` gibi bir adla düşer. Başka bir dizin kullanmak için `OMASNAP_SCREENSHOT_DIR` değişkenini ayarlayın — oturum ortam değişkenlerini nereye koyacağınız için bkz. [SSS](46-faq.md). Omasnap, ilk görüntüyü kaydettiğinde dizini oluşturur. Otomatik kaydetmeyi devre dışı bırakmak için `~/.config/omasnap/omasnap.conf` içinde `[output] autosave = false` ayarını yapın; yakalamalar o zaman yalnızca kopyalanır ve 10 saniye boyunca, sabitleme düğmesiyle veya `Ctrl + P` ile ekranda tutabileceğiniz bir önizlemede gösterilir.

Terminalden, `omarchy screenshot` aynı yerleşimi açar ve başlangıç modunu seçebilirsiniz: `omarchy capture screenshot region`, `windows`, `fullscreen` veya `scroll`. İkinci bir argüman olarak `copy` veya `save` vermek görüntüyü doğrudan o hedefe gönderir. Çıktıdan önce düzenlemek için tam ekran düzenleyici için `omarchy screenshot --editor=overlay` veya ayrı bir pencere için `omarchy screenshot --editor=window` kullanın.

### Seçiciyi klavyeden yönlendirmek

Seçim açıkken fareyi hiç kullanmak zorunda değilsiniz:

| Tuş | İşlev |
| --- | -------- |
| `S` | Kaydırmalı bölge modunu açma/kapatma |
| `Super + Arrow keys` | Pencere modunda pencereler arasında gezinme |
| `Return` | Vurgulanan pencereyi yakalama |
| `Ctrl + A` | Odaklanılan monitörün tamamını yakalama |
| `R` | Bu oturumda çizilen son bölgeyi geri getirme |
| `Esc` | Omasnap'ı kapatma |

Bu tuş atamaları yalnızca Omasnap açıkken vardır, bu yüzden kendi yapılandırmanızdaki hiçbir şeyle çakışamazlar.

## Ekran kaydı

`Alt + Print Screen`, _Trigger > Capture > Screenrecord_'u açar; bu, ses kuşağında ne istediğinizi sorar: ses yok, masaüstü sesi, masaüstü artı mikrofon veya masaüstü artı mikrofon artı web kamerası. Sonuncusu yalnızca gerçekten takılı bir kameranız varsa görünür. Birini seçin; Omarchy'nin kayıt seçicisi bir bölge sürüklemenize veya bir pencereye ya da monitöre tıklamanıza izin verir.

Kayıt, gpu-screen-recorder üzerinde çalışır; bu, GPU üzerinde 60fps'de kodlama yapar ve gerekirse CPU'ya geri döner. Sonuç, `~/Videos` içinde `screenrecording-2026-08-13_14-22-05.mp4` adlı bir MP4 olur. Bunu değiştirmek için `OMARCHY_SCREENRECORD_DIR` değişkenini ayarlayın — ancak ekran görüntüsü dizininden farklı olarak bunun önceden var olması gerektiğini, yoksa kaydın başlamayı reddedeceğini unutmayın.

Kaydederken çubukta küçük bir gösterge belirir. Durdurmak için ona tıklayın. Ayrıca `Alt + Print Screen` kombinasyonuna tekrar basarak veya yalnızca gerçekten bir şey kaydedilirken görünen, _Trigger > Capture > Screenrecord_ altındaki _Stop Screenrecording_ girdisiyle de durdurabilirsiniz.

Durdurmak, dosyayı size vermeden önce biraz temizlik yapar: ilk kare kırpılır ve ses varsa, en baştaki PipeWire yakalama patlaması susturulmuş olarak -14 LUFS'ye normalize edilir. Ardından kayıttan bir küçük resimle birlikte bir bildirim belirir. Dosyayı Omaview'de oynatmak için ona tıklayın.

### Web kamerası yerleşimi

Web kamerasıyla kayıt yaptığınızda kamera, kaydettiğiniz şeyin sağ alt köşesinde sabitlenmiş, kırpılmış bir portre penceresi olarak görünür. İhtiyacınız olan bir şeyin üzerinde duruyorsa onu anında yeniden boyutlandırın:

| Kısayol Tuşu | İşlev |
| ------ | -------- |
| `Super + Alt + [` | Web kamerası yerleşimini küçültme |
| `Super + Alt + ]` | Web kamerası yerleşimini büyütme |

Üç boyut vardır — küçük, orta ve büyük — ve kısayol tuşları bunlar arasında adım adım geçiş yapar. Orta varsayılandır. Kayıtla orantılıdırlar, bu yüzden ister 1080p bir monitörü ister 6K bir monitörü kaydedin, kamera karenin aynı payını kaplar. Ve tüm bir ekran yerine bir bölge kaydettiyseniz yerleşim, monitörün köşesi yerine o bölgenin köşesine sabitlenir, böylece çekimin içinde kalır.

Ayrıca doğrudan `omarchy-capture-webcam-resize small` ile de çağırabilir veya ortaya geri dönmek için `reset` kullanabilirsiniz.

## Metin, QR kodları ve renkler

`Super + Ctrl + Print Screen` bir bölge seçer ve onu OCR ile panoya çıkarır. Bu, [Metin Çıkarma ve Dikte](11-text-extraction-dictation.md) bölümünde düzgünce ele alınmıştır.

_Trigger > Capture > QR Code_ QR kodları için aynı numarayı yapar. İçinde kod olan bölgeyi seçin; çözülen değer panoya gider. Yalnızca QR kodlarını arar — yoğun ekran içeriği, aksi takdirde barkodmuş gibi yanlış pozitif sonuç verme alışkanlığına sahiptir. Bilmekte fayda var: çözülen değer panoya gider ve başka hiçbir yere gitmez. Yazdırılmaz, bildirimde yer almaz ve [pano geçmişi](08-unified-clipboard-history.md) içinde kalmaması için hassas olarak işaretlenir. QR kodları rutin olarak sırlar taşır — örneğin bir 2FA kurulum kodunun arkasındaki `otpauth://` URI'si — ve bunu bir günlüğe sokmak istemezsiniz. Yapıştırma yine de gayet iyi çalışır.

`Super + Print Screen` (veya _Trigger > Capture > Color_) imleci bir damlalığa dönüştürür. Ekrandaki herhangi bir şeye tıklayın; renk panoya düşer. Seçim yapmadan geri çıkmak için kısayol tuşuna tekrar basın.

## Paylaşmadan önce dönüştürme

4K bir ekran kaydı veya telefonunuzdan gelen ham bir HEIC genellikle öylece göndermek için fazla büyüktür. `Super + Ctrl + .` (veya _Trigger > Transcode_) bunu düzeltir. Size `~/Pictures` ve `~/Videos` üzerinde bulanık bir dosya seçici sunar, ardından bir format ve bir boyut ister.

Resimler, genişliği 3160, 2160 ve 1080 pikselde sınırlayan yüksek, orta veya düşük kalitede jpg veya png'ye gider. Videolar 4k, 1080p veya 720p'de mp4 veya animasyonlu bir gif'e gider. Dönüştürülen dosya, adında çözünürlükle birlikte orijinalin yanına yazılır — `demo-1080p.mp4` — ve yol, bir dosya URI'si olarak panoya kopyalanır, böylece onu dosya bırakmalarını kabul eden bir uygulamaya doğrudan yapıştırabilirsiniz.

Terminalden de çalışır, zaten ne istediğinizi biliyorsanız: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ayrıca bir resmi ASCII sanatına dönüştüren `omarchy transcode ascii` de vardır — o çoğunlukla [markalama](41-branding.md) içindir.

## Bir yere göndermek

Dosyayı aldıktan sonra `Super + Ctrl + S`, Share menüsünü açar ve onu LocalSend aracılığıyla ağınızdaki başka bir cihaza gönderir. Bunun için bkz. [GUIs](22-guis.md).
