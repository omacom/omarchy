# Kısayol Tuşları

Tüm ana klavye bağlamalarını `Super + K` ile görebilirsiniz (Tmux bağlamaları `Super + Alt + K` ile ve Herdr bağlamaları `Super + Ctrl + K` ile).

## Kısayol tuşları nasıl düzenleniyor

Her kısayol tuşu, değiştiricileri tarafından belirlenen bir düzlemde durur ve her düzlemin tek bir işi vardır. Kısayol tuşlarının birbirine karışmasını engelleyen de budur ve bu sayede genellikle bir şeyin nerede olduğunu tahmin edebilirsiniz.

| Düzlem | Orada ne var | Örnekler |
| --- | --- | --- |
| `Super + key` | Sistem: pencereler, çalışma alanları, düzenler ve temel menüler | `Super + Space` Omarchy menüsü, `Super + W` pencereyi kapat, `Super + F` tam ekran |
| `Super + Shift + key` | Uygulamalar | `Super + Shift + B` tarayıcı, `Super + Shift + E` e-posta, `Super + Shift + N` düzenleyici |
| `Super + Ctrl + key` | Paneller ve sistem menüleri | `Super + Ctrl + A` ses, `Super + Ctrl + N` ağ, `Super + Ctrl + C` yakalama menüsü |
| `Super + Ctrl + Alt + key` | Hızlı eylemler ve uyarılar | `Super + Ctrl + Alt + T` saati göster, `Super + Ctrl + Alt + B` pil, `Super + Ctrl + Alt + C` ekran görüntüsü |

Bir kısayol tuşuna `Alt` eklemek size aynı şeyin bir varyantını verir, asla ilgisiz bir şeyi vermez:

- `Super + Shift + B` tarayıcıyı açar; `Super + Shift + Alt + B` gizli bir pencere açar
- `Super + Shift + E` e-postayı açar; `Super + Shift + Alt + E` yeni bir tane başlatır
- `Super + F` tam ekrana geçer; `Super + Alt + F` tam genişliğe geçer
- `Super + Ctrl + C` yakalama menüsünü açar; `Super + Ctrl + Alt + C` menüyü atlar ve ekran görüntüsü alır

Bir kısayol tuşu eklerken:

1. Yaptığı işe göre düzlemi seçin, sonra tuşu seçin.
2. Yer açmak için mevcut bir kısayol tuşunu taşımayın. Doğru düzlemde boş bir tuş bulun.
3. `Alt` tuşunu yalnızca onsuz kısayol tuşunun bir varyantı için kullanın.

Birkaç kısayol tuşu kullanışlı oldukları için bu kuralları çiğner. Bir ok veya `Tab` ile birlikte `Shift`, bir uygulama açmak yerine taşır veya tersine çevirir ve `Print`, medya tuşları, `Alt + Tab` ve `Ctrl + Alt + Del` her yerde olduğu gibi çalışır. Bunlar istisnadır, kopyalanacak kalıplar değildir.

