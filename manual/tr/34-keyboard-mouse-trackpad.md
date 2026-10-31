# Klavye, Fare, Trackpad

Hyprland, tüm girişlerinizi büyük ayrıntıyla yapılandırmanıza olanak tanır. Klavye tekrarını süpersonik hızda yapabilir veya trackpad'in doğal kaydırmayı kullanmasını sağlayabilirsiniz. Bunların tümünü `~/.config/hypr/input.lua` içinde değiştirirsiniz; buraya Omarchy menüsündeki (`Super + Space`) _Setup > Input_ yolundan da ulaşabilirsiniz. Orada ayarladığınız her şey Omarchy'nin varsayılanlarının yerini alır.

İşte bir örnek:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Girişler için Hyprland wiki'sinde [tüm giriş seçeneklerini görebilirsiniz](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için oluşturma tuşudur. Oluşturma tuşunun başka bir yerde olmasını tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` ifadesini değiştirin. Örneğin, bu, oluşturma tuşunu Right Alt'a taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad hareketleri

Masaüstünde gezinmek için trackpad üzerinde kaydırın:

| Hareket | Eylem |
| --- | --- |
| Üç parmak sol / sağ | Boş olanlar dahil, önceki / sonraki çalışma alanı |
| Üç parmak yukarı | AI konsolunu aç/kapat |
| Üç parmak aşağı | Omarchy menüsünü aç |
| Dört parmak sol / sağ | Etkin pencereyi önceki / sonraki çalışma alanına taşı |
| Dört parmak aşağı | Tam ekranı aç/kapat |

Birini değiştirmek için, kendi [touchpad hareketinizi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) eklemeden önce `~/.config/hypr/input.lua` içinde onu kaldırın; çünkü Hyprland aynı parmaklar ve yön için iki hareket kabul etmez:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy'nin tüm hareketlerini kapatmak için, Omarchy'nin varsayılanları yüklenmeden önce, `~/.config/hypr/hyprland.lua` dosyasının üst kısmına yakın bir yerde `omarchy_default_gestures = false` ayarını yapın.

Haptik touchpad'e sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Trigger > Hardware > Touchpad Haptics_ altında düşük, orta veya yüksek olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazma

Kurulum programı klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin), Tayvan (Zhuyin) veya Hong Kong (Cangjie) seçin. Omarchy, çevrimdışı ilk açılış kurulumu sırasında da dahil olmak üzere, klavyeyi ve eşleşen giriş motorunu otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki setli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Tayvan Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japonca (US klavye), US klavye düzeniyle Mozc sağlar. Latin harflerini Dvorak, Colemak veya AZERTY ile yazsanız bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul veya Chewing'i bundan önce eklediyseniz, tuşlarını buraya taşımak için _Setup > Typing > Input Methods_ altında seçimini kaldırıp yeniden seçin; Omarchy, zaten yazdığınız bir motora dokunmaz.

Yazma Latin modunda başlar. Yapılandırılmış giriş yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına, geriye doğru geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir giriş yönteminden Latin harflerine çıkmak için `Shift` tuşuna tek başına dokunun ve geri dönmek için tekrar dokunun; bu, Sogou, Microsoft Pinyin ve macOS'taki gibi çalışır; `Shift` artı bir harf yine büyük harf yazar. Japon klavyelerinde 全角/半角 girişi açıp kapatır, 変換 açar ve 無変換 kapatır. Korece ile 한/영 Hangul'u değiştirir ve 한자 Hanja'ya dönüştürür; klavyenizde özel tuşlar olsa da, birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl gönderilse de bu böyledir, bu yüzden Right Alt ve Right Ctrl orada düz değiştiriciler değildir; dikte bas-konuş F9'da kalır. `Ctrl + Space`, Tmux ve Herdr için kullanılabilir durumda kalır; `Shift + CapsLock` oluşturma tuşu olarak kalır.

Birden fazla klavye düzeniniz veya giriş yönteminiz olduğunda klavye göstergesi çubuğun sağında görünür. Giriş dillerini değiştirmek için ona tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japoncaya geçin, `nihongo` gibi bir sözcük yazın, ardından Space tuşuna iki kez basın. Seçiminizi kabul etmek için Enter tuşuna basın. Birden fazla klavye düzeniniz de varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

Kurulum sırasında sunulan aynı seçenekler arasından İngilizce ve Fransızca gibi düzenleri seçmek için _Setup > Typing > Keyboard Layouts_ yolunu kullanın. Hangi oluşturma motorlarının etkin olduğunu seçmek için _Setup > Typing > Input Methods_ yolunu kullanın. Her iki seçici de Omarchy menüsünün içinde, mevcut seçimleriniz işaretli olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter tuşuna basın; her değişiklik hemen uygulanır. Bir giriş yönteminin seçimini kaldırmak, onu sistemden kaldırmadan döngüden çıkarır; klavye kullanılabilir durumda kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` komutunu çalıştırın. Komut satırından bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` veya `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Input Methods seçicisinde görünür. Özel değiştirme tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için, `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` paketini kurun ve bir terminalden başlatın. Bir giriş dili seçmek masaüstü dilini değiştirmez. _Setup > Language_ altında Japonca, Korece veya Çince seçmek, henüz bir giriş yönteminiz yoksa onun giriş yöntemini ekler.

Giriş yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I`, diğer yöne geri gitmek için `Super + Shift + I` kullanın; böylece üç tane yapılandırılmışsa iki komşu arasında hareket edebilirsiniz. Giriş göstergesi, çubuğun sağında yalnızca birden fazla giriş yöntemi veya düzen yapılandırıldığında görünür. Bu masaüstü kısayolu, mevcut Fcitx değiştirme tuşlarınızla birlikte çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Giriş motorları ve oluşturma dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT'yi SUPER olarak kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak elverişli değildir. Bu değişiklikle bunun yerine ALT olmasını sağlayabilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
