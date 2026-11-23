# Kısayollar

Tüm ana klavye bağlamalarını `Super + K` ile görebilirsiniz (Tmux bağlamaları `Super + Alt + K` ile ve Herdr bağlamaları `Super + Ctrl + K` ile).

## Kısayollar nasıl düzenlenir

Her kısayol, değiştiricileriyle belirlenen bir düzlemde oturur ve her düzlemin tek bir işi vardır. Kısayolların birbirine karışmasını engelleyen budur ve bu sayede bir şeyin nerede olduğunu genellikle tahmin edebilirsiniz.

| Düzlem | Orada ne bulunur | Örnekler |
| --- | --- | --- |
| `Super + key` | Sistem: pencereler, çalışma alanları, düzenler ve temel menüler | `Super + Space` Omarchy menüsü, `Super + W` pencereyi kapat, `Super + F` tam ekran |
| `Super + Shift + key` | Uygulamalar | `Super + Shift + B` tarayıcı, `Super + Shift + E` e-posta, `Super + Shift + N` düzenleyici |
| `Super + Ctrl + key` | Paneller ve sistem menüleri | `Super + Ctrl + A` ses, `Super + Ctrl + N` ağ, `Super + Ctrl + C` yakalama menüsü |
| `Super + Ctrl + Alt + key` | Hızlı eylemler ve uyarılar | `Super + Ctrl + Alt + T` saati göster, `Super + Ctrl + Alt + B` pil, `Super + Ctrl + Alt + C` ekran görüntüsü |

Bir kısayola `Alt` eklemek size aynı şeyin bir varyantını verir, asla alakasız bir şeyi vermez:

- `Super + Shift + B` tarayıcıyı açar; `Super + Shift + Alt + B` özel bir pencere açar
- `Super + Shift + E` e-postayı açar; `Super + Shift + Alt + E` yeni bir tane başlatır
- `Super + F` tam ekrana geçer; `Super + Alt + F` tam genişliğe geçer
- `Super + Ctrl + C` yakalama menüsünü açar; `Super + Ctrl + Alt + C` menüyü atlar ve bir ekran görüntüsü alır

Kısayol eklerken:

1. Ne yaptığına göre düzlemi seçin, sonra tuşu seçin.
2. Yer açmak için mevcut bir kısayolu taşımayın. Doğru düzlemde boş bir tuş bulun.
3. `Alt` tuşunu yalnızca onsuz kısayolun bir varyantı için kullanın.

Birkaç kısayol, kullanışlı oldukları için bu kuralları bozar. Bir ok veya `Tab` ile `Shift`, uygulama açmak yerine taşır veya tersine çevirir ve `Print`, medya tuşları, `Alt + Tab` ve `Ctrl + Alt + Del` her yerde olduğu gibi çalışır. Bunlar istisnadır, kopyalanacak kalıplar değildir.

