# Klavye, Fare, Dokunmatik Yüzey

Hyprland, tüm girişlerinizi büyük ayrıntıyla yapılandırmanıza olanak tanır. Klavye yinelemesini süpersonik derecede hızlı yapabilir veya dokunmatik yüzeyin doğal kaydırmayı kullanmasını sağlayabilirsiniz. Bunların tümünü, Omarchy menüsü (`Super + Space`) üzerinden _Kurulum > Giriş_ yoluyla da ulaşabileceğiniz `~/.config/hypr/input.lua` içinde değiştirirsiniz. Orada ayarladığınız her şey Omarchy'nin varsayılanlarının yerine geçer.

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

### Fonksiyon Tuşları

Bir dizüstü bilgisayar klavyesinin üst sırası varsayılan olarak medya tuşlarını (ses, parlaklık vb.) gönderir ve `Fn` tuşunu basılı tutmak F1-F12 tuşlarını verir; `Fn + Esc` bunu, yeniden basana kadar ters yönde kilitler. Çoğu klavye bu kilidi kendisi hatırlar. ASUS dizüstü bilgisayarlar ve Apple tarzı klavyeler bunu Linux'a bırakır; Linux da onları her önyüklemede medya tuşlarıyla başlatır. Bunun yerine F1-F12 ile başlamalarını sağlamak için `omarchy device keyboard toprow fnkeys` komutunu çalıştırın (geri dönmek için `omarchy device keyboard toprow mediakeys`); bazı dizüstü bilgisayarlarda yeniden başlattıktan sonra etkili olur. Apple Silicon Mac'ler kendi ayarlarını korur.

### Dokunmatik Yüzey Hareketleri

Masaüstünde gezinmek için dokunmatik yüzeyde kaydırın:

| Hareket | Eylem |
| --- | --- |
| Üç parmak sola / sağa | Önceki / sonraki çalışma alanı, boş olanlar dahil |
| Üç parmak yukarı | AI konsolunu aç/kapat |
| Üç parmak aşağı | Omarchy menüsünü aç |
| Dört parmak sola / sağa | Etkin pencereyi önceki / sonraki çalışma alanına taşı |
| Dört parmak aşağı | Tam ekranı aç/kapat |

Birini değiştirmek için, kendi [dokunmatik yüzey hareketinizi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) eklemeden önce onu `~/.config/hypr/input.lua` içinde devre dışı bırakın; çünkü Hyprland aynı parmaklar ve aynı yön için iki hareket kabul etmez:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy'nin tüm hareketlerini kapatmak için, Omarchy'nin varsayılanları yüklenmeden önce, `~/.config/hypr/hyprland.lua` dosyasının üst kısmına yakın bir yere `omarchy_default_gestures = false` ayarını ekleyin.

Haptik dokunmatik yüzeye sahip Dell XPS dizüstü bilgisayarlarda, tıklama gücünü _Tetikleyici > Donanım > Dokunmatik Yüzey Haptikleri_ altında düşük, orta veya yüksek olarak da ayarlayabilirsiniz.

### Çince, Japonca ve Diğer Dillerde Yazma

Yükleyici klavyenizi sorduğunda Japonca, Korece, Çince (Basitleştirilmiş, Pinyin), Tayvan (Zhuyin) veya Hong Kong (Cangjie) seçin. Omarchy, çevrimdışı ilk önyükleme kurulumu sırasında da dahil olmak üzere, klavyeyi ve eşleşen giriş motorunu otomatik olarak yapılandırır. Japonca Mozc kullanır, Korece standart iki kümeli Hangul kullanır, Basitleştirilmiş Çince Pinyin kullanır, Tayvan Chewing'in standart Zhuyin düzenini kullanır ve Hong Kong, Hong Kong karakter biçimleriyle Cangjie kullanır. Japonca (US klavye), US klavye düzeniyle Mozc sağlar. Latin harflerini Dvorak, Colemak veya AZERTY ile yazsanız bile Hangul, Zhuyin ve Cangjie tuşları standart konumlarında kalır. Hangul veya Chewing'i bundan önce eklediyseniz, tuşlarını buraya taşımak için _Kurulum > Klavye > Girdi Yöntemleri_ altında seçimini kaldırıp yeniden seçin; Omarchy, zaten yazdığınız bir motoru kendi haline bırakır.

