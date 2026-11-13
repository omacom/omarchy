# Klavye, Fare, Dokunmatik Yüzey

Hyprland, tüm girdilerinizi ayrıntılı biçimde yapılandırmanızı sağlar. Klavye yinelemesini süpersonik derecede hızlı yapabilir ya da dokunmatik yüzeyin doğal kaydırmayı kullanmasını sağlayabilirsiniz. Bunların tamamını `~/.config/hypr/input.lua` içinde değiştirirsiniz; buraya Omarchy menüsündeki (`Super + Space`) _Setup > Input_ üzerinden de ulaşabilirsiniz. Buraya yazdığınız her şey Omarchy varsayılanlarının yerini alır.

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

Girdilere dair [tüm girdi seçeneklerini](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki'sinde görebilirsiniz.

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için compose tuşudur. Compose tuşunun başka bir yerde olmasını tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` ifadesini değiştirin. Örneğin, aşağıdakiler compose tuşunu Right Alt tuşuna taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### İşlev tuşları

Bir dizüstü bilgisayar klavyesinin üst sırası varsayılan olarak medya tuşlarını (ses seviyesi, parlaklık ve benzerlerini) gönderir ve `Fn` tuşunu basılı tutmak F1-F12 tuşlarını verir; `Fn + Esc` bunu tekrar basana kadar tersi yönde kilitler. Çoğu klavye bu kilidi kendisi hatırlar. ASUS dizüstü bilgisayarlar ve Apple tarzı klavyeler bunu Linux'a bırakır; Linux da bunları her açılışta medya tuşlarıyla başlatır. Bunun yerine F1-F12 ile başlamalarını sağlamak için `omarchy keyboard toprow fnkeys` komutunu çalıştırın (geri dönmek için `omarchy keyboard toprow mediakeys`); bazı dizüstü bilgisayarlarda bu, yeniden başlatmanın ardından etkili olur. Apple Silicon Mac'ler kendi ayarlarını korur.

### Dokunmatik yüzey hareketleri

Masaüstünde gezinmek için dokunmatik yüzeyde kaydırın:

| Gesture | Action |
| --- | --- |
| Three fingers left / right | Previous / next workspace, including empty ones |
| Three fingers up | Toggle the AI console |
| Three fingers down | Open the Omarchy menu |
| Four fingers left / right | Move the active window to the previous / next workspace |
| Four fingers down | Toggle fullscreen |

Birini değiştirmek için, kendi [dokunmatik yüzey hareketinizi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) eklemeden önce onu `~/.config/hypr/input.lua` içinde kaldırın; çünkü Hyprland aynı parmaklara ve yöne iki hareket kabul etmez:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy'nin tüm hareketlerini kapatmak için, Omarchy varsayılanları yüklenmeden önce, `~/.config/hypr/hyprland.lua` dosyasının üst kısmına yakın bir yerde `omarchy_default_gestures = false` ayarını yapın.

Dokunsal dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Trigger > Hardware > Touchpad Haptics_ altında düşük, orta veya yüksek olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazma

Kurulum programı klavyenizi sorduğunda Japonca, Korece, Çince (Simplified, Pinyin), Taiwan (Zhuyin) veya Hong Kong (Cangjie) seçin. Omarchy, çevrimdışı ilk açılış kurulumu sırasında da dahil olmak üzere, klavyeyi ve eşleşen girdi motorunu otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki kümeli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Taiwan, Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japanese (US keyboard), US klavye düzenine sahip Mozc sağlar. Latin harflerini Dvorak, Colemak veya AZERTY ile yazdığınızda bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul veya Chewing'i bundan önce eklediyseniz, tuşlarını buraya taşımak için _Setup > Keyboard > Input Methods_ altında seçimini kaldırıp yeniden seçin; Omarchy, halihazırda yazdığınız bir motora dokunmaz.

Yazma işlemi Latin modunda başlar. Yapılandırılmış girdi yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına, geri yönde geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir girdi yönteminden Latin harflerine çıkmak için `Shift` tuşuna tek başına dokunun ve geri dönmek için tekrar dokunun; Sogou, Microsoft Pinyin ve macOS böyle çalışır; `Shift` artı bir harf yine büyük harf yazar. Japonca klavyelerde 全角/半角 girdiyi açıp kapatır, 変換 açar ve 無変換 kapatır. Korece ile 한/영 Hangul arasında geçiş yapar ve 한자 Hanja'ya dönüştürür; klavyenizde ister özel tuşlar bulunsun ister birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl gönderilsin, bu böyledir; dolayısıyla Right Alt ve Right Ctrl orada düz değiştirici tuşlar değildir; dikte bunun yerine Alt + Space ile açılıp kapatılır. `Ctrl + Space`, Tmux ve Herdr için kullanılabilir durumda kalır; `Shift + CapsLock` compose tuşu olarak kalır.

Birden fazla klavye düzeniniz veya girdi yönteminiz olduğunda klavye göstergesi çubuğun sağ tarafında görünür. Girdi dilleri arasında geçiş yapmak için tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japonca'ya geçin, `nihongo` gibi bir sözcük yazın, ardından iki kez Space tuşuna basın. Seçiminizi kabul etmek için Enter tuşuna basın. Birden fazla klavye düzeniniz de varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

English ve French gibi düzenleri, kurulum sırasında sunulan seçeneklerin aynısı arasından seçmek için _Setup > Keyboard > Keyboard Inputs_ yolunu kullanın. Hangi oluşturma motorlarının etkin olacağını seçmek için _Setup > Keyboard > Input Methods_ yolunu kullanın. Her iki seçici de Omarchy menüsünün içinde, mevcut seçimleriniz işaretli olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter tuşuna basın; her değişiklik hemen uygulanır. Bir girdi yönteminin seçimini kaldırmak, onu kaldırmadan döngüden çıkarır; klavye kullanılabilir durumda kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` komutunu çalıştırın. Komut satırından tek bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` veya `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Input Methods seçicisinde görünür. Özel geçiş tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için, `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` paketini kurun ve bir terminalden başlatın. Bir girdi dili seçmek masaüstü dilini değiştirmez. _Setup > Language_ altında Japonca, Korece veya Çince seçmek, henüz hiç yoksa onun girdi yöntemini ekler.

Girdi yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I`, diğer yöne gitmek için `Super + Shift + I` tuşlarını kullanın; böylece yapılandırılmış üç taneyle iki komşu arasında hareket edebilirsiniz. Girdi göstergesi çubuğun sağ tarafında yalnızca birden fazla girdi yöntemi veya düzen yapılandırıldığında görünür. Bu masaüstü kısayolu, mevcut Fcitx geçiş tuşlarınızla birlikte çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Girdi motorları ve compose dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT tuşunu SUPER olarak kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak uygun değildir. Bunun yerine ALT kullanılmasını şu değişiklikle sağlayabilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
