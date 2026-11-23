# Kısayol Tuşları

Tüm ana klavye bağlamalarını `Super + K` ile görebilirsiniz (Tmux bağlamaları `Super + Alt + K` ile ve Herdr bağlamaları `Super + Ctrl + K` ile).

## Kısayol tuşları nasıl düzenlenir

Her kısayol tuşu, değiştiricileri tarafından belirlenen bir düzlemde yer alır ve her düzlemin tek bir işi vardır. Kısayol tuşlarının birbirine karışmasını engelleyen budur ve bu sayede genellikle bir şeyin nerede olduğunu tahmin edebilirsiniz.

| Düzlem | Orada ne var | Örnekler |
| --- | --- | --- |
| `Super + key` | Sistem: pencereler, çalışma alanları, düzenler ve temel menüler | `Super + Space` Omarchy menüsü, `Super + W` pencereyi kapat, `Super + F` tam ekran |
| `Super + Shift + key` | Uygulamalar | `Super + Shift + B` tarayıcı, `Super + Shift + E` e-posta, `Super + Shift + N` editör |
| `Super + Ctrl + key` | Paneller ve sistem menüleri | `Super + Ctrl + A` ses, `Super + Ctrl + N` ağ, `Super + Ctrl + C` yakalama menüsü |
| `Super + Ctrl + Alt + key` | Hızlı eylemler ve bildirimler | `Super + Ctrl + Alt + T` saati göster, `Super + Ctrl + Alt + B` pil, `Super + Ctrl + Alt + C` ekran görüntüsü |

Bir kısayol tuşuna `Alt` eklemek size aynı şeyin bir varyantını verir, asla ilgisiz bir şeyi vermez:

- `Super + Shift + B` tarayıcıyı açar; `Super + Shift + Alt + B` gizli bir pencere açar
- `Super + Shift + E` e-postayı açar; `Super + Shift + Alt + E` yeni bir tane başlatır
- `Super + F` tam ekrana geçer; `Super + Alt + F` tam genişliğe geçer
- `Super + Ctrl + C` yakalama menüsünü açar; `Super + Ctrl + Alt + C` menüyü atlar ve ekran görüntüsü alır

Bir kısayol tuşu eklerken:

1. Ne yaptığına göre düzlemi seçin, sonra tuşu seçin.
2. Yer açmak için mevcut bir kısayol tuşunu taşımayın. Doğru düzlemde boş bir tuş bulun.
3. `Alt` tuşunu yalnızca onsuz kısayol tuşunun bir varyantı için kullanın.

Birkaç kısayol tuşu kullanışlı oldukları için bu kuralları bozar. Bir ok veya `Tab` ile `Shift`, bir uygulama açmak yerine taşır veya tersine çevirir ve `Print`, medya tuşları, `Alt + Tab` ve `Ctrl + Alt + Del` her yerde olduğu gibi çalışır. Bunlar istisnadır, kopyalanacak kalıplar değildir.

