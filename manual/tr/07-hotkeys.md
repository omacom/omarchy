# Kısayol Tuşları

Tüm ana klavye bağlamalarını `Super + K` ile görebilirsin (Tmux bağlamalarını `Super + Alt + K` ve Herdr bağlamalarını `Super + Ctrl + K` ile).

## Kısayol tuşları nasıl düzenleniyor

Her kısayol tuşu, değiştiricileri tarafından belirlenen bir düzlemde durur ve her düzlemin tek bir işi vardır. Kısayol tuşlarının birbirine karışmasını engelleyen şey budur ve genellikle bir şeyin nerede olduğunu tahmin edebileceğin anlamına gelir.

| Düzlem | Orada ne var | Örnekler |
| --- | --- | --- |
| `Super + key` | Sistem: pencereler, çalışma alanları, düzenler ve temel menüler | `Super + Space` Omarchy menüsü, `Super + W` pencereyi kapat, `Super + F` tam ekran |
| `Super + Shift + key` | Uygulamalar | `Super + Shift + B` tarayıcı, `Super + Shift + E` e-posta, `Super + Shift + N` editör |
| `Super + Ctrl + key` | Paneller ve sistem menüleri | `Super + Ctrl + A` ses, `Super + Ctrl + N` ağ, `Super + Ctrl + C` yakalama menüsü |
| `Super + Ctrl + Alt + key` | Hızlı eylemler ve duyurular | `Super + Ctrl + Alt + T` saati göster, `Super + Ctrl + Alt + B` pil, `Super + Ctrl + Alt + C` ekran görüntüsü |

Bir kısayol tuşuna `Alt` eklemek sana aynı şeyin bir varyantını verir, asla alakasız bir şey vermez:

- `Super + Shift + B` tarayıcıyı açar; `Super + Shift + Alt + B` gizli bir pencere açar
- `Super + Shift + E` e-postayı açar; `Super + Shift + Alt + E` yeni bir tane başlatır
- `Super + F` tam ekrana geçer; `Super + Alt + F` tam genişliğe geçer
- `Super + Ctrl + C` yakalama menüsünü açar; `Super + Ctrl + Alt + C` menüyü atlar ve bir ekran görüntüsü alır

Kısayol tuşu eklerken:

1. Ne yaptığına göre düzlemi seç, sonra tuşu seç.
2. Yer açmak için mevcut bir kısayol tuşunu taşıma. Doğru düzlemde boş bir tuş bul.
3. `Alt` tuşunu yalnızca onsuz kısayol tuşunun bir varyantı için kullan.

Birkaç kısayol tuşu rahat olduğu için bu kuralları çiğner. Bir ok veya `Tab` ile `Shift` bir uygulama açmak yerine taşır veya tersine çevirir ve `Print`, medya tuşları, `Alt + Tab` ve `Ctrl + Alt + Del` her yerde olduğu gibi çalışır. Bunlar istisnadır, kopyalanacak kalıplar değil.