Bir varsayılan size uymuyorsa (diyelim Windows'taki gibi ekran görüntüleri için `Super + Shift + S` istiyorsunuz), onu `~/.config/hypr/bindings.lua` içinde yeniden bağlayın.

## Gezinme

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüsü (uygulamalar ve diğer her şey)    |
| `Super + Alt + Space` | Uygulama ızgarası |
| `Super + Escape` | Sistem menüsü (askıya al, yeniden başlat vb.)  |
| `Super + Ctrl + L` | Bilgisayarı kilitle |
| `Super + W` veya `Super + Q` | Pencereyi kapat             |
| `Ctrl + Alt + Del` | Tüm pencereleri kapat |
| `Super + K` | Tüm kısayol tuşlarını göster |
| `Super + Alt + K` | tmux kısayol tuşlarını göster |
| `Super + Ctrl + K` | herdr kısayol tuşlarını göster |
| `Super + M` | Pencereyi dock'a küçült |
| `Super + T`               | Pencereyi döşeme/yüzen arasında değiştir             |
| `Super + J` | Pencere konumunu değiştir (yatay/dikey) |
| `Super + O`               | Pencereyi sticky'n'floating içine fırlatmayı aç/kapat |
| `Super + L`               | dwindle, scrolling ve floating düzenleri arasında geçiş yap |
| `Super + Alt + L`         | Düzenler arasında ters yönde geçiş yap |
| `Super + P`               | Pseudo pencere stilini değiştir (natural v stretch) |
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
| `Super + the key above Tab` (ABD düzenlerinde grave) | Quake konsolunu aç/kapat |
| `Super + Shift + the key above Tab` (ABD düzenlerinde grave) | Pencereyi Quake konsoluna taşı |
| `Super + Shift + Ctrl + Arrows` | Pencereyi o yöndeki monitöre taşı |
| `Super + Shift + Alt + Arrows` | Çalışma alanını o yöndeki monitöre taşı |
| `Super + Arrow`  | Odağı ok yönündeki pencereye taşı, ekran kenarında o taraftaki monitöre geçerek |
| `Super + Shift + Arrow`  | Pencereyi ok yönündeki başka bir pencereyle değiştir, o taraftaki monitördeki pencere dahil |
| `Super + Minus` | Pencereyi sola genişlet |
| `Super + Equal` | Pencereyi soldan küçült |
| `Super + Shift + Minus` | Pencereyi yukarı küçült |
| `Super + Shift + Equal` | Pencereyi aşağı genişlet |
| `Super + Alt + Minus/Equal` | Aynı boyutlandırma daha küçük adımlarla |
| `Super + Ctrl + Minus/Equal` | Aynı boyutlandırma daha büyük adımlarla |
| `Super + Alt + Home` | Pencere genişliğini kaydet |
| `Super + Home` | Kaydedilen pencere genişliğini geri yükle |
| `Super + Left Mouse` | Pencereyi sürükle |
| `Super + Right Mouse` | Pencereyi boyutlandır |
| `Super + Scroll Wheel` | Odaklanılan monitörde çalışma alanları arasında kaydır |
| `Super + G`               | Pencere gruplandırmayı aç/kapat      |
| `Super + Alt + G`               | Pencereyi gruplandırmanın dışına taşı      |
| `Super + Alt + Tab`               | Gruplandırma içindeki pencereler arasında geçiş yap      |
| `Super + Alt + Shift + Tab`               | Gruplandırma içindeki pencereler arasında geriye doğru geçiş yap      |
| `Super + Alt + Scroll Wheel` | Gruplandırma içindeki pencereler arasında geçiş yap |
| `Super + Alt + 1/2/3/4/5`               | Gruplandırmada belirli pencereye git      |
| `Super + Alt + Arrow`  | Pencereyi ok yönünde gruplandırmanın içine taşı, o taraftaki monitördeki pencere dahil |
| `Super + Ctrl + Left/Right`  | Bir döşeme grubu içindeki pencereler arasında geçiş yap |
| `Super + Ctrl + Z` | Ekrana yakınlaş (daha fazla yakınlaşmak için tekrarla) |
| `Super + Ctrl + Alt + Z` | Ekrandan tamamen uzaklaş |
| `Super + /` | Monitör ölçeklendirme seçeneklerinde ileri git |
| `Super + Alt + /` | Monitör ölçeklendirme seçeneklerinde geri git |
| `Alt + Tab` | Etkin çalışma alanındaki pencereler arasında ileri doğru geçiş yap |
| `Alt + Shift + Tab` | Etkin çalışma alanındaki pencereler arasında geriye doğru geçiş yap |
| `Ctrl + Alt + Tab`| Monitörler arasında odağı ileri doğru değiştir |
| `Ctrl + Alt + Shift + Tab`| Monitörler arasında odağı geriye doğru değiştir |
| `Super + I` | Giriş dilini değiştir (birden fazla düzen veya giriş yöntemi varsa) |
| `Super + Shift + I` | Giriş dilini geri değiştir |

Bir touchpad'de üç ve dört parmakla kaydırma hareketleri çalışma alanlarını değiştirir, pencereleri taşır ve menüyü ve Quake konsolunu açar; hareketler için [klavye, fare ve trackpad](34-keyboard-mouse-trackpad.md) bölümüne bakın.

Boyutlandırma, 0'ın hemen sağındaki iki tuşu kullanır, klavyenizde üzerlerinde ne yazarsa yazsın: ABD klavyelerinde `-` ve `=`, Danimarka ve İsveç klavyelerinde `+` ve `´`, Norveç klavyelerinde `+` ve `\`, Alman klavyelerinde `ß` ve `´`, İspanyol klavyelerinde `'` ve `¡` ve Japon (JIS) klavyelerinde `-` ve `^`. `Super + K` bunları klavyenizin üzerinde yazdığı gibi listeler. JIS'te `Super + ^`, `Super + Equal` demektir; `=` yazan `Super + Shift + -` ise `Super + Shift + Minus` demektir. Monitör ölçeklendirme ve parola yöneticisi `/` kullanır; çoğu Avrupa düzeninde olduğu gibi `/` tuşunu yalnızca Shift ile yazan düzenlerde, bunun yerine sağ Shift'in solundaki tuşu kullanırlar (Danimarka ve Alman düzenlerinde `-`).

## Sistem kontrolleri

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ses paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wifi/ağ paneli    |
| `Super + Ctrl + D`           | Ekran paneli    |
| `Super + Ctrl + P`           | Güç paneli    |
| `Super + Ctrl + X`           | Agents paneli    |
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
| `Power` tuşu | Sistem menüsü |
| `Super + Shift + Copilot` tuşu | Omarchy menüsü |

## Ayarlamalar

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimum ekran parlaklığı |
| `Shift + Brightness Down` | Minimum ekran parlaklığı |
| `Alt + Brightness Up/Down` | Hassas %1 parlaklık değişiklikleri |
| `Alt + Volume Up/Down` | Hassas %1 ses seviyesi değişiklikleri |
| `Keyboard Brightness Up/Down` | Klavye arka ışığı daha parlak/daha sönük |
| `Keyboard Backlight` | Klavye arka ışık seviyeleri arasında geçiş yap |
| `Ctrl + Brightness Up/Down` | Kendi tuşları olmayan klavyelerde klavye arka ışığı daha parlak/daha sönük |
| `Mic Mute` | Mikrofonu sustur |
| `Shift + Mute` | Ses çıkışını değiştir |
| `Touchpad Toggle` | Touchpad'i aç veya kapat |
| `Display` tuşu | Çalışma alanı düzenini değiştir |
| `Alt + Play` | Sonraki parça |
| `Alt + Shift + Play` | Önceki parça |

## Uygulamaları başlatma

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (ajan yöneticisi) |
| `Super + Shift + Return` veya `Super + Shift + B`  | Tarayıcı    |
| `Super + Shift + Alt + B`           | Tarayıcı (gizli/incognito)    |
| `Super + Shift + F`           | Dosya yöneticisi    |
| `Super + Shift + Alt + F`           | Terminalin cwd'sindeki dosya yöneticisi    |
| `Super + Shift + M`           | Müzik (Spotify)    |
| `Super + Shift + Alt + M`           | Müzik (cliamp)    |
| `Super + Shift + /`           | Parola yöneticisi (1password)    |
| `Super + Shift + Q` veya `Calculator` tuşu  | Hesap Makinesi (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kurulduktan sonra)    |
| `Super + Shift + T`           | Etkinlik (btop)    |
| `Super + Shift + N`           | Düzenleyici (Plain veya seçtiğiniz varsayılan)  |
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
| `Super + Shift + W`           | Yazı (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (yeni gönderi) |
| `Super + Shift + Y`           | YouTube |

Bağlamaları `~/.config/hypr/bindings.lua` içinde değiştirin/ekleyin.

## Evrensel pano

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` destekleyen uygulamalarda tümünü seç    |
| `Super + C`           | Kopyala    |
| `Super + X`           | Kes (terminalde değil)    |
| `Super + V`           | Yapıştır    |
| `Super + Ctrl + V`           | Pano yöneticisi    |

Genellikle Linux'ta, terminalde kopyalayıp yapıştırmak için `Ctrl + Shift + C/V` tuşlarına ve diğer her yerde bunu yapmak için `Ctrl + C/V` tuşlarına ihtiyacınız olur. Bu Omarchy birleşik pano kısayol tuşları her yerde çalışır.

## Yakalama

| Kısayol Tuşu              | İşlev                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekran görüntüsü                      |
| `Super + Ctrl + Alt + C`            | Ekran görüntüsü (aynı çekim, Print Screen tuşu olmayan klavyeler için) |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Alt + Print Screen`            | Ekran kaydı                     |
| `Super + Shift + Ctrl + Alt + C` | Sessiz ekran kaydı, menüyü atlayarak (durdurmak için tekrar basın) |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Panoya metin çıkarma |
| `Super + Alt + [` | Kayıt sırasında webcam katmanını küçült |
| `Super + Alt + ]` | Kayıt sırasında webcam katmanını büyüt |
| `Alt + Shift + L` | Webapp veya tarayıcıdan geçerli URL'yi kopyala |
| `Alt + Shift + D` | Geçerli sayfadaki videoyu `~/Videos` klasörüne indir |
| `Alt + Space` | Dikteyi başlat/durdur (_Setup > Defaults > Dictation_ gerektirir) |
| `Right Alt` | Dikte etmek için basılı tut (_Setup > Defaults > Dictation_ gerektirir) |

Ekran kayıtlarında, kısayol tuşu önce hangi sesi istediğinizi sorar, sonra kaydı başlatır. Durdurmak için tekrar basın. Ayrıntılar için [ekran görüntüleri ve kayıt](12-screenshots-recording.md) bölümüne bakın.

Tüm yakalama seçeneklerine Omarchy menüsündeki (`Super + Space`) _Trigger > Capture_ altından da erişilebilir.

## Bildirimler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + ,` | En son bildirim üzerinde işlem yap: onu aç veya tek düğmesine bas, seçenekleri arasından seç veya hiçbiri yoksa kapat  |
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
| `Super + Ctrl + Backspace` | Tek pencerede kare en-boy oranını aç/kapat |

Ekstra arka plan görüntüleri `~/.config/omarchy/backgrounds/<theme name>` içinde bulunur. Omarchy menüsünde _Install > Style > Background_ yoluyla da kullanılabilir.

Tüm stil seçeneklerine Omarchy menüsünde (`Super + Space`) _Appearance_ altından da erişilebilir.

## Açma/Kapama

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Boştayken kilitlemeyi aç/kapat |
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
| `Super + Ctrl + R` | Bir hatırlatıcı ayarla  |
| `Super + Ctrl + Alt + R` | Tüm hatırlatıcıları gör  |
| `Super + Ctrl + Shift + R` | Tüm hatırlatıcıları temizle  |

## Uyarılar

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Saati bildirim olarak göster  |
| `Super + Ctrl + Alt + B` | Pili bildirim olarak göster  |
| `Super + Ctrl + Alt + W` | Hava durumunu bildirim olarak aç/kapat  |

## Tmux

Önek tuşu `Ctrl + Space` tuşudur (`Ctrl + B` de çalışır). Bu bağlamaları `~/.config/tmux/tmux.conf` içinde değiştirebilirsiniz.

### Bölmeler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bölmeyi yana böl (dikey) |
| `Prefix + h` | Bölmeyi aşağı böl (yatay) |
| `Prefix + x` | Bölmeyi sonlandır |
| `Prefix + z` | Bölme yakınlaştırmayı aç/kapat (tam ekran) |
| `Alt + Enter` | Bölmeyi aşağı böl (önek yok) |
| `Alt + Shift + Enter` | Bölmeyi yana böl (önek yok) |
| `Alt + Escape` | Bölmeyi sonlandır (önek yok) |
| `Ctrl + Alt + Arrows` | Bölmeler arasında geçiş yap |
| `Ctrl + Alt + Shift + Arrows` | Bölmeleri boyutlandır |

### Pencereler

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yeni pencere |
| `Prefix + k` | Pencereyi sonlandır |
| `Prefix + r` | Pencereyi yeniden adlandır |
| `Alt + 1-9` | Belirli pencereye git |
| `Alt + Arrow Left/Right` | Pencereler arasında geçiş yap |
| `Alt + Shift + Arrow Left/Right` | Pencereyi sola/sağa taşı |

### Oturumlar

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yeni oturum |
| `Prefix + K` | Oturumu sonlandır |
| `Prefix + R` | Oturumu yeniden adlandır |
| `Prefix + N` | Sonraki oturum |
| `Prefix + P` | Önceki oturum |
| `Alt + Arrow Up/Down` | Oturumlar arasında geçiş yap |
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
| `tdl <ai> [<second_ai>]` | Düzenleyici, AI ve terminal ile geliştirme düzeni oluştur |
| `tdlm <ai> [<second_ai>]` | Alt dizin başına geliştirme düzeni oluştur |
| `tsl <count> <command>` | Çok bölmeli swarm düzeni oluştur |

## Ghostty Terminali

Ghostty terminali, Omarchy menüsü üzerinden _Install > Terminal_ kullanılarak kurulur.

| Kısayol Tuşu                  | İşlev              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Aşağı yeni bölme |
| `Ctrl + Shift + O` | Yana yeni bölme |
| `Ctrl + Alt + Arrows` | Bölmeler arasında geçiş yap |
| `Super + Ctrl + Shift + Arrows` | Bölmeyi 10 satır boyutlandır |
| `Super + Ctrl + Shift + Alt + Arrows` | Bölmeyi 100 satır boyutlandır |
| `Ctrl + Shift + T` | Yeni sekme  |
| `Ctrl + Shift + Arrows` | Sekmeler arasında geçiş yap |
| `Alt + Numbers` | Belirli sekmeye git |
| `Shift + Pg Up/Down` | Geçmişi kaydır |
| `Ctrl + Left mouse` | Bağlantıyı tarayıcıda aç |

## Dosya Yöneticisi

| Kısayol Tuşu              | İşlev                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yola git                     |
| `Space`               | Dosyayı önizle (oklar gezindir) |
| `Alt + Up`       | Üst klasöre çık        |

## Neovim (w/ lazyvim)

### Gezinme

| Kısayol Tuşu                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Komut seçeneklerini göster            |
| `Space Space`              | Bulanık aramayla dosya aç      |
| `Space E`                  | Kenar çubuğunu aç/kapat                  |
| `Space G G`                | git kontrollerini göster               |
| `Space S G`                | Dosya içeriğini ara             |
| `Ctrl + W W`               | Kenar çubuğu ve düzenleyici arasında geçiş yap |
| `Ctrl + Left/right arrow`  | Kenar çubuğunun boyutunu değiştir          |
| `Shift + H`                      | Sol dosya sekmesine git             |
| `Shift + L`                      | Sağ dosya sekmesine git            |
| `Space B D`                | Dosya sekmesini kapat                  |

### Kenar çubuğundayken

| Kısayol Tuşu                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `A`                        | Üst dizinde yeni dosya ekle      |
| `Shift + A`                | Üst dizinde yeni alt dizin ekle    |
| `D`                        | Vurgulanan dosya/dizini sil     |
| `M`                        | Vurgulanan dosya/dizini taşı       |
| `R`                        | Vurgulanan dosya/dizini yeniden adlandır     |
| `?`                        | Tüm komutlar için yardımı göster      |

[LazyVim tarafından yapılandırılan tüm Neovim kısayol tuşlarına bakın](https://www.lazyvim.org/keymaps).

## Hızlı Emojiler

Seçimi panoya koyacak eksiksiz bir emoji seçici göstermek için `Super + Ctrl + E` kullanabilir veya bu hızlı erişim seçeneklerini kullanabilirsiniz.

| Kısayol Tuşu       | EM | İpucu       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Hızlı Tamamlamalar

| Kısayol Tuşu       | Tamamlama       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (uzun tire)   |
| `Shift + CapsLock Space N` | Adınız (kurulumda girildiği gibi)  |
| `Shift + CapsLock Space E` | E-postanız (kurulumda girildiği gibi)  |

`~/.XCompose` dosyasını düzenleyerek kendinizinkilerden daha fazlasını ekleyebilir, ardından değişikliklerin alınması için terminalde `omarchy restart xcompose` çalıştırabilirsiniz.
