# Klavye, Fare, Dokunmatik Yüzey

Hyprland, tüm girdilerinizi büyük ayrıntıyla yapılandırmanıza olanak tanır. Klavye yinelemesini süpersonik derecede hızlı yapabilir veya dokunmatik yüzeyin doğal kaydırma kullanmasını sağlayabilirsiniz. Hepsini `~/.config/hypr/input.lua` içinde değiştirirsiniz; buna Omarchy menüsündeki (`Super + Space`) _Ayarlar > Input_ aracılığıyla da ulaşabilirsiniz. Oraya ayarladığınız her şey Omarchy'nin varsayılanlarının yerine geçer.

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

Girdiler için Hyprland wiki'sinde [tüm girdi seçeneklerini görebilirsiniz](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için compose tuşudur. Compose tuşunun başka bir yerde olmasını tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` öğesini değiştirin. Örneğin, bu compose tuşunu Sağ Alt'a taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Dokunmatik yüzey hareketleri

Üç parmağınızı kaydırarak çalışma alanlarını değiştirmek gibi [dokunmatik yüzey hareketlerini](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) de açabilirsiniz:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dokunsal dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Tetikle > Hardware > Touchpad Haptics_ altında düşük, orta veya yüksek olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazmak

Kurulum programı klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin) veya Çince (Geleneksel, Zhuyin) seçin. Omarchy, çevrimdışı ilk önyükleme kurulumu sırasında da dahil olmak üzere, klavyeyi ve eşleşen girdi motorunu otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki setli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır ve Geleneksel Çince Chewing'in standart Zhuyin düzenini kullanır. Japonca (ABD klavyesi), ABD klavye düzeniyle Mozc sağlar.

Yazma Latin modunda başlar. Yapılandırılmış girdi yöntemleri arasında geçiş yapmak için `Super + I` ve geri geçiş yapmak için `Super + Shift + I` tuşuna basın. Pinyin gibi bir girdi yönteminden çıkıp Latin harflerine geçmek için `Shift` tuşuna tek başına dokunun ve Sogou, Microsoft Pinyin ve macOS'un çalıştığı şekilde geri dönmek için tekrar dokunun; `Shift` artı bir harf hâlâ büyük harf yazar. Japonca klavyelerde 全角/半角 girdiyi açıp kapatır, 変換 onu açar ve 無変換 kapatır. Korece klavye düzeninde, ayrılmış 한/영 ve 한자 tuşları Hangul'u değiştirir ve Hanja'ya dönüştürür. `Ctrl + Space` Tmux ve Herdr için kullanılabilir kalır; `Shift + CapsLock` compose tuşu olarak kalır.

Klavye göstergesi, birden çok klavye düzeniniz veya girdi yönteminiz olduğunda çubuğun sağında görünür. Girdi dillerini değiştirmek için ona tıklayın; Japonca, hiragana için あ görüntüler. Japonca karakter seçimleri için Japonca'ya geçin, `nihongo` gibi bir kelime yazın, ardından Space'e iki kez basın. Seçiminizi kabul etmek için Enter'a basın. Ayrıca birden çok klavye düzeniniz varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

Kurulum sırasında sunulan aynı seçeneklerden İngilizce ve Fransızca gibi düzenleri seçmek için _Ayarlar > Typing > Keyboard Layouts_ seçeneğini kullanın. Hangi birleşim motorlarının etkin olduğunu seçmek için _Ayarlar > Typing > Input Methods_ seçeneğini kullanın. Her iki seçici de Omarchy menüsü içinde geçerli seçimleriniz işaretlenmiş olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter'a basın; her değişiklik hemen geçerli olur. Bir girdi yönteminin seçimini kaldırmak, onu kaldırmadan döngüden çıkarır; klavye kullanılabilir kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` komutunu çalıştırın. Komut satırından bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin` veya `chewing` kullanın. Özel değiştirme tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` kurun ve bir terminalden başlatın. Bir girdi dili seçmek masaüstü dilini değiştirmez.

Girdi yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I` ve diğer yöne gitmek için `Super + Shift + I` kullanın; böylece üç tane yapılandırıldığında iki komşu arasında hareket edebilirsiniz. Girdi göstergesi, yalnızca birden fazla girdi yöntemi veya düzeni yapılandırıldığında çubuğun sağında görünür. Bu masaüstü ataması, mevcut Fcitx değiştirme tuşlarınızın yanında çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Girdi motorları ve compose dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT'yi SUPER olarak kullanmak

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak uygun değildir. Bunu şu değişikliği kullanarak bunun yerine ALT olarak değiştirebilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
