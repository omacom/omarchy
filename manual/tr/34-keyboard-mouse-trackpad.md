# Klavye, Fare, Dokunmatik Yüzey

Hyprland, tüm girişlerinizi büyük ayrıntıyla yapılandırmanıza olanak tanır. Klavye yinelemesini süpersonik hızda yapabilir veya dokunmatik yüzeyin doğal kaydırmayı kullanmasını sağlayabilirsiniz. Hepsini, Omarchy menüsünden (`Super + Space`) _Setup > Input_ yoluyla da ulaşabileceğiniz `~/.config/hypr/input.lua` içinde değiştirirsiniz. Orada ayarladığınız her şey Omarchy'nin varsayılanlarının yerini alır.

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

CapsLock normal bir Caps Lock olarak çalışır ve `Shift + CapsLock`, [hızlı emojiler](07-hotkeys.md#quick-emojis) ve [diğer tamamlamalar](07-hotkeys.md#quick-completions) için compose tuşudur. Compose tuşunun başka bir yerde olmasını tercih ederseniz, `kb_options` içindeki `omarchy:shift_caps_compose` ifadesini değiştirin. Örneğin, bu, compose tuşunu Right Alt'a taşır:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Fonksiyon tuşları

Bir dizüstü bilgisayar klavyesinin üst satırı varsayılan olarak medya tuşlarını (ses, parlaklık vb.) gönderir ve `Fn` tuşunu basılı tutmak F1-F12'yi verir; `Fn + Esc` bunu, tekrar basana kadar tersi şekilde kilitler. Çoğu klavye bu kilidi kendisi hatırlar. ASUS dizüstü bilgisayarlar ve Apple tarzı klavyeler bunu Linux'a bırakır; Linux da bunları her açılışta medya tuşlarıyla başlatır. Bunların bunun yerine F1-F12 ile başlamasını sağlamak için `omarchy device keyboard toprow fnkeys` komutunu çalıştırın (geri dönmek için `omarchy device keyboard toprow mediakeys`); bazı dizüstü bilgisayarlarda bu, yeniden başlatmanın ardından etkili olur. Apple Silicon Mac'ler kendi ayarlarını korur.

### Dokunmatik yüzey hareketleri

Masaüstünde gezinmek için dokunmatik yüzeyde kaydırın:

| Hareket | Eylem |
| --- | --- |
| Üç parmakla sola / sağa | Önceki / sonraki çalışma alanı, boş olanlar dahil |
| Üç parmakla yukarı | AI konsolunu açıp kapatma |
| Üç parmakla aşağı | Omarchy menüsünü açma |
| Dört parmakla sola / sağa | Etkin pencereyi önceki / sonraki çalışma alanına taşıma |
| Dört parmakla aşağı | Tam ekranı açıp kapatma |

Birini değiştirmek için, kendi [dokunmatik yüzey hareketinizi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) eklemeden önce onu `~/.config/hypr/input.lua` içinde devre dışı bırakın; çünkü Hyprland aynı parmak sayısı ve yön için iki hareketi kabul etmez:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy'nin tüm hareketlerini kapatmak için, Omarchy'nin varsayılanları yüklenmeden önce, `~/.config/hypr/hyprland.lua` dosyasının üst kısmına yakın bir yere `omarchy_default_gestures = false` ayarını ekleyin.

Haptik dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Trigger > Hardware > Touchpad Haptics_ altında düşük, orta veya yüksek olarak da ayarlayabilirsiniz.

### Çince, Japonca ve diğer dillerde yazma

Yükleyici klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin), Tayvan (Zhuyin) veya Hong Kong (Cangjie) seçin. Omarchy, çevrimdışı ilk açılış kurulumu sırasında da dahil olmak üzere, klavyeyi ve eşleşen giriş motorunu otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki kümeli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Tayvan Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japonca (ABD klavyesi), ABD klavye düzeniyle Mozc sağlar. Dvorak, Colemak veya AZERTY ile Latin harfleri yazarken bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul veya Chewing'i bundan önce eklediyseniz, tuşlarını oraya taşımak için _Setup > Keyboard > Input Methods_ altında seçimini kaldırıp yeniden seçin; Omarchy, zaten yazmak için kullandığınız bir motora dokunmaz.

Yazma Latin modunda başlar. Yapılandırılmış giriş yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına, geriye doğru geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir giriş yönteminden Latin harflerine çıkmak için tek başına `Shift` tuşuna dokunun ve geri dönmek için tekrar dokunun; Sogou, Microsoft Pinyin ve macOS'un çalıştığı şekilde. `Shift` artı bir harf hâlâ büyük harf yazar. Japon klavyelerinde 全角/半角 girişi açıp kapatır, 変換 açar ve 無変換 kapatır. Korecede 한/영 Hangul arasında geçiş yapar ve 한자 Hanja'ya dönüştürür; klavyenizde ister özel tuşlar olsun ister birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl gönderilsin, bu nedenle Right Alt ve Right Ctrl orada düz değiştirici tuşlar değildir; dikte bunun yerine Alt + Space ile açılıp kapatılır. `Ctrl + Space`, Tmux ve Herdr için kullanılabilir durumda kalır; `Shift + CapsLock` compose tuşu olarak kalır.

Birden çok klavye düzeniniz veya giriş yönteminiz olduğunda klavye göstergesi çubuğun sağ tarafında görünür. Giriş dilleri arasında geçiş yapmak için tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japoncaya geçin, `nihongo` gibi bir sözcük yazın, ardından Space tuşuna iki kez basın. Seçiminizi kabul etmek için Enter tuşuna basın. Birden çok klavye düzeniniz de varsa, bunlar arasında geçiş yapmak için göstergeye sağ tıklayın.

_Setup > Keyboard > Keyboard Inputs_ öğesini, kurulum sırasında sunulan aynı seçenekler arasından İngilizce ve Fransızca gibi düzenleri seçmek için kullanın. Hangi oluşturma motorlarının etkin olduğunu seçmek için _Setup > Keyboard > Input Methods_ öğesini kullanın. Her iki seçici de Omarchy menüsünün içinde, geçerli seçimleriniz işaretlenmiş olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter tuşuna basın; her değişiklik hemen uygulanır. Bir giriş yönteminin seçimini kaldırmak, onu kaldırmadan döngüden çıkarır; klavye kullanılabilir durumda kalır.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` komutunu çalıştırın. Komut satırından bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` veya `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Input Methods seçicisinde görünür. Özel geçiş tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için, `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` kurun ve bir terminalden başlatın. Bir giriş dili seçmek masaüstü dilini değiştirmez. Henüz hiçbir giriş yönteminiz yokken _Setup > Region > Language_ altında Japonca, Korece veya Çince seçmek, onun giriş yöntemini ekler.

Giriş yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I`, ters yönde gitmek için `Super + Shift + I` kullanın; böylece üç tane yapılandırılmışsa iki komşu arasında hareket edebilirsiniz. Giriş göstergesi, yalnızca birden fazla giriş yöntemi veya düzen yapılandırıldığında çubuğun sağ tarafında görünür. Bu masaüstü kısayolu, mevcut Fcitx geçiş tuşlarınızla birlikte çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Giriş motorları ve compose dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT'yi SUPER olarak kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak uygun değildir. Bu değişiklikle bunun yerine ALT olmasını sağlayabilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