Bir varsayılan sana uymuyorsa (diyelim Windows'taki gibi ekran görüntüleri için `Super + Shift + S` istiyorsun), onu `~/.config/hypr/bindings.lua` içinde yeniden bağla.

## Gezinme

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüsü (uygulamalar ve diğer her şey)    |
| `Super + Alt + Space` | Uygulama ızgarası |
| `Super + Escape` | Sistem menüsü (askıya al, yeniden başlat, vb.)  |
| `Super + Ctrl + L` | Bilgisayarı kilitle |
| `Super + W` or `Super + Q` | Pencereyi kapat             |
| `Ctrl + Alt + Del` | Tüm pencereleri kapat |
| `Super + K` | Tüm kısayol tuşlarını göster |
| `Super + Alt + K` | tmux kısayol tuşlarını göster |
| `Super + Ctrl + K` | herdr kısayol tuşlarını göster |
| `Super + M` | Pencereyi dock'a küçült |
| `Super + T`               | Pencereyi döşeme/yüzer arasında değiştir             |
| `Super + J` | Pencere konumunu değiştir (yatay/dikey) |
| `Super + O`               | Pencereyi sticky'n'floating olarak patlatmayı aç/kapat |
| `Super + L`               | dwindle, scrolling ve floating düzenleri arasında geçiş yap |
| `Super + Alt + L`         | Düzenler arasında ters yönde geçiş yap |
| `Super + P`               | Pseudo pencere stilini aç/kapat (natural v stretch) |
| `Super + F`                 | Tam ekrana geç              |
| `Super + Alt + F`                 | Tam genişliğe geç              |
| `Super + Ctrl + F`                 | Pencere içinde tam ekrana geç              |
| `Super + 1…9/0`         | Odaklanılan monitörde belirli çalışma alanına git (0, 10'dur) |
| `Super + Tab` | Odaklanılan monitörde sonraki çalışma alanına git |
| `Super + Shift + Tab` | Odaklanılan monitörde önceki çalışma alanına git |
| `Super + Ctrl + Tab` | Odaklanılan monitörde eski çalışma alanına git |
| `Super + Shift + 1…9/0` | Pencereyi odaklanılan monitördeki çalışma alanına taşı |
| `Super + Shift + Alt + 1…9/0` | Pencereyi odaklanılan monitördeki çalışma alanına takip etmeden taşı |
| `Super + S` | Tam scratchpad'i aç/kapat |
| `Super + Alt + S` | Pencereyi tam scratchpad'e taşı |
| `Super + Grave` | Quake konsolunu aç/kapat |
| `Super + Shift + Grave` | Pencereyi Quake konsoluna taşı |
| `Super + Shift + Ctrl + Arrows` | Pencereyi o yöndeki monitöre taşı |
| `Super + Shift + Alt + Arrows` | Çalışma alanını o yöndeki monitöre taşı |
| `Super + Arrow`  | Odağı ok yönündeki pencereye taşı, ekranın kenarında o taraftaki monitöre geçerek |
| `Super + Shift + Arrow`  | Pencereyi ok yönündeki başka bir pencereyle değiştir, o taraftaki monitördeki biri dahil |
| `Super + Minus` | Pencereyi sola genişlet |
| `Super + Equal` | Pencereyi sola küçült |
| `Super + Shift + Minus` | Pencereyi yukarı küçült |
| `Super + Shift + Equal` | Pencereyi aşağı genişlet |
| `Super + Alt + Minus/Equal` | Daha küçük adımlarla aynı yeniden boyutlandırma |
| `Super + Ctrl + Minus/Equal` | Daha büyük adımlarla aynı yeniden boyutlandırma |
| `Super + Alt + Home` | Pencere genişliğini kaydet |
| `Super + Home` | Kaydedilen pencere genişliğini geri yükle |
| `Super + Left Mouse` | Pencereyi sürükle |
| `Super + Right Mouse` | Pencereyi yeniden boyutlandır |
| `Super + Scroll Wheel` | Odaklanılan monitörde çalışma alanları arasında kaydır |
| `Super + G`               | Pencere gruplandırmayı aç/kapat      |
| `Super + Alt + G`               | Pencereyi gruplandırmanın dışına taşı      |
| `Super + Alt + Tab`               | Gruplandırma içindeki pencereler arasında geçiş yap      |
| `Super + Alt + Shift + Tab`               | Gruplandırma içindeki pencereler arasında geriye doğru geçiş yap      |
| `Super + Alt + Scroll Wheel` | Gruplandırma içindeki pencereler arasında geçiş yap |
| `Super + Alt + 1/2/3/4/5`               | Gruplandırmada belirli pencereye git      |
| `Super + Alt + Arrow`  | Pencereyi ok yönünde gruplandırmanın içine taşı, o taraftaki monitördeki biri dahil |
| `Super + Ctrl + Left/Right`  | Bir döşeme grubu içindeki pencereler arasında gezin |
| `Super + Ctrl + Z` | Ekrana yakınlaş (daha fazla yakınlaşmak için tekrarla) |
| `Super + Ctrl + Alt + Z` | Ekrandan tamamen uzaklaş |
| `Super + /` | Monitör ölçeklendirme seçeneklerinde ileri git |
| `Super + Alt + /` | Monitör ölçeklendirme seçeneklerinde geri git |
| `Alt + Tab` | Etkin çalışma alanındaki pencereler arasında ileri doğru geçiş yap |
| `Alt + Shift + Tab` | Etkin çalışma alanındaki pencereler arasında geriye doğru geçiş yap |
| `Ctrl + Alt + Tab`| Monitörler arasında odağı ileri doğru geçir |
| `Ctrl + Alt + Shift + Tab`| Monitörler arasında odağı geriye doğru geçir |
| `Super + I` | Girdi dilini değiştir (birden fazla düzen veya girdi yöntemi ile) |
| `Super + Shift + I` | Girdi dilini geri değiştir |

Dokunmatik yüzeyde, üç ve dört parmakla kaydırma hareketleri çalışma alanlarını değiştirir, pencereleri taşır ve menüyü ve Quake konsolunu açar; hareketler için [klavye, fare ve trackpad](34-keyboard-mouse-trackpad.md) bölümüne bak.

Yeniden boyutlandırma kısayolları, klavyede yazan karakterlerden bağımsız olarak fiziksel `code:20` ve `code:21` tuşlarını (XKB `<AE11>` ve `<AE12>`) kullanır. ABD klavyelerinde bu tuşlar `-` ve `=`; Japon (JIS) klavyelerinde `-` ve `^`; İspanyol klavyelerinde `'` ve `¡` tuşlarıdır. JIS'te, `Super + ^`, `Super + Equal` demektir, oysa `Super + Shift + -` (`=` yazar) `Super + Shift + Minus` demektir.

## Sistem kontrolleri

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ses paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/ağ paneli    |
| `Super + Ctrl + D`           | Ekran paneli    |
| `Super + Ctrl + P`           | Güç paneli    |
| `Super + Ctrl + X`           | Agents paneli    |
| `Super + Ctrl + Alt + X`           | Yerel modeller paneli    |
| `Super + Ctrl + Alt + D`           | Takvim paneli    |
| `Super + Ctrl + Alt + E`           | Dünya saati paneli    |
| `Super + Ctrl + 1-9`           | Konuma göre çubuk panelini aç/kapat    |
| `Super + Ctrl + S` | Paylaşım menüsü (LocalSend ile) |
| `Super + Ctrl + C` | Yakalama kontrolleri (ekran görüntüsü/-kaydı/seçici) |
| `Super + Ctrl + O` | Menüyü aç/kapat |
| `Super + Ctrl + H` | Donanım menüsü |
| `Super + Ctrl + E` | Emoji seçici |
| `Super + Ctrl + .` | Medyayı dönüştür |
| `Super + Shift + Ctrl + A` | Bir AI agent seç |
| `Power` key | Sistem menüsü |
| `Super + Shift + Copilot` key | Omarchy menüsü |

## Ayarlamalar

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimum ekran parlaklığı |
| `Shift + Brightness Down` | Minimum ekran parlaklığı |
| `Alt + Brightness Up/Down` | Hassas %1 parlaklık değişiklikleri |
| `Alt + Volume Up/Down` | Hassas %1 ses seviyesi değişiklikleri |
| `Keyboard Brightness Up/Down` | Klavye arka ışığı daha parlak/daha loş |
| `Keyboard Backlight` | Klavye arka ışık seviyeleri arasında geçiş yap |
| `Ctrl + Brightness Up/Down` | Kendi tuşları olmayan klavyelerde klavye arka ışığı daha parlak/daha loş |
| `Mic Mute` | Mikrofonu sessize al |
| `Shift + Mute` | Ses çıkışını değiştir |
| `Touchpad Toggle` | Dokunmatik yüzeyi aç veya kapat |
| `Display` key | Çalışma alanı düzeninde geçiş yap |
| `Alt + Play` | Sonraki parça |
| `Alt + Shift + Play` | Önceki parça |

## Uygulamaları başlatma

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent yöneticisi) |
| `Super + Shift + Return` or `Super + Shift + B`  | Tarayıcı    |
| `Super + Shift + Alt + B`           | Tarayıcı (gizli/incognito)    |
| `Super + Shift + F`           | Dosya yöneticisi    |
| `Super + Shift + Alt + F`           | Terminalin cwd'sindeki dosya yöneticisi    |
| `Super + Shift + M`           | Müzik (Spotify)    |
| `Super + Shift + Alt + M`           | Müzik (cliamp)    |
| `Super + Shift + /`           | Parola yöneticisi (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Hesap Makinesi (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kurulduktan sonra)    |
| `Super + Shift + T`           | Etkinlik (btop)    |
| `Super + Shift + N`           | Editör (Plain veya seçtiğin varsayılan)  |
| `Super + Shift + C`           | Takvim ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-posta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yeni e-posta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

Bağlamaları `~/.config/hypr/bindings.lua` içinde değiştir/ekle.

## Evrensel pano

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` destekleyen uygulamalarda tümünü seç    |
| `Super + C`           | Kopyala    |
| `Super + X`           | Kes (terminalde değil)    |
| `Super + V`           | Yapıştır    |
| `Super + Ctrl + V`           | Pano yöneticisi    |

Genellikle Linux'ta, terminalde kopyalayıp yapıştırmak için `Ctrl + Shift + C/V` ve diğer her yerde yapmak için `Ctrl + C/V` tuşlarına ihtiyacın olur. Bu Omarchy birleşik pano kısayol tuşları her yerde çalışır.

## Yakalama

| Kısayol Tuşu              | İşlev                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekran görüntüsü                      |
| `Super + Ctrl + Alt + C`            | Ekran görüntüsü (aynı çekim, Print Screen tuşu olmayan klavyeler için) |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Alt + Print Screen`            | Ekran kaydı                     |
| `Super + Shift + Ctrl + Alt + C` | Sessiz ekran kaydı, menüyü atlayarak (durdurmak için tekrar bas) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Metin çıkarmayı panoya kopyala |
| `Super + Alt + [` | Kayıt sırasında webcam katmanını küçült |
| `Super + Alt + ]` | Kayıt sırasında webcam katmanını büyüt |
| `Alt + Shift + L` | Web uygulamasından veya tarayıcıdan geçerli URL'yi kopyala |
| `Alt + Shift + D` | Geçerli sayfadaki videoyu `~/Videos` konumuna indir |
| `Alt + Space` | Dikteyi başlat/durdur (_Setup > Defaults > Dictation_ gerektirir) |
| `Right Alt` | Dikte etmek için basılı tut (_Setup > Defaults > Dictation_ gerektirir) |

Ekran kayıtlarında, kısayol tuşu önce hangi sesi istediğini sorar, sonra kaydı başlatır. Durdurmak için tekrar bas. Ayrıntılar için [ekran görüntüleri ve kayıt](12-screenshots-recording.md) bölümüne bak.

Tüm yakalama seçeneklerine Omarchy menüsünde (`Super + Space`) _Trigger > Capture_ altında da erişilebilir.

## Bildirimler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + ,` | En son bildirim üzerinde işlem yap: onu aç veya tek düğmesine bas, seçeneklerinden birini seç veya hiçbiri yoksa onu kapat  |
| `Super + Shift + ,` | Tüm bildirimleri kapat |
| `Super + Ctrl + ,` | Bildirimleri klavyeyle kontrol et  |
| `Super + Alt + ,` | En son bildirimi kapat  |
| `Super + Shift + Alt + ,` | Bildirim geçmişini aç  |
| `Super + Ctrl + Alt + ,` | Bildirimleri sessize almayı aç/kapat  |

## Stil

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yeni bir tema seç (ayrıca `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tema arka planını seç (ayrıca `Super + Ctrl + Space`) |
| `Super + Backspace` | Bir pencerede şeffaflığı aç/kapat |
| `Super + Ctrl + Backspace` | Tek pencere kare en-boy oranını aç/kapat |

Ekstra arka plan görüntüleri `~/.config/omarchy/backgrounds/<theme name>` içinde bulunur. Omarchy menüsünde _Install > Style > Background_ yoluyla da kullanılabilir.

Tüm stil seçeneklerine Omarchy menüsünde (`Super + Space`) _Appearance_ altında da erişilebilir.

## Aç/Kapat

| Kısayol Tuşu                  | İşlev              |
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

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Hatırlatıcı ayarla  |
| `Super + Ctrl + Alt + R` | Tüm hatırlatıcıları gör  |
| `Super + Ctrl + Shift + R` | Tüm hatırlatıcıları temizle  |

## Duyurular

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Saati bildirim olarak göster  |
| `Super + Ctrl + Alt + B` | Pili bildirim olarak göster  |
| `Super + Ctrl + Alt + W` | Hava durumunu bildirim olarak göstermeyi aç/kapat  |

## Tmux

Önek tuşu `Ctrl + Space` tuşudur (`Ctrl + B` de çalışır). Bu bağlamaları `~/.config/tmux/tmux.conf` içinde değiştirebilirsin.

### Bölmeler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bölmeyi yanına böl (dikey) |
| `Prefix + h` | Bölmeyi altına böl (yatay) |
| `Prefix + x` | Bölmeyi sonlandır |
| `Prefix + z` | Bölme yakınlaştırmasını aç/kapat (tam ekran) |
| `Alt + Enter` | Bölmeyi altına böl (önek yok) |
| `Alt + Shift + Enter` | Bölmeyi yanına böl (önek yok) |
| `Alt + Escape` | Bölmeyi sonlandır (önek yok) |
| `Ctrl + Alt + Arrows` | Bölmeler arasında gezin |
| `Ctrl + Alt + Shift + Arrows` | Bölmeleri yeniden boyutlandır |

### Pencereler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yeni pencere |
| `Prefix + k` | Pencereyi sonlandır |
| `Prefix + r` | Pencereyi yeniden adlandır |
| `Alt + 1-9` | Belirli pencereye git |
| `Alt + Arrow Left/Right` | Pencereler arasında gezin |
| `Alt + Shift + Arrow Left/Right` | Pencereyi sola/sağa taşı |

### Oturumlar

| Kısayol Tuşu                  | İşlev              |
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

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopyalama moduna gir |
| `v` | Seçimi başlat (kopyalama modunda) |
| `y` | Seçimi kopyala (kopyalama modunda) |

### Genel

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + q` | Yapılandırmayı yeniden yükle |
| `Prefix + ?` | Tmux tuş bağlamalarını göster |
| `Prefix + :` | Komut istemi |

### Tmux düzen işlevleri

Bu işlevler bir Tmux oturumu içinde çalıştırılmalıdır.

| Komut | İşlev |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Editör, AI ve terminal ile geliştirme düzeni oluştur |
| `tdlm <ai> [<second_ai>]` | Alt dizin başına geliştirme düzeni oluştur |
| `tsl <count> <command>` | Çok bölmeli swarm düzeni oluştur |

## Ghostty Terminal

Ghostty terminali, Omarchy menüsü üzerinden _Install > Terminal_ kullanılarak kurulur.

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Aşağıya yeni bölme |
| `Ctrl + Shift + O` | Yanına yeni bölme |
| `Ctrl + Alt + Arrows` | Bölmeler arasında gezin |
| `Super + Ctrl + Shift + Arrows` | Bölmeyi 10 satır yeniden boyutlandır |
| `Super + Ctrl + Shift + Alt + Arrows` | Bölmeyi 100 satır yeniden boyutlandır |
| `Ctrl + Shift + T` | Yeni sekme  |
| `Ctrl + Shift + Arrows` | Sekmeler arasında gezin |
| `Alt + Numbers` | Belirli sekmeye git |
| `Shift + Pg Up/Down` | Geçmişi kaydır |
| `Ctrl + Left mouse` | Bağlantıyı tarayıcıda aç |

## Dosya Yöneticisi

| Kısayol Tuşu              | İşlev                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yola git                     |
| `Space`               | Dosyayı önizle (oklar gezinir) |
| `Alt + Up`       | Üst klasöre git        |

## Neovim (lazyvim ile)

### Gezinme

| Kısayol Tuşu                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Komut seçeneklerini göster            |
| `Space Space`              | Bulanık arama ile dosya aç      |
| `Space E`                  | Kenar çubuğunu aç/kapat                  |
| `Space G G`                | git kontrollerini göster               |
| `Space S G`                | Dosya içeriğini ara             |
| `Ctrl + W W`               | Kenar çubuğu ve editör arasında atla |
| `Ctrl + Left/right arrow`  | Kenar çubuğunun boyutunu değiştir          |
| `Shift + H`                      | Sol dosya sekmesine git             |
| `Shift + L`                      | Sağ dosya sekmesine git            |
| `Space B D`                | Dosya sekmesini kapat                  |

### Kenar çubuğundayken

| Kısayol Tuşu                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `A`                        | Üst dizine yeni dosya ekle      |
| `Shift + A`                | Üst dizine yeni alt dizin ekle    |
| `D`                        | Vurgulanan dosyayı/dizini sil     |
| `M`                        | Vurgulanan dosyayı/dizini taşı       |
| `R`                        | Vurgulanan dosyayı/dizini yeniden adlandır     |
| `?`                        | Tüm komutlar için yardımı göster      |

[LazyVim tarafından yapılandırılan tüm Neovim kısayol tuşlarına bak](https://www.lazyvim.org/keymaps).

## Hızlı Emojiler

Seçimi panoya koyacak eksiksiz bir emoji seçici göstermek için `Super + Ctrl + E` kullanabilirsin veya bu hızlı erişim seçeneklerini kullanabilirsin.

| Kısayol Tuşu       | EM | İpucu       |
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
| `Shift + CapsLock M P` | 🙏 | dua |
| `Shift + CapsLock M D` | 🤤 | salya      |
| `Shift + CapsLock M M` | 💰 | para      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | kadeh kaldırma      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | selamlama |
| `Shift + CapsLock M A` |💪 | kol |
| `Shift + CapsLock M B` |🤯 | patlama |

## Hızlı Tamamlamalar

| Kısayol Tuşu       | Tamamlama       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Adın (kurulumda girildiği gibi)  |
| `Shift + CapsLock Space E` | E-postan (kurulumda girildiği gibi)  |

`~/.XCompose` dosyasını düzenleyerek kendininkilerden daha fazlasını ekleyebilirsin, sonra değişikliklerin alınması için terminalde `omarchy restart xcompose` çalıştır.
