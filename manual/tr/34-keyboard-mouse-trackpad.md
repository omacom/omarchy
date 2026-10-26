# Klavye, Fare, Trackpad

Hyprland, tüm girişlerinizi büyük ayrıntıyla yapılandırmanıza olanak tanır. Klavye yinelemesini süpersonik derecede hızlı yapabilir ya da trackpad'in doğal kaydırmayı kullanmasını sağlayabilirsiniz. Hepsini `~/.config/hypr/input.lua` içinde değiştirirsiniz; buraya Omarchy menüsünden (`Super + Space`) _Setup > Input_ yoluyla da ulaşabilirsiniz. Orada ayarladığınız her şey Omarchy'nin varsayılanlarının yerini alır.

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

Girişler için Hyprland wiki'sinde [tüm giriş seçeneklerine bakabilirsiniz](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için oluşturma tuşudur. Oluşturma tuşunu başka bir yerde tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` ifadesini değiştirin. Örneğin, bu, oluşturma tuşunu Right Alt'a taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad hareketleri

Üç parmağınızla kaydırarak çalışma alanlarını değiştirmek gibi [dokunmatik yüzey hareketlerini](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) de açabilirsiniz:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Haptik dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Trigger > Hardware > Touchpad Haptics_ altında low, mid ya da high olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazma

Yükleyici klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin), Tayvan (Zhuyin) ya da Hong Kong (Cangjie) seçin. Omarchy, klavyeyi ve eşleşen giriş motorunu, çevrimdışı ilk açılış kurulumu sırasında da dahil olmak üzere otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki kümeli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Tayvan Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japanese (US keyboard), US klavye düzeniyle Mozc sağlar. Dvorak, Colemak ya da AZERTY ile Latin harfleri yazsanız bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul ya da Chewing'i bundan önce eklediyseniz, tuşlarını buraya taşımak için _Setup > Typing > Input Methods_ altında seçimini kaldırıp yeniden seçin; Omarchy, zaten yazmakta olduğunuz bir motoru kendi haline bırakır.

Yazmaya Latin modunda başlarsınız. Yapılandırılmış giriş yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına, geriye doğru geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir giriş yönteminden Latin harflerine çıkmak için `Shift`e tek başına dokunun, geri dönmek için tekrar dokunun; Sogou, Microsoft Pinyin ve macOS'un çalıştığı gibi; `Shift` artı bir harf yine de büyük harf yazar. Japonca klavyelerde 全角/半角 girişi açıp kapatır, 変換 açar ve 無変換 kapatır. Korece ile 한/영 Hangul arasında geçiş yapar ve 한자 Hanja'ya dönüştürür; klavyenizde özel tuşlar olsa da, birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl gönderse de, bu yüzden Right Alt ve Right Ctrl orada düz değiştirici tuşlar değildir; dikte bas-konuş F9'da kalır. `Ctrl + Space` Tmux ve Herdr için kullanılabilir kalır; `Shift + CapsLock` oluşturma tuşu olarak kalır.

Birden çok klavye düzeniniz ya da giriş yönteminiz olduğunda klavye göstergesi çubuğun sağında görünür. Giriş dilleri arasında geçiş yapmak için tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japonca'ya geçin, `nihongo` gibi bir sözcük yazın, sonra Space tuşuna iki kez basın. Seçiminizi kabul etmek için Enter tuşuna basın. Birden çok klavye düzeniniz de varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

Kurulum sırasında sunulan aynı seçeneklerden İngilizce ve Fransızca gibi düzenleri seçmek için _Setup > Typing > Keyboard Layouts_ yolunu kullanın. Hangi oluşturma motorlarının etkin olduğunu seçmek için _Setup > Typing > Input Methods_ yolunu kullanın. Her iki seçici de Omarchy menüsü içinde, geçerli seçimleriniz işaretli olarak açılır. Bir seçimi açıp kapatmak için tıklayın ya da Enter tuşuna basın; her değişiklik hemen uygulanır. Bir giriş yönteminin seçimini kaldırmak, onu kaldırmadan döngüden çıkarır; klavye kullanılabilir kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` ya da `omarchy setup input` çalıştırın. Komut satırından tek bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ya da `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Input Methods seçicisinde görünür. Özel geçiş tuşlarınız korunur. Alternatif motor düzenleri ya da tuşları için `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` kurun ve bir terminalden başlatın. Bir giriş dili seçmek masaüstü dilini değiştirmez. _Setup > Language_ altında Japonca, Korece ya da Çince seçmek, henüz hiç giriş yönteminiz yoksa onun giriş yöntemini ekler.

Giriş yöntemleri ya da klavye düzenleri arasında geçiş yapmak için `Super + I` tuşlarını, ters yönde gitmek için `Super + Shift + I` tuşlarını kullanın; böylece üç tane yapılandırılmışsa iki komşu arasında hareket edebilirsiniz. Giriş göstergesi, yalnızca birden fazla giriş yöntemi ya da düzeni yapılandırıldığında çubuğun sağında görünür. Bu masaüstü kısayolu, mevcut Fcitx geçiş tuşlarınızla birlikte çalışır; bunu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Giriş motorları ve oluşturma dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT'yi SUPER olarak kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak rahat değildir. Bu değişiklikle bunun yerine ALT kullanacak şekilde değiştirebilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