Varsayılan bir ayar size uymuyorsa (diyelim ki ekran görüntüleri için Windows'taki gibi `Super + Shift + S` istiyorsunuz), bunu `~/.config/hypr/bindings.lua` içinde yeniden bağlayın.

## Gezinme

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menüsü (uygulamalar ve diğer her şey) |
| `Super + Alt + Space` | Uygulama ızgarası |
| `Super + Escape` | Sistem menüsü (askıya al, yeniden başlat, vb.) |
| `Super + Ctrl + L` | Bilgisayarı kilitle |
| `Super + W` veya `Super + Q` | Pencereyi kapat |
| `Ctrl + Alt + Del` | Tüm pencereleri kapat |
| `Super + K` | Tüm kısayol tuşlarını göster |
| `Super + Alt + K` | tmux kısayol tuşlarını göster |
| `Super + Ctrl + K` | herdr kısayol tuşlarını göster |
| `Super + M` | Pencereyi dock'a küçült |
| `Super + T` | Pencereyi döşeme/yüzen arasında değiştir |
| `Super + J` | Pencere konumunu değiştir (yatay/dikey) |
| `Super + O` | Pencereyi sticky'n'floating içine çıkarmayı aç/kapat |
| `Super + L` | dwindle, scrolling ve floating düzenleri arasında geçiş yap |
| `Super + Alt + L` | Düzenler arasında ters yönde geçiş yap |
| `Super + P` | Pseudo pencere stilini aç/kapat (doğal ve esnetilmiş) |
| `Super + F` | Tam ekrana geç |
| `Super + Alt + F` | Tam genişliğe geç |
| `Super + Ctrl + F` | Pencere içinde tam ekrana geç |
| `Super + 1…9/0` | Odaklanılan monitörde belirli çalışma alanına atla (0, 10'dur) |
| `Super + Tab` | Odaklanılan monitörde sonraki çalışma alanına atla |
| `Super + Shift + Tab` | Odaklanılan monitörde önceki çalışma alanına atla |
| `Super + Ctrl + Tab` | Odaklanılan monitörde eski çalışma alanına atla |
| `Super + Shift + 1…9/0` | Pencereyi odaklanılan monitördeki çalışma alanına taşı |
| `Super + Shift + Alt + 1…9/0` | Pencereyi takip etmeden odaklanılan monitördeki çalışma alanına taşı |
| `Super + S` | Tam scratchpad'i aç/kapat |
| `Super + Alt + S` | Pencereyi tam scratchpad'e taşı |
| `Super + the key above Tab` (ABD düzenlerinde grave) | Quake konsolunu aç/kapat |
| `Super + Shift + the key above Tab` (ABD düzenlerinde grave) | Pencereyi Quake konsoluna taşı |
| `Super + Shift + Ctrl + Arrows` | Pencereyi o yöndeki monitöre taşı |
| `Super + Shift + Alt + Arrows` | Çalışma alanını o yöndeki monitöre taşı |
| `Super + Arrow` | Odağı ok yönündeki pencereye taşı, ekran kenarında o taraftaki monitöre geçerek |
| `Super + Shift + Arrow` | Pencereyi ok yönündeki başka bir pencereyle değiştir, o taraftaki monitördeki biri dahil |
| `Super + Minus` | Pencereyi sola genişlet |
| `Super + Equal` | Pencereyi sola küçült |
| `Super + Shift + Minus` | Pencereyi yukarı küçült |
| `Super + Shift + Equal` | Pencereyi aşağı genişlet |
| `Super + Alt + Minus/Equal` | Aynı yeniden boyutlandırma daha küçük adımlarla |
| `Super + Ctrl + Minus/Equal` | Aynı yeniden boyutlandırma daha büyük adımlarla |
| `Super + Alt + Home` | Pencere genişliğini kaydet |
| `Super + Home` | Kaydedilen pencere genişliğini geri yükle |
| `Super + Left Mouse` | Pencereyi sürükle |
| `Super + Right Mouse` | Pencereyi yeniden boyutlandır |
| `Super + Scroll Wheel` | Odaklanılan monitörde çalışma alanları arasında kaydır |
| `Super + G` | Pencere gruplandırmasını aç/kapat |
| `Super + Alt + G` | Pencereyi gruplandırmadan çıkar |
| `Super + Alt + Tab` | Gruplandırmadaki pencereler arasında geçiş yap |
| `Super + Alt + Shift + Tab` | Gruplandırmadaki pencereler arasında geriye doğru geçiş yap |
| `Super + Alt + Scroll Wheel` | Gruplandırmadaki pencereler arasında geçiş yap |
| `Super + Alt + 1/2/3/4/5` | Gruplandırmada belirli pencereye atla |
| `Super + Alt + Arrow` | Pencereyi ok yönünde gruplandırmaya taşı, o taraftaki monitördeki biri dahil |
| `Super + Ctrl + Left/Right` | Bir döşeme grubu içindeki pencereler arasında gezin |
| `Super + Ctrl + Z` | Ekrana yakınlaştır (daha fazla yakınlaştırma için tekrarla) |
| `Super + Ctrl + Alt + Z` | Ekrandan tamamen uzaklaştır |
| `Super + /` | Monitör ölçeklendirme seçeneklerinde ileri adım at |
| `Super + Alt + /` | Monitör ölçeklendirme seçeneklerinde geri adım at |
| `Alt + Tab` | Etkin çalışma alanındaki pencereler arasında ileri doğru geçiş yap |
| `Alt + Shift + Tab` | Etkin çalışma alanındaki pencereler arasında geriye doğru geçiş yap |
| `Ctrl + Alt + Tab` | Odağı monitörler arasında ileri doğru dolaştır |
| `Ctrl + Alt + Shift + Tab` | Odağı monitörler arasında geriye doğru dolaştır |
| `Super + I` | Girdi dilini değiştir (birden fazla düzen veya girdi yöntemiyle) |
| `Super + Shift + I` | Girdi dilini geri değiştir |

Bir touchpad'de, üç ve dört parmakla kaydırmalar çalışma alanlarını değiştirir, pencereleri taşır ve menüyü ve Quake konsolunu açar; hareketler için [klavye, fare ve trackpad](34-keyboard-mouse-trackpad.md) bölümüne bakın.

Yeniden boyutlandırma, klavyenizde üzerlerinde ne yazarsa yazsın, 0'ın sağındaki iki tuşu kullanır: ABD klavyelerinde `-` ve `=`, Danca ve İsveççede `+` ve `´`, Norveççede `+` ve `\`, Almancada `ß` ve `´`, İspanyolcada `'` ve `¡` ve Japoncada (JIS) `-` ve `^`. `Super + K` bunları klavyenizin yazdığı gibi listeler. JIS'de, `Super + ^`, `Super + Equal` iken, `Super + Shift + -` (ki `=` yazar) `Super + Shift + Minus` olur. Monitör ölçeklendirme ve parola yöneticisi `/` kullanır; `/` tuşunu yalnızca Shift ile yazan düzenlerde, çoğu Avrupa düzeninde olduğu gibi, bunun yerine sağ Shift'in solundaki tuşu kullanırlar (Danca ve Almancada `-`).

## Sistem kontrolleri

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Ses paneli |
| `Super + Ctrl + B` | Bluetooth paneli |
| `Super + Ctrl + N` | Wifi/ağ paneli |
| `Super + Ctrl + D` | Ekran paneli |
| `Super + Ctrl + P` | Güç paneli |
| `Super + Ctrl + X` | Agents paneli |
| `Super + Ctrl + Alt + D` | Takvim paneli |
| `Super + Ctrl + Alt + E` | Dünya saati paneli |
| `Super + Ctrl + 1-9` | Çubuk panelini konuma göre aç/kapat |
| `Super + Ctrl + S` | Paylaşım menüsü (LocalSend ile) |
| `Super + Ctrl + C` | Yakalama kontrolleri (ekran görüntüsü/-kaydı/seçici) |
| `Super + Ctrl + O` | Menüyü aç/kapat |
| `Super + Ctrl + H` | Donanım menüsü |
| `Super + Ctrl + E` | Emoji seçici |
| `Super + Ctrl + .` | Medyayı dönüştür |
| `Super + Shift + Ctrl + A` | Varsayılan agent'ınızı başlatın |
| `Power` tuşu | Sistem menüsü |
| `Super + Shift + Copilot` tuşu | Omarchy menüsü |

## Ayarlamalar

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimum ekran parlaklığı |
| `Shift + Brightness Down` | Minimum ekran parlaklığı |
| `Alt + Brightness Up/Down` | Hassas %1 parlaklık değişiklikleri |
| `Alt + Volume Up/Down` | Hassas %1 ses değişiklikleri |
| `Keyboard Brightness Up/Down` | Klavye arka ışığı daha parlak/daha loş |
| `Keyboard Backlight` | Klavye arka ışık seviyeleri arasında geçiş yap |
| `Ctrl + Brightness Up/Down` | Klavye arka ışığı daha parlak/daha loş, kendi tuşları olmayan klavyelerde |
| `Mic Mute` | Mikrofonu sessize al |
| `Shift + Mute` | Ses çıkışını değiştir |
| `Touchpad Toggle` | Touchpad'i aç veya kapat |
| `Display` tuşu | Çalışma alanı düzeninde geçiş yap |
| `Alt + Play` | Sonraki parça |
| `Alt + Shift + Play` | Önceki parça |

## Uygulamaları başlatma

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent yöneticisi) |
| `Super + Shift + Return` veya `Super + Shift + B` | Tarayıcı |
| `Super + Shift + Alt + B` | Tarayıcı (gizli/incognito) |
| `Super + Shift + F` | Dosya yöneticisi |
| `Super + Shift + Alt + F` | Terminalin cwd'sinde dosya yöneticisi |
| `Super + Shift + M` | Müzik (Spotify) |
| `Super + Shift + Alt + M` | Müzik (cliamp) |
| `Super + Shift + /` | Parola yöneticisi (1password) |
| `Super + Shift + Q` veya `Calculator` tuşu | Hesap Makinesi (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kurulduktan sonra) |
| `Super + Shift + T` | Etkinlik (btop) |
| `Super + Shift + N` | Editör (Plain veya seçtiğiniz varsayılan) |
| `Super + Shift + C` | Takvim ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-posta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Yeni e-posta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Varsayılan agent'ınız veya bir tane seçene kadar ChatGPT |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Mesajlaşma (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mesajlaşma (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mesajlaşma (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Yazı (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (yeni gönderi) |
| `Super + Shift + Y` | YouTube |

Bağlamaları `~/.config/hypr/bindings.lua` içinde değiştirin/ekleyin.

## Evrensel pano

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` destekleyen uygulamalarda tümünü seç |
| `Super + C` | Kopyala |
| `Super + X` | Kes (terminalde değil) |
| `Super + V` | Yapıştır |
| `Super + Ctrl + V` | Pano yöneticisi |

Genellikle Linux'ta, terminalde kopyala'n'yapıştır için `Ctrl + Shift + C/V` ve diğer her yerde yapmak için `Ctrl + C/V` gerekir. Bu Omarchy birleşik pano kısayol tuşları her yerde çalışır.

## Yakalama

| Kısayol Tuşu | İşlev |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekran görüntüsü |
| `Super + Ctrl + Alt + C` | Ekran görüntüsü (Print Screen tuşu olmayan klavyeler için aynı çekim) |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Alt + Print Screen` | Ekran kaydı |
| `Super + Shift + Ctrl + Alt + C` | Menüyü atlayarak sessiz ekran kaydı (durdurmak için tekrar basın) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Metni panoya çıkarma |
| `Super + Alt + [` | Kayıt sırasında webcam kaplamasını küçült |
| `Super + Alt + ]` | Kayıt sırasında webcam kaplamasını büyüt |
| `Alt + Shift + L` | Geçerli URL'yi web uygulamasından veya tarayıcıdan kopyala |
| `Alt + Shift + D` | Geçerli sayfadaki videoyu `~/Videos` konumuna indir |
| `Alt + Space` | Dikteyi başlat/durdur (_Kurulum > Varsayılanlar > Dikte_ gerekir) |
| `Right Alt` | Dikte etmek için basılı tut (_Kurulum > Varsayılanlar > Dikte_ gerekir) |

Ekran kayıtlarında, kısayol tuşu önce hangi sesi istediğinizi sorar, sonra kaydı başlatır. Durdurmak için tekrar basın. Ayrıntılar için [ekran görüntüleri ve kayıt](12-screenshots-recording.md) bölümüne bakın.

Tüm yakalama seçeneklerine Omarchy menüsünde (`Super + Space`) _Tetikleyici > Yakalama_ altından da erişilebilir.

## Bildirimler

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + ,` | En son bildirim üzerinde işlem yap: onu aç veya tek düğmesine bas, seçeneklerinden seç veya hiçbiri olmadığında onu kapat |
| `Super + Shift + ,` | Tüm bildirimleri kapat |
| `Super + Ctrl + ,` | Bildirimleri klavyeyle kontrol et |
| `Super + Alt + ,` | En son bildirimi kapat |
| `Super + Shift + Alt + ,` | Bildirim geçmişini aç |
| `Super + Ctrl + Alt + ,` | Bildirimleri sessize almayı aç/kapat |

## Stil

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yeni bir tema seç (ayrıca `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tema arka planını seç (ayrıca `Super + Ctrl + Space`) |
| `Super + Backspace` | Bir pencerede şeffaflığı aç/kapat |
| `Super + Ctrl + Backspace` | Tek pencere kare en-boy oranını aç/kapat |

Ekstra arka plan görüntüleri `~/.config/omarchy/backgrounds/<theme name>` içinde bulunur. Omarchy menüsünde _Yükle > Stil > Arka Plan_ üzerinden de kullanılabilir.

Tüm stil seçeneklerine Omarchy menüsünde (`Super + Space`) _Görünüm_ altından da erişilebilir.

## Aç/Kapat

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Boşta kilitlemeyi aç/kapat |
| `Super + Ctrl + Delete` | Dizüstü ekranını aç/kapat |
| `Super + Ctrl + Alt + Delete` | Dizüstü ekran yansıtmayı aç/kapat |
| `Super + Shift + Space` | Üst çubuğu aç/kapat |
| `Shift + Mute` | Sonraki ses çıkışına geç |
| `Shift + Play` | Sonraki medya kaynağına geç |
| `Super + Shift + Backspace` | Pencere boşluklarını aç/kapat |
| `Super + Ctrl + Alt + F` | Tam ekran masaüstünü aç/kapat (üst çubuk + pencere boşlukları) |

## Hatırlatıcılar

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Bir hatırlatıcı ayarla |
| `Super + Ctrl + Alt + R` | Tüm hatırlatıcıları gör |
| `Super + Ctrl + Shift + R` | Tüm hatırlatıcıları temizle |

## Bildirimler

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Saati bildirim olarak göster |
| `Super + Ctrl + Alt + B` | Pili bildirim olarak göster |
| `Super + Ctrl + Alt + W` | Hava durumunu bildirim olarak aç/kapat |

## Tmux

Ön ek tuşu `Ctrl + Space` tuşudur (`Ctrl + B` de çalışır). Bu bağlamaları `~/.config/tmux/tmux.conf` içinde değiştirebilirsiniz.

### Bölmeler

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Prefix + v` | Bölmeyi yana böl (dikey) |
| `Prefix + h` | Bölmeyi aşağı böl (yatay) |
| `Prefix + x` | Bölmeyi sonlandır |
| `Prefix + z` | Bölme yakınlaştırmasını aç/kapat (tam ekran) |
| `Alt + Enter` | Bölmeyi aşağı böl (ön eksiz) |
| `Alt + Shift + Enter` | Bölmeyi yana böl (ön eksiz) |
| `Alt + Escape` | Bölmeyi sonlandır (ön eksiz) |
| `Ctrl + Alt + Arrows` | Bölmeler arasında gezin |
| `Ctrl + Alt + Shift + Arrows` | Bölmeleri yeniden boyutlandır |

### Pencereler

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Prefix + c` | Yeni pencere |
| `Prefix + k` | Pencereyi sonlandır |
| `Prefix + r` | Pencereyi yeniden adlandır |
| `Alt + 1-9` | Belirli pencereye git |
| `Alt + Arrow Left/Right` | Pencereler arasında gezin |
| `Alt + Shift + Arrow Left/Right` | Pencereyi sola/sağa taşı |

### Oturumlar

| Kısayol Tuşu | İşlev |
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

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopyalama moduna gir |
| `v` | Seçimi başlat (kopyalama modunda) |
| `y` | Seçimi kopyala (kopyalama modunda) |

### Genel

| Kısayol Tuşu | İşlev |
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

Ghostty terminali, Omarchy menüsü üzerinden _Yükle > Terminal_ kullanılarak kurulur.

| Kısayol Tuşu | İşlev |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Aşağı yeni bölme |
| `Ctrl + Shift + O` | Yana yeni bölme |
| `Ctrl + Alt + Arrows` | Bölmeler arasında gezin |
| `Super + Ctrl + Shift + Arrows` | Bölmeyi 10 satır yeniden boyutlandır |
| `Super + Ctrl + Shift + Alt + Arrows` | Bölmeyi 100 satır yeniden boyutlandır |
| `Ctrl + Shift + T` | Yeni sekme |
| `Ctrl + Shift + Arrows` | Sekmeler arasında gezin |
| `Alt + Numbers` | Belirli sekmeye git |
| `Shift + Pg Up/Down` | Geçmişi kaydır |
| `Ctrl + Left mouse` | Bağlantıyı tarayıcıda aç |

## Dosya Yöneticisi

| Kısayol Tuşu | İşlev |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Yola git |
| `Space` | Dosyayı önizle (oklar gezinir) |
| `Alt + Up` | Üst klasöre çık |

## Neovim (w/ lazyvim)

### Gezinme

| Kısayol Tuşu | İşlev |
| ------------------------ | ------------------------------- |
| `Space` | Komut seçeneklerini göster |
| `Space Space` | Bulanık arama ile dosya aç |
| `Space E` | Kenar çubuğunu aç/kapat |
| `Space G G` | git kontrollerini göster |
| `Space S G` | Dosya içeriğini ara |
| `Ctrl + W W` | Kenar çubuğu ile editör arasında atla |
| `Ctrl + Left/right arrow` | Kenar çubuğunun boyutunu değiştir |
| `Shift + H` | Sol dosya sekmesine git |
| `Shift + L` | Sağ dosya sekmesine git |
| `Space B D` | Dosya sekmesini kapat |

### Kenar çubuğundayken

| Kısayol Tuşu | İşlev |
| ------------------------ | ------------------------------- |
| `A` | Üst dizine yeni dosya ekle |
| `Shift + A` | Üst dizine yeni alt dizin ekle |
| `D` | Vurgulanan dosya/dizini sil |
| `M` | Vurgulanan dosya/dizini taşı |
| `R` | Vurgulanan dosya/dizini yeniden adlandır |
| `?` | Tüm komutlar için yardımı göster |

[LazyVim tarafından yapılandırılan tüm Neovim kısayol tuşlarına bakın](https://www.lazyvim.org/keymaps).

## Hızlı Emojiler

Seçimi panoya koyacak eksiksiz bir emoji seçici göstermek için `Super + Ctrl + E` kullanabilir veya bu hızlı erişim seçeneklerini kullanabilirsiniz.

| Kısayol Tuşu | EM | İpucu |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gülümseme |
| `Shift + CapsLock M C` | 😂 | ağlama |
| `Shift + CapsLock M L` | 😍 | aşk |
| `Shift + CapsLock M V` | ✌️ | zafer |
| `Shift + CapsLock M H` | ❤️ | kalp |
| `Shift + CapsLock M Y` | 👍 | evet |
| `Shift + CapsLock M N` | 👎 | hayır |
| `Shift + CapsLock M F` | 🖕 | siktir |
| `Shift + CapsLock M W` | 🤞 | dilek |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | öpücük |
| `Shift + CapsLock M E` | 🙄 | göz devirme |
| `Shift + CapsLock M I` | 😉 | göz kırpma |
| `Shift + CapsLock M P` | 🙏 | dua |
| `Shift + CapsLock M D` | 🤤 | salya |
| `Shift + CapsLock M M` | 💰 | para |
| `Shift + CapsLock M X` | 🎉 | kutlama |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | kadeh kaldırma |
| `Shift + CapsLock M O` |👌 | tamam |
| `Shift + CapsLock M G` |👋 | selamlama |
| `Shift + CapsLock M A` |💪 | kol |
| `Shift + CapsLock M B` |🤯 | patlama |

## Hızlı Tamamlamalar

| Kısayol Tuşu | Tamamlama |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (uzun tire) |
| `Shift + CapsLock Space N` | Adınız (kurulumda girildiği gibi) |
| `Shift + CapsLock Space E` | E-postanız (kurulumda girildiği gibi) |

`~/.XCompose` dosyasını düzenleyerek kendinizden daha fazlasını ekleyebilir, ardından değişikliklerin alınması için terminalde `omarchy restart xcompose` komutunu çalıştırabilirsiniz.
