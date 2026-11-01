# Klavye, Fare, Dokunmatik Yüzey

Hyprland, tüm giriş aygıtlarınızı büyük bir ayrıntıyla yapılandırmanıza olanak tanır. Klavye tekrarını süpersonik derecede hızlı yapabilir ya da dokunmatik yüzeyin doğal kaydırmayı kullanmasını sağlayabilirsiniz. Tümünü `~/.config/hypr/input.lua` içinde değiştirirsiniz; buraya Omarchy menüsündeki (`Super + Space`) _Setup > Input_ yoluyla da ulaşabilirsiniz. Orada ayarladığınız her şey Omarchy'nin varsayılanlarının yerini alır.

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

Girişlere ilişkin [tüm giriş seçeneklerini görebilirsiniz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki'sinde.

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için compose tuşudur. Compose tuşunun başka bir yerde olmasını tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` ifadesini değiştirin. Örneğin, bu, compose tuşunu Right Alt'a taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Dokunmatik yüzey hareketleri

Masaüstünde gezinmek için dokunmatik yüzeyde kaydırın:

| Hareket | Eylem |
| --- | --- |
| Üç parmakla sola / sağa | Önceki / sonraki çalışma alanı, boş olanlar dahil |
| Üç parmakla yukarı | AI konsolunu aç/kapat |
| Üç parmakla aşağı | Omarchy menüsünü aç |
| Dört parmakla sola / sağa | Etkin pencereyi önceki / sonraki çalışma alanına taşı |
| Dört parmakla aşağı | Tam ekranı aç/kapat |

Birini değiştirmek için, Hyprland aynı parmak sayısı ve yönde iki hareketi kabul etmeyeceğinden, kendi [dokunmatik yüzey hareketinizi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) eklemeden önce onu `~/.config/hypr/input.lua` içinde kaldırın:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy'nin tüm hareketlerini kapatmak için, Omarchy'nin varsayılanları yüklenmeden önce `~/.config/hypr/hyprland.lua` dosyasının üst kısmına yakın bir yerde `omarchy_default_gestures = false` ayarını yapın.

Haptik dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Trigger > Hardware > Touchpad Haptics_ altında low, mid veya high olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazma

Kurulum programı klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin), Taiwan (Zhuyin) veya Hong Kong (Cangjie) seçin. Omarchy, klavyeyi ve eşleşen giriş motorunu, çevrimdışı ilk açılış kurulumu sırasında da dahil olmak üzere otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki kümeli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Taiwan Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japonca (US klavye), US klavye düzeniyle Mozc sağlar. Dvorak, Colemak veya AZERTY ile Latin harfleri yazsanız bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul veya Chewing'i bundan önce eklediyseniz, tuşlarını buraya taşımak için _Setup > Typing > Input Methods_ altında seçimini kaldırıp yeniden seçin; Omarchy zaten yazmak için kullandığınız bir motora dokunmaz.

Yazma Latin modunda başlar. Yapılandırılmış giriş yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına, geriye doğru geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir giriş yönteminden Latin harflerine çıkmak için tek başına `Shift` tuşuna dokunun ve geri dönmek için tekrar dokunun; Sogou, Microsoft Pinyin ve macOS'un çalıştığı gibi; `Shift` artı bir harf hâlâ büyük harf yazar. Japon klavyelerinde 全角/半角 girişi açıp kapatır, 変換 açar ve 無変換 kapatır. Korece ile 한/영 Hangul arasında geçiş yapar ve 한자 Hanja'ya dönüştürür; klavyenizde özel tuşlar bulunsa da birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl gönderse de durum böyledir, dolayısıyla Right Alt ve Right Ctrl orada sıradan değiştiriciler değildir; dikte bunun yerine Alt + Space ile açılıp kapatılır. `Ctrl + Space`, Tmux ve Herdr için kullanılabilir durumda kalır; `Shift + CapsLock` compose tuşu olarak kalır.

Klavye göstergesi, birden çok klavye düzeniniz veya giriş yönteminiz olduğunda çubuğun sağ tarafında görünür. Giriş dillerini değiştirmek için ona tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japoncaya geçin, `nihongo` gibi bir sözcük yazın, ardından Space tuşuna iki kez basın. Seçiminizi kabul etmek için Enter tuşuna basın. Birden çok klavye düzeniniz de varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

İngilizce ve Fransızca gibi düzenleri, kurulum sırasında sunulan aynı seçenekler arasından seçmek için _Setup > Typing > Keyboard Layouts_ kullanın. Hangi oluşturma motorlarının etkin olduğunu seçmek için _Setup > Typing > Input Methods_ kullanın. Her iki seçici de Omarchy menüsünün içinde, geçerli seçimleriniz işaretli olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter tuşuna basın; her değişiklik anında uygulanır. Bir giriş yönteminin seçimini kaldırmak, onu kaldırmadan döngüden çıkarır; klavye kullanılabilir durumda kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` çalıştırın. Komut satırından tek bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` veya `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Input Methods seçicisinde görünür. Özel geçiş tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için, `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` kurun ve onu bir terminalden başlatın. Bir giriş dili seçmek masaüstü dilini değiştirmez. _Setup > Language_ altında Japonca, Korece veya Çince seçmek, henüz hiç giriş yönteminiz yoksa onun giriş yöntemini ekler.

Giriş yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I`, ters yönde gitmek için `Super + Shift + I` kullanın; böylece üç tane yapılandırılmışsa iki komşu arasında hareket edebilirsiniz. Giriş göstergesi yalnızca birden fazla giriş yöntemi veya düzen yapılandırıldığında çubuğun sağ tarafında görünür. Bu masaüstü kısayolu, mevcut Fcitx geçiş tuşlarınızla birlikte çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Giriş motorları ve compose dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### SUPER olarak ALT kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak pratik değildir. Bunun yerine ALT olmasını şu değişiklikle sağlayabilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
