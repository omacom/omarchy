# Kendi temanızı yapma

Kendi temalarınızı `~/.config/omarchy/themes` konumuna ekleyebilirsiniz. Mevcut temalardan birini baz olarak kopyalayın (`/usr/share/omarchy/themes` konumuna bakın), sonra gönlünüzce değiştirin. Temanız o klasörün içinde olduğu sürece tema seçim menüsüne dahil edilir.

Değiştirmeniz gereken ana dosya `colors.toml` dosyasıdır. Bu dosya, terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt uygulamaları, klavye arka ışığı, giriş yöntemi, ekran paylaşımı seçicisi, uygulama simgeleri, çeşitli AI araçları (Claude, Pi, Hermes, T3 Code, Herdr) ve tüm Omarchy kabuğu (üst çubuk, menü, bildirimler, OSD ve kilit ekranı) için yapılandırmalar oluşturmakta kullanılan renk kümesini tanımlar.

Dahil edilen Aether uygulamasını da kullanarak, renklerle oynayabileceğiniz ve arka planlar arayabileceğiniz hoş bir GUI arayüzüyle yeni bir tema oluşturabilirsiniz. Uygulamayı `Super + Alt + Space` ile uygulama ızgarasından başlatmanız yeterlidir.

### Yüklü bir tema neler içerebilir

`~/.config/omarchy/themes` içinde kendiniz yazdığınız bir tema istediğiniz her şeyi içerebilir — bu sizin makineniz ve sizin dosyanız, Omarchy de hepsini uygular.

Başkasının deposundan `omarchy theme install` ile yüklediğiniz bir tema, renk olan her şeyi korur ve makinenizde kod çalıştıracak bir avuç dosyayı kaybeder: tüm `.lua` dosyaları, terminal yapılandırmaları (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ve `vscode.json`. Bir temanın `hyprland.lua` dosyası, compositor'ınızın oturum açarken çalıştırdığı Lua'dır, bir terminal yapılandırması terminalinizin başlattığı programı belirtir ve `vscode.json` yüklenecek bir VSCode uzantısını belirtir. Birinin temasını yüklemek masaüstünüzün görünümünü değiştirmelidir, ne çalıştırdığını asla değiştirmemelidir.

Diğer her şey tema yazarının yazdığı gibi aynen çalışır — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, arka planlar ve önizlemeler korunur. Yalnızca atılanlar makinenizde `colors.toml` dosyasından yeniden oluşturulur.

Omarchy, ikisini temanın içinde kendi git deposu olup olmadığına göre ayırt eder; `omarchy theme install` klonladığında geride bıraktığı şey budur. Böylece sizin yazdığınız bir tema sizin olarak kalır, internetten çektiğiniz bir tema da renkler olarak kalır.

### Açık mod

Açık mod teması yapıyorsanız, `colors.toml` dosyanızın en üstüne `mode = "light"` satırını ekleyin. Sonra tüm uygulamalar için otomatik olarak açık modla eşleştirilir. (Eski yöntem olan, temanızın köküne `light.mode` adlı boş bir dosya bırakmak da hâlâ çalışır.)

### Kilit açma görseli

`unlock.png` ve `preview-unlock.png` görselleriyle gelen temalar _Görünüm > Kilit Açma_ altında listelenir. `unlock.png` dosyanız tercihen şeffaf bir png olmalıdır. Önizleme görselini de `omarchy plymouth preview` kullanarak oluşturabilirsiniz.

### Omarchy'nin kapsamadığı uygulamaları temalandırma

O listede olmayan bir uygulama kullanıyorsanız, bir şablonla Omarchy'ye onu nasıl temalandıracağını kendiniz öğretebilirsiniz. `~/.config/omarchy/themed/` içine, oluşturduğu yapılandırmanın adını ve `.tpl` uzantısını taşıyan bir dosya bırakın ve yapılandırmayı `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` ile `{{ color15 }}` arası değerler ve paletin geri kalanını yer tutucu olarak kullanarak yazın. Tema her değiştirdiğinizde dosya, o temanın renkleriyle yeniden oluşturulur.

O klasörde kopyalamanız için tamamen yorumlarla açıklanmış bir `alacritty.toml.tpl.sample` vardır — kullanabileceğiniz her değişkeni, ayrıca renklerini `#` olmadan veya ondalık RGB olarak isteyen uygulamalar için `_strip` ve `_rgb` değiştiricilerini listeler. Şablonlarınız Omarchy'nin kendi şablonlarına göre önceliklidir, bu yüzden bunu yerleşik bir uygulamanın nasıl temalandırıldığını geçersiz kılmak için de kullanabilirsiniz.

### Temanızı dağıtma

Temanızı başkalarının kullanabilmesi için dağıtmak istiyorsanız, onu GitHub gibi herkese açık bir git sunucusuna koymanız gerekir. Sonra insanlar, o URL'yi kullanarak Omarchy menüsündeki _Kurulum > Stil > Tema_ yoluyla temanızı yükleyebilir. `omarchy-[themename]-theme` adlandırma kuralını izlemeniz önerilir, çünkü tema yüklendikten sonra tema seçim menüsünde yalnızca `[themename]` olarak doğru şekilde görünür.

Geriye kalan o `[themename]` kısmı temanın dizin adı olur, bu yüzden Omarchy'nin güvenle kullanabileceği bir ad olmalıdır: bir harf, bir rakam veya bir alt çizgi ile başlamalı, geri kalanı harf, rakam, `.`, `_`, `+` ve `-` içerebilir. Büyük harfler sizin için küçük harfe çevrilir, ancak bunun dışındaki her şey — bir boşluk, bir tırnak işareti, İngilizce olmayan bir karakter — bir dizin adına dönüştürülmek yerine yükleme sırasında reddedilir. Böylece `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ve `omarchy-c++-theme` temalarının hepsi sorunsuz yüklenir.

Bir depodan yüklendikten sonra, beraberinde gelen tüm `.lua` dosyalarının, terminal yapılandırmalarının veya `vscode.json` dosyasının atıldığını unutmayın; bu yüzden temanızı bunların üzerine kurmayın.

Temanızın [ekstra temalar sayfasına](https://omarchy.org/themes/) eklenmesini, [omarchy-site deposuna](https://github.com/omacom-io/omarchy-site) bir pull request göndererek sağlayabilirsiniz.
