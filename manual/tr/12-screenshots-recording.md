# Ekran Görüntüleri ve Kayıt

Ekranda yakalayabileceğiniz her şey Print Screen tuşuna bağlıdır. Tek başına bir tuş bir resim alır ve değiştiriciler bir kayıt, bir renk veya bir bölgenin içindeki metni alır. Klavyenizde hiç Print Screen tuşu yoksa, `Super + Ctrl + C` aynı kümeyi bir menü olarak açar.

| Kısayol | İşlev |
| ------ | -------- |
| `Print Screen` | Ekran Görüntüsü |
| `Alt + Print Screen` | Ekran kaydı (veya çalışmakta olanı durdur) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Bir bölgeden metin çıkar |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Super + Ctrl + .` | Bir resmin veya videonun kodunu dönüştür |

## Ekran Görüntüleri

`Print Screen` tuşuna basın; Omasnap, katmanı görünmeden önce odaklanmış monitörü yakalar, böylece nişan alırken altınızda hiçbir şey kaymaz. Serbest bir bölge sürükleyin, yakalamak için bir pencereye tıklayın veya tüm monitörü yakalamak için açık alana tıklayın. Kayan bir bölge yakalamak için çizmeden önce `S` tuşuna basın. Fikrinizi mi değiştirdiniz? Omasnap'i kapatmak için yine `Print Screen` tuşuna basın.

Bir alan seçtikten sonra, Omasnap yakalamayı kaydeder, panoya kopyalar ve 10 saniye boyunca bir önizleme gösterir. Onu ekranda tutmak için önizlemenin sabitle düğmesini veya `Ctrl + P` tuşunu kullanın veya açıklamak için Düzenle'yi seçin.

Açıklama düzenleyicisi oklar, çizgiler, şekiller, vurgular, numaralı işaretçiler, metin ve güvenli sansürlemeler çizebilir; görüntünün bir kısmını kırpabilir veya kesebilir; metnini OCR yapabilir; ve bir arka plan ekleyebilir. Düzenleyicide, bitmiş PNG'yi kopyalayıp kaydetmek için `Enter`, kaydetmeden kopyalamak için `Ctrl + C` veya kopyalamadan kaydetmek için `Ctrl + S` tuşuna basın.

Kayıtlı ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` içine, `screenshot-2026-08-13_14-22-05-firefox.png` gibi bir adla iner. Başka bir dizin kullanmak için `OMASNAP_SCREENSHOT_DIR` ayarlayın — oturum ortam değişkenlerini nereye koyacağınız için bkz. [SSS](46-faq.md). Omasnap, ilk çekimi kaydederken dizini oluşturur. Otomatik kaydetmeyi devre dışı bırakmak için `~/.config/omasnap/omasnap.conf` içinde `[output] autosave = false` ayarlayın.

Terminalden, `omarchy screenshot` aynı katmanı açar ve başlangıç modunu seçebilirsiniz: `omarchy capture screenshot region`, `windows`, `fullscreen` veya `scroll`. İkinci bir `copy` veya `save` argümanı önizlemeyi atlar ve çekimi doğrudan o hedefe gönderir. Çıktıdan önce düzenlemek için, tam ekran bir düzenleyici için `omarchy screenshot --editor=overlay` veya ayrı bir pencere için `omarchy screenshot --editor=window` kullanın.

### Seçiciyi klavyeden sürmek

Seçim açıkken, fareyi hiç kullanmak zorunda değilsiniz:

| Tuş | İşlev |
| --- | -------- |
| `S` | Kayan bölge modunu aç/kapat |
| `Super + Arrow keys` | Pencere modunda pencereler arasında hareket et |
| `Return` | Vurgulanan pencereyi yakala |
| `Ctrl + A` | Odaklanmış monitörün tamamını yakala |
| `R` | Bu oturumda çizilen son bölgeyi geri yükle |
| `Esc` | Omasnap'i kapat |

Bu bağlamalar yalnızca Omasnap açıkken vardır, bu yüzden kendi yapılandırmanızdaki hiçbir şeyle çakışamazlar.

## Ekran kaydı

`Alt + Print Screen`, film müziğinde ne istediğinizi soran _Tetikle > Yakala > Ekran Kaydı_ öğesini açar: ses yok, masaüstü sesi, masaüstü + mikrofon veya masaüstü + mikrofon + webcam. Sonuncusu yalnızca gerçekten takılı bir kameranız varsa görünür. Birini seçin, Omarchy'nin kayıt seçicisi bir bölge sürüklemenize veya bir pencere veya monitöre tıklamanıza izin verir.

Kayıt, GPU üzerinde 60fps'de kodlayan ve gerekirse CPU'ya dönen gpu-screen-recorder üzerinde çalışır. Sonuç, `~/Videos` içinde `screenrecording-2026-08-13_14-22-05.mp4` adlı bir MP4'tür. Bunu değiştirmek için `OMARCHY_SCREENRECORD_DIR` ayarlayın — ancak ekran görüntüsü dizininin aksine, bunun zaten mevcut olması gerektiğini, yoksa kaydın başlamayı reddedeceğini unutmayın.