Yazma Latin modunda başlar. Yapılandırılmış girdi yöntemleri arasında geçiş yapmak için `Super + I` tuşlarına basın, geri geçiş yapmak için `Super + Shift + I` tuşlarına basın. Pinyin gibi bir girdi yönteminden çıkıp Latin harflerine geçmek için tek başına `Shift` tuşuna dokunun, geri dönmek için yeniden dokunun; Sogou, Microsoft Pinyin ve macOS'un çalıştığı gibi; `Shift` artı bir harf yine de büyük harf yazar. Japon klavyelerinde 全角/半角 girişi açıp kapatır, 変換 açar ve 無変換 kapatır. Korece ile 한/영 Hangul arasında geçiş yapar ve 한자 Hanja'ya dönüştürür; klavyenizde ister özel tuşlar olsun ister birçok dizüstü bilgisayarın yaptığı gibi bunlar için Right Alt ve Right Ctrl göndersin, bu nedenle Right Alt ve Right Ctrl orada düz değiştiriciler değildir; dikte bunun yerine Alt + Space ile açılıp kapatılır. `Ctrl + Space`, Tmux ve Herdr için kullanılabilir durumda kalır; `Shift + CapsLock` oluşturma tuşu olarak kalır.

Birden çok klavye düzeniniz veya girdi yönteminiz olduğunda klavye göstergesi çubuğun sağında görünür. Giriş dilleri arasında geçiş yapmak için tıklayın; Japonca, hiragana için あ gösterir. Japonca karakter seçimleri için Japonca'ya geçin, `nihongo` gibi bir sözcük yazın, ardından iki kez Space'e basın. Seçiminizi kabul etmek için Enter'a basın. Birden çok klavye düzeniniz de varsa, bunları döndürmek için göstergeye sağ tıklayın.

İngilizce ve Fransızca gibi düzenleri seçmek için, kurulum sırasında sunulan aynı seçeneklerden _Kurulum > Klavye > Klavye Girdileri_ öğesini kullanın. Hangi oluşturma motorlarının etkin olduğunu seçmek için _Kurulum > Klavye > Girdi Yöntemleri_ öğesini kullanın. Her iki seçici de Omarchy menüsü içinde mevcut seçimleriniz işaretli olarak açılır. Bir seçimi açıp kapatmak için tıklayın veya Enter'a basın; her değişiklik hemen uygulanır. Bir girdi yönteminin seçimini kaldırmak, onu sistemden kaldırmadan döngüden çıkarır; klavye kullanılabilir kalmaya devam eder.

Aynı seçicileri açmak için `omarchy setup keyboard` veya `omarchy setup input` çalıştırın. Komut satırından tek bir dil eklemek için `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` veya `cangjie5` kullanın. Quick, Boshiamy ve Array, Cangjie ile aynı pakette gelir ve Girdi Yöntemleri seçicisinde görünür. Özel geçiş tuşlarınız korunur. Alternatif motor düzenleri veya tuşları için, `omarchy pkg add fcitx5-configtool` ile `fcitx5-configtool` kurun ve bir terminalden başlatın. Bir giriş dili seçmek masaüstü dilini değiştirmez. _Kurulum > Dil_ altında Japonca, Korece veya Çince seçmek, henüz hiç yoksa onun girdi yöntemini ekler.

Girdi yöntemleri veya klavye düzenleri arasında geçiş yapmak için `Super + I`, diğer yöne geri gitmek için `Super + Shift + I` kullanın; böylece üç tane yapılandırılmışken iki komşu arasında hareket edebilirsiniz. Giriş göstergesi, yalnızca birden fazla girdi yöntemi veya düzeni yapılandırıldığında çubuğun sağında görünür. Bu masaüstü bağlaması, mevcut Fcitx geçiş tuşlarınızla birlikte çalışır; onu `~/.config/hypr/bindings.lua` içinde geçersiz kılabilirsiniz. Giriş motorları ve oluşturma dizileri, her oturumda zaten çalışan [Fcitx5](https://fcitx-im.org/) hizmetini kullanır.

### ALT'yi SUPER Olarak Kullanma

Bazı klavyelerde, birincil meta tuşunu (Windows/cmd tuşu) SUPER olarak kullanmak uygun değildir. Bunu bunun yerine ALT olacak şekilde şu değişiklikle değiştirebilirsiniz:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
