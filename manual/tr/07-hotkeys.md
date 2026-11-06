# Kısayol Tuşları

Tüm ana klavye bağlamalarını `Super + K` ile görebilirsiniz (Tmux bağlamaları `Super + Alt + K` ile ve Herdr bağlamaları `Super + Ctrl + K` ile).

## Kısayollar nasıl düzenleniyor

Her kısayol, değiştiricileri tarafından belirlenen bir düzlemde durur ve her düzlemin tek bir işi vardır. Kısayolların birbirine karışmasını engelleyen budur ve bu, genellikle bir şeyin nerede olduğunu tahmin edebileceğiniz anlamına gelir.

| Düzlem | Orada ne var | Örnekler |
| --- | --- | --- |
| `Super + key` | Sistem: pencereler, çalışma alanları, düzenler ve temel menüler | `Super + Space` Omarchy menüsü, `Super + W` pencereyi kapat, `Super + F` tam ekran |
| `Super + Shift + key` | Uygulamalar | `Super + Shift + B` tarayıcı, `Super + Shift + E` e-posta, `Super + Shift + N` editör |
| `Super + Ctrl + key` | Paneller ve sistem menüleri | `Super + Ctrl + A` ses, `Super + Ctrl + N` ağ, `Super + Ctrl + C` yakalama menüsü |
| `Super + Ctrl + Alt + key` | Hızlı eylemler ve duyurular | `Super + Ctrl + Alt + T` saati göster, `Super + Ctrl + Alt + B` pil, `Super + Ctrl + Alt + C` ekran görüntüsü |

Bir kısayola `Alt` eklemek size aynı şeyin bir varyantını verir, asla alakasız bir şeyi değil:

- `Super + Shift + B` tarayıcıyı açar; `Super + Shift + Alt + B` gizli bir pencere açar
- `Super + Shift + E` e-postayı açar; `Super + Shift + Alt + E` yeni bir tane başlatır
- `Super + F` tam ekrana geçer; `Super + Alt + F` tam genişliğe geçer
- `Super + Ctrl + C` yakalama menüsünü açar; `Super + Ctrl + Alt + C` menüyü atlar ve bir ekran görüntüsü alır

Bir kısayol eklerken:

1. Ne yaptığına göre düzlemi seçin, sonra tuşu seçin.
2. Yer açmak için mevcut bir kısayolu taşımayın. Doğru düzlemde boş bir tuş bulun.
3. `Alt` tuşunu yalnızca onsuz kısayolun bir varyantı için kullanın.

Birkaç kısayol kullanışlı oldukları için bu kuralları çiğner. Bir ok veya `Tab` ile `Shift`, bir uygulama açmak yerine taşır veya tersine çevirir ve `Print`, medya tuşları, `Alt + Tab` ve `Ctrl + Alt + Del` her yerde olduğu gibi çalışır. Bunlar istisnadır, kopyalanacak kalıplar değildir.