Bir varsayılan size uymuyorsa (diyelim ki Windows'taki gibi ekran görüntüleri için `Super + Shift + S` istiyorsunuz), bunu `~/.config/hypr/bindings.lua` içinde yeniden bağlayın.

## Gezinme

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüsü (uygulamalar ve diğer her şey)    |
| `Super + Alt + Space` | Uygulama ızgarası |
| `Super + Escape` | Sistem menüsü (askıya al, yeniden başlat vb.)  |
| `Super + Ctrl + L` | Bilgisayarı kilitle |
| `Super + W` or `Super + Q` | Pencereyi kapat             |
| `Ctrl + Alt + Del` | Tüm pencereleri kapat |
| `Super + K` | Tüm kısayolları göster |
| `Super + Alt + K` | Tmux kısayollarını göster |
| `Super + Ctrl + K` | Herdr kısayollarını göster |
| `Super + M` | Pencereyi dock'a küçült |
| `Super + T`               | Pencereyi döşeme/yüzen arasında değiştir             |
| `Super + J` | Pencere konumunu değiştir (yatay/dikey) |
| `Super + O`               | Pencereyi yapışkan ve yüzen olarak açmayı değiştir |
| `Super + L`               | Dwindle, scrolling ve floating düzenleri arasında dolaş |
| `Super + Alt + L`         | Düzenler arasında ters yönde dolaş |
| `Super + P`               | Sözde pencere stilini değiştir (doğal ve gerilmiş) |
| `Super + F`                 | Tam ekrana geç              |
| `Super + Alt + F`                 | Tam genişliğe geç              |
| `Super + Ctrl + F`                 | Pencere içinde tam ekrana geç              |
| `Super + 1…9/0`         | Odaklanılan monitörde belirli çalışma alanına atla (0, 10'dur) |
| `Super + Tab` | Odaklanılan monitörde sonraki çalışma alanına atla |
| `Super + Shift + Tab` | Odaklanılan monitörde önceki çalışma alanına atla |
| `Super + Ctrl + Tab` | Odaklanılan monitörde eski çalışma alanına atla |
| `Super + Shift + 1…9/0` | Pencereyi odaklanılan monitördeki çalışma alanına taşı |
| `Super + Shift + Alt + 1…9/0` | Pencereyi takip etmeden odaklanılan monitördeki çalışma alanına taşı |
| `Super + S` | Tam scratchpad'i aç/kapat |
| `Super + Alt + S` | Pencereyi tam scratchpad'e taşı |
| `Super + the key above Tab` (grave on US layouts) | Quake konsolunu aç/kapat |
| `Super + Shift + the key above Tab` (grave on US layouts) | Pencereyi Quake konsoluna taşı |
| `Super + Shift + Ctrl + Arrows` | Pencereyi o yöndeki monitöre taşı |
| `Super + Shift + Alt + Arrows` | Çalışma alanını o yöndeki monitöre taşı |
| `Super + Arrow`  | Odağı ok yönündeki pencereye taşı, ekranın kenarında o taraftaki monitöre geçerek |
| `Super + Shift + Arrow`  | Pencereyi ok yönündeki başka bir pencereyle takas et, o taraftaki monitördekiler dahil |
| `Super + Minus` | Pencereyi sola genişlet |
| `Super + Equal` | Pencereyi sola küçült |
| `Super + Shift + Minus` | Pencereyi yukarı küçült |
| `Super + Shift + Equal` | Pencereyi aşağı genişlet |
| `Super + Alt + Minus/Equal` | Aynı boyutlandırmayı daha küçük adımlarla yap |
| `Super + Ctrl + Minus/Equal` | Aynı boyutlandırmayı daha büyük adımlarla yap |
| `Super + Alt + Home` | Pencere genişliğini kaydet |
| `Super + Home` | Kaydedilen pencere genişliğini geri yükle |
| `Super + Left Mouse` | Pencereyi sürükleyerek taşı |
| `Super + Right Mouse` | Pencereyi yeniden boyutlandır |
| `Super + Scroll Wheel` | Odaklanılan monitörde çalışma alanları arasında kaydır |
| `Super + G`               | Pencere gruplandırmasını aç/kapat      |
| `Super + Alt + G`               | Pencereyi gruplandırmanın dışına taşı      |
| `Super + Alt + Tab`               | Gruplandırma içindeki pencereler arasında dolaş      |
| `Super + Alt + Shift + Tab`               | Gruplandırma içindeki pencereler arasında geriye doğru dolaş      |
| `Super + Alt + Scroll Wheel` | Gruplandırma içindeki pencereler arasında dolaş |
| `Super + Alt + 1/2/3/4/5`               | Gruplandırmada belirli pencereye atla      |
| `Super + Alt + Arrow`  | Pencereyi ok yönünde gruplandırmaya taşı, o taraftaki monitördekiler dahil |
| `Super + Ctrl + Left/Right`  | Bir döşeme grubu içinde pencereler arasında gezin |
| `Super + Ctrl + Z` | Ekrana yakınlaş (daha fazla yakınlaşma için tekrarlayın) |
| `Super + Ctrl + Alt + Z` | Ekrandan tamamen uzaklaş |
| `Super + /` | Monitör ölçekleme seçeneklerinde ileri adım at |
| `Super + Alt + /` | Monitör ölçekleme seçeneklerinde geri adım at |
| `Alt + Tab` | Etkin çalışma alanındaki pencereler arasında ileri doğru dolaş |
| `Alt + Shift + Tab` | Etkin çalışma alanındaki pencereler arasında geriye doğru dolaş |
| `Ctrl + Alt + Tab`| Monitörler arasında odağı ileri doğru dolaştır |
| `Ctrl + Alt + Shift + Tab`| Monitörler arasında odağı geriye doğru dolaştır |
| `Super + I` | Giriş dilini değiştir (birden fazla düzen veya giriş yöntemiyle) |
| `Super + Shift + I` | Giriş dilini geri değiştir |

Dokunmatik yüzeyde, üç ve dört parmakla kaydırma hareketleri çalışma alanlarını değiştirir, pencereleri taşır ve menüyü ve Quake konsolunu açar; hareketler için bkz. [klavye, fare ve dokunmatik yüzey](34-keyboard-mouse-trackpad.md).

Boyutlandırma, klavyenizin üzerlerine ne yazdığına bakılmaksızın 0'ın sağındaki iki tuşu kullanır: ABD klavyelerinde `-` ve `=`, Danca ve İsveççe'de `+` ve `´`, Norveççe'de `+` ve `\`, Almanca'da `ß` ve `´`, İspanyolca'da `'` ve `¡` ve Japonca'da (JIS) `-` ve `^`. `Super + K` bunları klavyenizin yazdığı şekilde listeler. JIS'te, `Super + ^`, `Super + Equal`'dır, oysa `Super + Shift + -` (`=` yazar) `Super + Shift + Minus`'tur. Monitör ölçekleme ve parola yöneticisi `/` kullanır; `/` tuşunu yalnızca Shift ile yazan düzenlerde, çoğu Avrupa düzeninde olduğu gibi, bunun yerine sağ Shift'in solundaki tuşu kullanırlar (Danca ve Almanca'da `-`).

## Sistem kontrolleri

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ses paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/ağ paneli    |
| `Super + Ctrl + D`           | Ekran paneli    |
| `Super + Ctrl + P`           | Güç paneli    |
| `Super + Ctrl + X`           | Ajanlar paneli    |
| `Super + Ctrl + Alt + X`           | Yerel modeller paneli    |
| `Super + Ctrl + Alt + D`           | Takvim paneli    |
| `Super + Ctrl + Alt + E`           | Dünya saati paneli    |
| `Super + Ctrl + 1-9`           | Çubuk panelini konuma göre aç/kapat    |
| `Super + Ctrl + S` | Paylaşım menüsü (LocalSend ile) |
| `Super + Ctrl + C` | Yakalama kontrolleri (ekran görüntüsü/-kaydı/seçici) |
| `Super + Ctrl + O` | Menüyü aç/kapat |
| `Super + Ctrl + H` | Donanım menüsü |
| `Super + Ctrl + E` | Emoji seçici |
| `Super + Ctrl + .` | Medyayı dönüştür |
| `Super + Shift + Ctrl + A` | Varsayılan ajanınızı başlatın |
| `Power` key | Sistem menüsü |
| `Super + Shift + Copilot` key | Omarchy menüsü |

## Ayarlamalar

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimum ekran parlaklığı |
| `Shift + Brightness Down` | Minimum ekran parlaklığı |
| `Alt + Brightness Up/Down` | Hassas %1 parlaklık değişiklikleri |
| `Alt + Volume Up/Down` | Hassas %1 ses değişiklikleri |
| `Keyboard Brightness Up/Down` | Klavye arka ışığını daha parlak/daha sönük yap |
| `Keyboard Backlight` | Klavye arka ışık seviyeleri arasında dolaş |
| `Ctrl + Brightness Up/Down` | Kendi tuşları olmayan klavyelerde klavye arka ışığını daha parlak/daha sönük yap |
| `Mic Mute` | Mikrofonu sessize al |
| `Shift + Mute` | Ses çıkışını değiştir |
| `Touchpad Toggle` | Dokunmatik yüzeyi aç veya kapat |
| `Display` key | Çalışma alanı düzeninde dolaş |
| `Alt + Play` | Sonraki parça |
| `Alt + Shift + Play` | Önceki parça |

## Uygulamaları başlatma

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (ajan yöneticisi) |
| `Super + Shift + Return` or `Super + Shift + B`  | Tarayıcı    |
| `Super + Shift + Alt + B`           | Tarayıcı (özel/gizli)    |
| `Super + Shift + F`           | Dosya yöneticisi    |
| `Super + Shift + Alt + F`           | Terminalin cwd'sindeki dosya yöneticisi    |
| `Super + Shift + M`           | Müzik (Spotify)    |
| `Super + Shift + Alt + M`           | Müzik (cliamp)    |
| `Super + Shift + /`           | Parola yöneticisi (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Hesap makinesi (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kurulduktan sonra)    |
| `Super + Shift + T`           | Etkinlik (btop)    |
| `Super + Shift + N`           | Düzenleyici (Plain veya seçtiğiniz varsayılan)  |
| `Super + Shift + C`           | Takvim ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-posta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yeni e-posta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Varsayılan ajanınız veya bir tane seçene kadar ChatGPT |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Mesajlaşma (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mesajlaşma (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mesajlaşma (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Yazma (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (yeni gönderi) |
| `Super + Shift + Y`           | YouTube |

Bağlamaları `~/.config/hypr/bindings.lua` içinde değiştirin/ekleyin.

## Evrensel pano

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` destekleyen uygulamalarda tümünü seç    |
| `Super + C`           | Kopyala    |
| `Super + X`           | Kes (terminalde değil)    |
| `Super + V`           | Yapıştır    |
| `Super + Ctrl + V`           | Pano yöneticisi    |

Genellikle Linux'ta, terminalde kopyalayıp yapıştırmak için `Ctrl + Shift + C/V` ve diğer her yerde bunu yapmak için `Ctrl + C/V` kullanmanız gerekir. Bu Omarchy birleşik pano kısayolları her yerde çalışır.

## Yakalama

| Kısayol              | İşlev                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekran görüntüsü                      |
| `Super + Ctrl + Alt + C`            | Ekran görüntüsü (Print Screen tuşu olmayan klavyeler için aynı çekim) |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Alt + Print Screen`            | Ekran kaydı                     |
| `Super + Shift + Ctrl + Alt + C` | Ses olmadan, menüyü atlayarak ekran kaydı (durdurmak için tekrar basın) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Metin çıkarmayı panoya kopyala |
| `Super + Alt + [` | Kayıt sırasında web kamerası katmanını küçült |
| `Super + Alt + ]` | Kayıt sırasında web kamerası katmanını büyüt |
| `Alt + Shift + L` | Web uygulamasından veya tarayıcıdan geçerli URL'yi kopyala |
| `Alt + Shift + D` | Geçerli sayfadaki videoyu `~/Videos` konumuna indir |
| `Alt + Space` | Dikteyi başlat/durdur (_Kurulum > Varsayılanlar > Dikte_ gerektirir) |
| `Right Alt` | Dikte etmek için basılı tut (_Kurulum > Varsayılanlar > Dikte_ gerektirir) |

Ekran kayıtlarında, kısayol önce hangi sesi istediğinizi sorar, sonra kaydı başlatır. Durdurmak için tekrar basın. Ayrıntılar için bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md).

Tüm yakalama seçeneklerine Omarchy menüsündeki (`Super + Space`) _Tetikleyici > Yakalama_ altından da erişilebilir.

## Bildirimler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + ,` | En son bildirime işlem yap: açın veya tek düğmesine basın, seçeneklerinden birini seçin veya hiçbiri yoksa kapatın  |
| `Super + Shift + ,` | Tüm bildirimleri kapat |
| `Super + Ctrl + ,` | Bildirimleri klavyeyle kontrol et  |
| `Super + Alt + ,` | En son bildirimi kapat  |
| `Super + Shift + Alt + ,` | Bildirim geçmişini aç  |
| `Super + Ctrl + Alt + ,` | Bildirimleri susturmayı aç/kapat  |

## Stil

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yeni bir tema seç (ayrıca `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tema arka planını seç (ayrıca `Super + Ctrl + Space`) |
| `Super + Backspace` | Bir pencerede şeffaflığı aç/kapat |
| `Super + Ctrl + Backspace` | Tek pencere kare en-boy oranını aç/kapat |

Ekstra arka plan görüntüleri `~/.config/omarchy/backgrounds/<theme name>` içinde bulunur. Ayrıca Omarchy menüsündeki _Kur > Stil > Arka Plan_ yoluyla da kullanılabilir.

Tüm stil seçeneklerine Omarchy menüsündeki (`Super + Space`) _Görünüm_ altından da erişilebilir.

## Geçişler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Boşta kilitlemeyi aç/kapat |
| `Super + Ctrl + Delete` | Dizüstü ekranını aç/kapat |
| `Super + Ctrl + Alt + Delete` | Dizüstü ekran yansıtmayı aç/kapat |
| `Super + Shift + Space` | Üst çubuğu aç/kapat  |
| `Shift + Mute` | Sonraki ses çıkışına geç |
| `Shift + Play` | Sonraki medya kaynağına geç |
| `Super + Shift + Backspace` | Pencere boşluklarını aç/kapat |
| `Super + Ctrl + Alt + F` | Tam ekran masaüstünü aç/kapat (üst çubuk + pencere boşlukları) |

## Hatırlatıcılar

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Bir hatırlatıcı ayarla  |
| `Super + Ctrl + Alt + R` | Tüm hatırlatıcıları gör  |
| `Super + Ctrl + Shift + R` | Tüm hatırlatıcıları temizle  |

## Uyarılar

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Saati bildirim olarak göster  |
| `Super + Ctrl + Alt + B` | Pili bildirim olarak göster  |
| `Super + Ctrl + Alt + W` | Havayı bildirim olarak göstermeyi aç/kapat  |

## Tmux

Ön ek tuşu `Ctrl + Space`'tir (`Ctrl + B` de çalışır). Bu bağlamaları `~/.config/tmux/tmux.conf` içinde değiştirebilirsiniz.

### Paneller

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + v` | Paneli yanına böl (dikey) |
| `Prefix + h` | Paneli altına böl (yatay) |
| `Prefix + x` | Paneli sonlandır |
| `Prefix + z` | Panel yakınlaştırmayı aç/kapat (tam ekran) |
| `Alt + Enter` | Paneli altına böl (ön ek yok) |
| `Alt + Shift + Enter` | Paneli yanına böl (ön ek yok) |
| `Alt + Escape` | Paneli sonlandır (ön ek yok) |
| `Ctrl + Alt + Arrows` | Paneller arasında gezin |
| `Ctrl + Alt + Shift + Arrows` | Panelleri yeniden boyutlandır |

### Pencereler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yeni pencere |
| `Prefix + k` | Pencereyi sonlandır |
| `Prefix + r` | Pencereyi yeniden adlandır |
| `Alt + 1-9` | Belirli pencereye git |
| `Alt + Arrow Left/Right` | Pencereler arasında gezin |
| `Alt + Shift + Arrow Left/Right` | Pencereyi sola/sağa taşı |

### Oturumlar

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yeni oturum |
| `Prefix + K` | Oturumu sonlandır |
| `Prefix + R` | Oturumu yeniden adlandır |
| `Prefix + N` | Sonraki oturum |
| `Prefix + P` | Önceki oturum |
| `Alt + Arrow Up/Down` | Oturumlar arasında gezin |
| `Prefix + s` | Oturumları listele |
| `Prefix + d` | Oturumdan ayrıl |

### Kopyalama modu (vi tarzı)

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopyalama moduna gir |
| `v` | Seçimi başlat (kopyalama modunda) |
| `y` | Seçimi kopyala (kopyalama modunda) |

### Genel

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + q` | Yapılandırmayı yeniden yükle |
| `Prefix + ?` | Tmux tuş bağlamalarını göster |
| `Prefix + :` | Komut istemi |

### Tmux düzen işlevleri

Bu işlevler bir Tmux oturumu içinde çalıştırılmalıdır.

| Komut | İşlev |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Düzenleyici, AI ve terminal ile geliştirme düzeni oluştur |
| `tdlm <ai> [<second_ai>]` | Alt dizin başına geliştirme düzeni oluştur |
| `tsl <count> <command>` | Çok panelli sürü düzeni oluştur |

## Ghostty Terminali

Ghostty terminali, Omarchy menüsü üzerinden _Kur > Terminal_ kullanılarak kurulur.

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Aşağıda yeni bölme |
| `Ctrl + Shift + O` | Yanında yeni bölme |
| `Ctrl + Alt + Arrows` | Bölmeler arasında gezin |
| `Super + Ctrl + Shift + Arrows` | Bölmeyi 10 satır yeniden boyutlandır |
| `Super + Ctrl + Shift + Alt + Arrows` | Bölmeyi 100 satır yeniden boyutlandır |
| `Ctrl + Shift + T` | Yeni sekme  |
| `Ctrl + Shift + Arrows` | Sekmeler arasında gezin |
| `Alt + Numbers` | Belirli sekmeye git |
| `Shift + Pg Up/Down` | Geçmişi kaydır |
| `Ctrl + Left mouse` | Bağlantıyı tarayıcıda aç |

## Dosya Yöneticisi

| Kısayol              | İşlev                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yola git                     |
| `Space`               | Dosyayı önizle (oklar gezinir) |
| `Alt + Up`       | Üst klasöre git        |

## Neovim (LazyVim ile)

### Gezinme

| Kısayol                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Komut seçeneklerini göster            |
| `Space Space`              | Bulanık aramayla dosya aç      |
| `Space E`                  | Kenar çubuğunu aç/kapat                  |
| `Space G G`                | Git kontrollerini göster               |
| `Space S G`                | Dosya içeriğinde ara             |
| `Ctrl + W W`               | Kenar çubuğu ve düzenleyici arasında atla |
| `Ctrl + Left/right arrow`  | Kenar çubuğunun boyutunu değiştir          |
| `Shift + H`                      | Soldaki dosya sekmesine git             |
| `Shift + L`                      | Sağdaki dosya sekmesine git            |
| `Space B D`                | Dosya sekmesini kapat                  |

### Kenar çubuğundayken

| Kısayol                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `A`                        | Üst dizinde yeni dosya ekle      |
| `Shift + A`                | Üst dizinde yeni alt dizin ekle    |
| `D`                        | Vurgulanan dosya/dizini sil     |
| `M`                        | Vurgulanan dosya/dizini taşı       |
| `R`                        | Vurgulanan dosya/dizini yeniden adlandır     |
| `?`                        | Tüm komutlar için yardımı göster      |

[LazyVim tarafından yapılandırılan tüm Neovim kısayollarına bakın](https://www.lazyvim.org/keymaps).

## Hızlı Emojiler

Tam bir emoji seçici göstermek için `Super + Ctrl + E` kullanabilirsiniz; bu, seçimi panoya koyar veya bu hızlı erişim seçeneklerini kullanabilirsiniz.

| Kısayol       | EM | İpucu       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gülümseme      |
| `Shift + CapsLock M C` | 😂 | ağlama        |
| `Shift + CapsLock M L` | 😍 | aşk       |
| `Shift + CapsLock M V` | ✌️ | zafer    |
| `Shift + CapsLock M H` | ❤️ | kalp      |
| `Shift + CapsLock M Y` | 👍 | evet        |
| `Shift + CapsLock M N` | 👎 | hayır         |
| `Shift + CapsLock M F` | 🖕 | siktir       |
| `Shift + CapsLock M W` | 🤞 | dilek       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | öpücük       |
| `Shift + CapsLock M E` | 🙄 | göz devirme    |
| `Shift + CapsLock M I` | 😉 | göz kırpma       |
| `Shift + CapsLock M P` | 🙏 | dua et |
| `Shift + CapsLock M D` | 🤤 | salya akıtma      |
| `Shift + CapsLock M M` | 💰 | para      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | kadeh kaldırma      |
| `Shift + CapsLock M O` |👌 | tamam |
| `Shift + CapsLock M G` |👋 | selamlama |
| `Shift + CapsLock M A` |💪 | kol |
| `Shift + CapsLock M B` |🤯 | patlama |

## Hızlı Tamamlamalar

| Kısayol       | Tamamlama       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Adınız (kurulumda girildiği gibi)  |
| `Shift + CapsLock Space E` | E-postanız (kurulumda girildiği gibi)  |

`~/.XCompose` dosyasını düzenleyerek kendinizden daha fazlasını ekleyebilirsiniz, ardından değişikliklerin alınması için terminalde `omarchy restart xcompose` çalıştırın.