Kaydederken, çubukta küçük bir gösterge belirir. Durdurmak için ona tıklayın. Ayrıca tekrar `Alt + Print Screen` ile veya _Tetikle > Yakala > Ekran Kaydı_ altındaki ve yalnızca bir şey gerçekten kaydederken görünen _Kaydı Durdur_ girdisiyle de durdurabilirsiniz.

Durdurmak, dosyayı size vermeden önce biraz düzenleme yapar: ilk kare kırpılır ve ses varsa -14 LUFS'a normalleştirilir, en baştaki PipeWire yakalama sesi sessize alınır. Ardından kayıttan küçük bir resimle bir bildirim görünür. Dosyayı mpv'de oynatmak için ona tıklayın.

### Webcam katmanı

Bir webcam ile kaydettiğinizde, kamera kaydettiğiniz şeyin sağ alt köşesinde sabitlenmiş, kırpılmış bir portre penceresi olarak görünür. İhtiyacınız olan bir şeyin üzerinde oturuyorsa, onu anında yeniden boyutlandırın:

| Kısayol | İşlev |
| ------ | -------- |
| `Super + Alt + [` | Webcam katmanını küçült |
| `Super + Alt + ]` | Webcam katmanını büyüt |

Üç boyut vardır — küçük, orta ve büyük — ve kısayollar aralarında adım atar. Orta varsayılandır. Bunlar kayıtla orantılıdır, böylece kamera 1080p bir monitör de 6K bir monitör de kaydediyor olsanız çerçevenin aynı payını alır. Ve tüm ekran yerine bir bölge kaydettiyseniz, katman monitörün köşesi yerine o bölgenin köşesine sabitlenir, böylece çekimin içinde kalır.

Ayrıca bunu `omarchy-capture-webcam-resize small` ile doğrudan çağırabilir veya ortaya dönmek için `reset` diyebilirsiniz.

## Metin, QR kodları ve renkler

`Super + Ctrl + Print Screen` bir bölge seçer ve panoya OCR yapar. Bu, [Metin Çıkarma ve Dikte](11-text-extraction-dictation.md) bölümünde düzgünce ele alınmıştır.

_Tetikle > Yakala > QR Kodu_ aynı numarayı QR kodları için yapar. Kodu içeren bölgeyi seçin, çözülen değer panoya gider. Yalnızca QR kodlarını arar — yoğun ekran içeriğinin aksi halde barkod olarak yanlış pozitif verme alışkanlığı vardır. Bilmeye değer: çözülen değer panoya gider ve başka hiçbir yere gitmez. Yazdırılmaz, bildirimde olmaz ve hassas olarak işaretlenir, böylece [pano geçmişinde](08-unified-clipboard-history.md) kalıcı olmaz. QR kodları rutin olarak sırlar taşır — örneğin bir 2FA kurulum kodunun ardındaki `otpauth://` URI'si — ve bunun bir günlükte olmasını istemezsiniz. Yapıştırma yine de sorunsuz çalışır.

`Super + Print Screen` (veya _Tetikle > Yakala > Renk_) imleci bir damlalığa dönüştürür. Ekrandaki herhangi bir şeye tıklayın, renk panoya iner. Seçmeden geri çıkmak için kısayola tekrar basın.

## Paylaşmadan önce kod dönüştürme

4K bir ekran kaydı veya telefonunuzdan ham bir HEIC genellikle öylece gönderilemeyecek kadar büyüktür. `Super + Ctrl + .` (veya _Tetikle > Dönüştür_) bunu düzeltir. Size `~/Pictures` ve `~/Videos` üzerinde bir bulanık dosya seçici sunar, ardından bir format ve boyut sorar.

Resimler genişliği 3160, 2160 ve 1080 piksel ile sınırlayan yüksek, orta veya düşük ayarda jpg veya png'ye gider. Videolar 4k, 1080p veya 720p'de mp4 veya animasyonlu gif'e gider. Dönüştürülen dosya, çözünürlük adında olacak şekilde orijinalin yanına yazılır — `demo-1080p.mp4` — ve yol dosya URI'si olarak panoya kopyalanır, böylece onu dosya bırakmalarını kabul eden bir uygulamanın içine doğrudan yapıştırabilirsiniz.

Ne istediğinizi zaten biliyorsanız terminalden de çalışır: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ayrıca bir görüntüyü ASCII sanatına dönüştüren `omarchy transcode ascii` de var — bu çoğunlukla [markalama](41-branding.md) için.

## Bir yere göndermek

Dosyayı aldığınızda, `Super + Ctrl + S` Paylaş menüsünü açar ve onu LocalSend üzerinden ağınızdaki başka bir cihaza gönderir. Bunun için bkz. [GUI'ler](22-guis.md).