Bir varsayılan size uymuyorsa (diyelim ki Windows'taki gibi ekran görüntüleri için `Super + Shift + S` istiyorsunuz), onu `~/.config/hypr/bindings.lua` içinde yeniden bağlayın.

## Gezinme

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüsü (uygulamalar ve diğer her şey)    |
| `Super + Alt + Space` | Uygulama ızgarası |
| `Super + Escape` | Sistem menüsü (askıya al, yeniden başlat, vb.)  |
| `Super + Ctrl + L` | Bilgisayarı kilitle |
| `Super + W` or `Super + Q` | Pencereyi kapat             |
| `Ctrl + Alt + Del` | Tüm pencereleri kapat |
| `Super + T`               | Pencereyi döşeme/yüzen arasında değiştir             |
| `Super + J` | Pencere konumunu değiştir (yatay/dikey) |
| `Super + O`               | Açılır pencereyi yapışkan ve yüzen moda al/kapat |
| `Super + L`               | dwindle, scrolling ve floating düzenleri arasında geçiş yap |
| `Super + Alt + L`         | Düzenler arasında ters yönde geçiş yap |
| `Super + P`               | Sözde pencere stilini değiştir (doğal ve gerilmiş) |
| `Super + F`                 | Tam ekrana geç              |
| `Super + Alt + F`                 | Tam genişliğe geç              |
| `Super + Ctrl + F`                 | Pencere içinde tam ekrana geç              |
| `Super + 1/2/3/4`         | Odaklanılan monitörde belirli çalışma alanına git |
| `Super + Tab` | Odaklanılan monitörde sonraki çalışma alanına git |
| `Super + Shift + Tab` | Odaklanılan monitörde önceki çalışma alanına git |
| `Super + Ctrl + Tab` | Odaklanılan monitörde eski çalışma alanına git |
| `Super + Shift + 1/2/3/4` | Pencereyi odaklanılan monitördeki çalışma alanına taşı |
| `Super + Shift + Alt + 1/2/3/4` | Pencereyi odaklanılan monitördeki çalışma alanına takip etmeden taşı |
| `Super + S` | Tam scratchpad'i aç/kapat |
| `Super + Alt + S` | Pencereyi tam scratchpad'e taşı |
| `Super + Grave` | Quake konsolunu aç/kapat |
| `Super + Shift + Grave` | Pencereyi Quake konsoluna taşı |
| `Super + Shift + Ctrl + Arrows` | Pencereyi o yöndeki monitöre taşı |
| `Super + Shift + Alt + Arrows` | Çalışma alanını o yöndeki monitöre taşı |
| `Super + Arrow`  | Odağı ok yönündeki pencereye taşı, ekran kenarında o taraftaki monitöre geçerek |
| `Super + Shift + Arrow`  | Pencereyi ok yönündeki başka bir pencereyle değiştir, o taraftaki monitördeki dahil |
| `Super + Minus` | Pencereyi sola genişlet |
| `Super + Equal` | Pencereyi soldan küçült |
| `Super + Shift + Minus` | Pencereyi yukarı küçült |
| `Super + Shift + Equal` | Pencereyi aşağı genişlet |
| `Super + Alt + Minus/Equal` | Aynı yeniden boyutlandırma daha küçük adımlarla |
| `Super + Ctrl + Minus/Equal` | Aynı yeniden boyutlandırma daha büyük adımlarla |
| `Super + Alt + Home` | Pencere genişliğini kaydet |
| `Super + Home` | Kaydedilen pencere genişliğini geri yükle |
| `Super + Left Mouse` | Pencereyi sürükle |
| `Super + Right Mouse` | Pencereyi yeniden boyutlandır |
| `Super + Scroll Wheel` | Odaklanılan monitörde çalışma alanları arasında kaydır |
| `Super + G`               | Pencere gruplandırmasını aç/kapat      |
| `Super + Alt + G`               | Pencereyi gruplandırmadan çıkar      |
| `Super + Alt + Tab`               | Gruplandırmadaki pencereler arasında geçiş yap      |
| `Super + Alt + Shift + Tab`               | Gruplandırmadaki pencereler arasında geriye doğru geçiş yap      |
| `Super + Alt + Scroll Wheel` | Gruplandırmadaki pencereler arasında geçiş yap |
| `Super + Alt + 1/2/3/4/5`               | Gruplandırmada belirli pencereye git      |
| `Super + Alt + Arrow`  | Pencereyi ok yönünde gruplandırmaya taşı, o taraftaki monitördeki dahil |
| `Super + Ctrl + Left/Right`  | Bir döşeme grubu içindeki pencereler arasında geçiş yap |
| `Super + Ctrl + Z` | Ekrana yakınlaş (daha fazla yakınlaşmak için tekrarlayın) |
| `Super + Ctrl + Alt + Z` | Ekrandan tamamen uzaklaş |
| `Super + /` | Monitör ölçeklendirme seçeneklerinde ileri adım at |
| `Super + Alt + /` | Monitör ölçeklendirme seçeneklerinde geri adım at |
| `Alt + Tab` | Etkin çalışma alanındaki pencereler arasında ileriye doğru geçiş yap |
| `Alt + Shift + Tab` | Etkin çalışma alanındaki pencereler arasında geriye doğru geçiş yap |
| `Ctrl + Alt + Tab`| Monitörler arasında odağı ileriye doğru dolaştır |
| `Ctrl + Alt + Shift + Tab`| Monitörler arasında odağı geriye doğru dolaştır |

Yeniden boyutlandırma kısayolları, klavyede yazan karakterlerden bağımsız olarak fiziksel `code:20` ve `code:21` tuşlarını (XKB `<AE11>` ve `<AE12>`) kullanır. ABD klavyelerinde bu tuşlar `-` ve `=`; Japon (JIS) klavyelerinde `-` ve `^`; İspanyol klavyelerinde `'` ve `¡`. JIS'te `Super + ^`, `Super + Equal` demektir, oysa `Super + Shift + -` (ki `=` yazar) `Super + Shift + Minus` demektir.

## Sistem kontrolleri

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ses paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wifi/ağ paneli    |
| `Super + Ctrl + D`           | Ekran paneli    |
| `Super + Ctrl + P`           | Güç paneli    |
| `Super + Ctrl + Alt + D`           | Takvim paneli    |
| `Super + Ctrl + Alt + E`           | Dünya saati paneli    |
| `Super + Ctrl + 1-9`           | Çubuk panelini konuma göre aç/kapat    |
| `Super + Ctrl + S` | Paylaşım menüsü (LocalSend aracılığıyla) |
| `Super + Ctrl + C` | Yakalama kontrolleri (ekran görüntüsü/-kaydı/seçici) |
| `Super + Ctrl + O` | Menüyü aç/kapat |
| `Super + Ctrl + H` | Donanım menüsü |
| `Super + Ctrl + E` | Emoji seçici |
| `Super + Ctrl + .` | Medyayı dönüştür |
| `Super + Shift + Ctrl + A` | Bir AI ajanı seç |

## Ayarlamalar

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimum ekran parlaklığı |
| `Shift + Brightness Down` | Minimum ekran parlaklığı |
| `Alt + Brightness Up/Down` | Hassas %1 parlaklık değişiklikleri |
| `Alt + Volume Up/Down` | Hassas %1 ses değişiklikleri |
| `Keyboard Brightness Up/Down` | Klavye arka ışığı daha parlak/daha sönük |
| `Keyboard Backlight` | Klavye arka ışık seviyeleri arasında geçiş yap |
| `Alt + Play` | Sonraki parça |
| `Alt + Shift + Play` | Önceki parça |

## Uygulamaları başlatma

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (ajan yöneticisi) |
| `Super + Shift + Return`           | Tarayıcı    |
| `Super + Shift + Alt + B`           | Tarayıcı (gizli)    |
| `Super + Shift + F`           | Dosya yöneticisi    |
| `Super + Shift + Alt + F`           | Terminalin cwd'sinde dosya yöneticisi    |
| `Super + Shift + M`           | Müzik (Spotify)    |
| `Super + Shift + Alt + M`           | Müzik (cliamp)    |
| `Super + Shift + /`           | Parola yöneticisi (1password)    |
| `Super + Shift + Q`           | Hesap makinesi (Omacalc)    |
| `Super + Shift + T`           | Etkinlik (btop)    |
| `Super + Shift + N`           | Editör (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
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

Genelde Linux'ta, terminalde kopyalayıp yapıştırmak için `Ctrl + Shift + C/V` ve bunu diğer her yerde yapmak için `Ctrl + C/V` gerekir. Bu Omarchy birleşik pano kısayolları her yerde çalışır.

## Yakalama

| Kısayol              | İşlev                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekran görüntüsü                      |
| `Super + Ctrl + Alt + C`            | Ekran görüntüsü (aynı çekim, Print Screen tuşu olmayan klavyeler için) |
| `Super + Ctrl + C` | Yakalama menüsü |
| `Alt + Print Screen`            | Ekran kaydı                     |
| `Super + Print Screen` | Renk seçici |
| `Super + Ctrl + Print Screen` | Metni çıkarıp panoya kopyala |
| `Super + Alt + [` | Kayıt sırasında web kamerası katmanını küçült |
| `Super + Alt + ]` | Kayıt sırasında web kamerası katmanını büyüt |
| `Alt + Shift + L` | Geçerli URL'yi web uygulamasından veya Chromium'dan kopyala |
| `Alt + Shift + D` | Geçerli sayfadaki videoyu `~/Videos` konumuna indir |
| `Alt + Space` | Dikteyi başlat/durdur (_Setup > Defaults > Dictation_ gerektirir) |
| `Right Alt` | Dikte etmek için basılı tut (_Setup > Defaults > Dictation_ gerektirir) |

Ekran kayıtlarında, kısayol önce hangi sesi istediğinizi sorar, sonra kaydı başlatır. Durdurmak için tekrar basın. Ayrıntılar için [ekran görüntüleri ve kayıt](12-screenshots-recording.md) bölümüne bakın.

Tüm yakalama seçeneklerine Omarchy menüsündeki (`Super + Space`) _Trigger > Capture_ altından da erişilebilir.

## Bildirimler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + ,` | En son bildirimde işlem yap: onu aç veya tek düğmesine bas, seçeneklerinden birini seç ya da hiçbiri yoksa kapat  |
| `Super + Shift + ,` | Tüm bildirimleri kapat |
| `Super + Ctrl + ,` | Bildirimleri klavye ile kontrol et  |
| `Super + Alt + ,` | En son bildirimi kapat  |
| `Super + Shift + Alt + ,` | Bildirim geçmişini aç  |
| `Super + Ctrl + Alt + ,` | Bildirimleri sessize almayı aç/kapat  |

## Stil

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yeni bir tema seç (ayrıca `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tema arka planını seç (ayrıca `Super + Ctrl + Space`) |
| `Super + Backspace` | Bir pencerede şeffaflığı aç/kapat |
| `Super + Ctrl + Backspace` | Tek pencere kare en-boy oranını aç/kapat |

Ek arka plan görüntüleri `~/.config/omarchy/backgrounds/<theme name>` içinde bulunur. Omarchy menüsündeki _Install > Style > Background_ üzerinden de kullanılabilir.

Tüm stil seçeneklerine Omarchy menüsündeki (`Super + Space`) _Style_ altından da erişilebilir.

## Aç/Kapat

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

## Duyurular

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Saati bildirim olarak göster  |
| `Super + Ctrl + Alt + B` | Pili bildirim olarak göster  |
| `Super + Ctrl + Alt + W` | Hava durumunu bildirim olarak aç/kapat  |

## Tmux

Önek tuşu `Ctrl + Space` tuşudur (`Ctrl + B` de çalışır). Bu bağlamaları `~/.config/tmux/tmux.conf` içinde değiştirebilirsiniz.

### Bölmeler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bölmeyi yana böl (dikey) |
| `Prefix + h` | Bölmeyi aşağı böl (yatay) |
| `Prefix + x` | Bölmeyi sonlandır |
| `Prefix + z` | Bölme yakınlaştırmasını aç/kapat (tam ekran) |
| `Alt + Enter` | Bölmeyi aşağı böl (öneksiz) |
| `Alt + Shift + Enter` | Bölmeyi yana böl (öneksiz) |
| `Alt + Escape` | Bölmeyi sonlandır (öneksiz) |
| `Ctrl + Alt + Arrows` | Bölmeler arasında geçiş yap |
| `Ctrl + Alt + Shift + Arrows` | Bölmeleri yeniden boyutlandır |

### Pencereler

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yeni pencere |
| `Prefix + k` | Pencereyi sonlandır |
| `Prefix + r` | Pencereyi yeniden adlandır |
| `Alt + 1-9` | Belirli pencereye git |
| `Alt + Arrow Left/Right` | Pencereler arasında geçiş yap |
| `Alt + Shift + Arrow Left/Right` | Pencereyi sola/sağa taşı |

### Oturumlar

| Kısayol                  | İşlev              |
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
| `tdl <ai> [<second_ai>]` | Editör, AI ve terminal ile geliştirme düzeni oluştur |
| `tdlm <ai> [<second_ai>]` | Alt dizin başına geliştirme düzeni oluştur |
| `tsl <count> <command>` | Çok bölmeli sürü düzeni oluştur |

## Ghostty Terminal

Ghostty terminali, Omarchy menüsü üzerinden _Install > Terminal_ kullanılarak kurulur.

| Kısayol                  | İşlev              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Aşağı yeni bölme |
| `Ctrl + Shift + O` | Yana yeni bölme |
| `Ctrl + Alt + Arrows` | Bölmeler arasında geçiş yap |
| `Super + Ctrl + Shift + Arrows` | Bölmeyi 10 satır yeniden boyutlandır |
| `Super + Ctrl + Shift + Alt + Arrows` | Bölmeyi 100 satır yeniden boyutlandır |
| `Ctrl + Shift + T` | Yeni sekme  |
| `Ctrl + Shift + Arrows` | Sekmeler arasında geçiş yap |
| `Alt + Numbers` | Belirli sekmeye git |
| `Shift + Pg Up/Down` | Geçmişi kaydır |
| `Ctrl + Left mouse` | Bağlantıyı tarayıcıda aç |

## Dosya Yöneticisi

| Kısayol              | İşlev                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yola git                     |
| `Space`               | Dosyayı önizle (oklar gezinir) |
| `Alt + Up`       | Üst klasöre git        |

## Neovim (lazyvim ile)

### Gezinme

| Kısayol                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Komut seçeneklerini göster            |
| `Space Space`              | Dosyayı bulanık aramayla aç      |
| `Space E`                  | Kenar çubuğunu aç/kapat                  |
| `Space G G`                | git kontrollerini göster               |
| `Space S G`                | Dosya içeriğini ara               |
| `Ctrl + W W`               | Kenar çubuğu ve editör arasında geçiş yap |
| `Ctrl + Left/right arrow`  | Kenar çubuğunun boyutunu değiştir          |
| `Shift + H`                      | Sol dosya sekmesine git             |
| `Shift + L`                      | Sağ dosya sekmesine git            |
| `Space B D`                | Dosya sekmesini kapat                  |

### Kenar çubuğundayken

| Kısayol                   | İşlev                        |
| ------------------------ | ------------------------------- |
| `A`                        | Üst dizine yeni dosya ekle      |
| `Shift + A`                | Üst dizine yeni alt dizin ekle    |
| `D`                        | Vurgulanan dosya/dizini sil     |
| `M`                        | Vurgulanan dosya/dizini taşı       |
| `R`                        | Vurgulanan dosya/dizini yeniden adlandır     |
| `?`                        | Tüm komutlar için yardımı göster      |

[LazyVim tarafından yapılandırılan tüm Neovim kısayollarına bakın](https://www.lazyvim.org/keymaps).

## Hızlı Emojiler

Seçimi panoya koyacak eksiksiz bir emoji seçici göstermek için `Super + Ctrl + E` kullanabilir ya da bu hızlı erişim seçeneklerini kullanabilirsiniz.

| Kısayol       | EM | İpucu       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gülümse      |
| `Shift + CapsLock M C` | 😂 | ağla        |
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
| `Shift + CapsLock M T` | 🥂 | kadeh tokuşturma      |
| `Shift + CapsLock M O` |👌 | tamam |
| `Shift + CapsLock M G` |👋 | selamlaşma |
| `Shift + CapsLock M A` |💪 | kol |
| `Shift + CapsLock M B` |🤯 | patlama |

## Hızlı Tamamlamalar

| Kısayol       | Tamamlama       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (uzun tire)   |
| `Shift + CapsLock Space N` | Adınız (kurulumda girildiği gibi)  |
| `Shift + CapsLock Space E` | E-postanız (kurulumda girildiği gibi)  |

`~/.XCompose` dosyasını düzenleyerek kendinizinkilerden daha fazlasını ekleyebilir, ardından değişikliklerin alınması için terminalde `omarchy-restart-xcompose` çalıştırabilirsiniz.
