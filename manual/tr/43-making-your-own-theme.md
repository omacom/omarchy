# Kendi temanızı oluşturmak

Kendi temalarınızı `~/.config/omarchy/themes` konumuna ekleyebilirsiniz. Mevcut temalardan birini temel olarak kopyalayın (`/usr/share/omarchy/themes` konumuna bakın), sonra gönlünüzce ince ayar yapın. Temanız o klasörün içinde olduğu sürece tema seçim menüsüne dahil edilir.

Düzenlemeniz gereken ana dosya `colors.toml` dosyasıdır. Bu dosya, daha sonra terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt uygulamaları, klavye arka aydınlatması, giriş yöntemi, ekran paylaşımı seçici, uygulama simgeleri, çeşitli AI araçları (Claude, Pi, Hermes, T3 Code, Herdr) ve tüm Omarchy kabuğu (üst çubuk, menü, bildirimler, OSD ve kilit ekranı) için yapılandırmalar oluşturmakta kullanılan renk kümesini tanımlar.

Dahil edilen Aether uygulamasını da renklerle oynayıp arka planlar aramanıza olanak tanıyan hoş bir GUI arayüzüyle yeni bir tema oluşturmak için kullanabilirsiniz. Uygulama ızgarasından `Super + Alt + Space` ile başlatmanız yeterli.

### Yüklü bir tema neleri içerebilir

`~/.config/omarchy/themes` içinde kendiniz yazdığınız bir tema dilediğiniz her şeyi içerebilir — bu sizin makineniz ve sizin dosyanız, Omarchy de hepsini uygular.

Başkasının repo'sundan `omarchy theme install` ile yüklediğiniz bir tema, renk olan her şeyi korur ve makinenizde kod çalıştıracak bir avuç dosyayı kaybeder: herhangi bir `.lua` dosyası, terminal yapılandırmaları (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ve `vscode.json`. Bir temanın `hyprland.lua` dosyası, compositor'ınızın oturum açarken çalıştırdığı Lua'dır, bir terminal yapılandırması terminalinizin başlattığı programı adlandırır ve `vscode.json` yüklenecek bir VSCode uzantısını adlandırır. Birinin temasını yüklemek masaüstünüzün nasıl göründüğünü değiştirmelidir, ne çalıştırdığını asla.

Geriye kalan her şey tema yazarının yazdığı gibi aynen çalışmaya devam eder — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, arka planlar ve önizlemelerin hepsi korunur. Yalnızca düşürülenler makinenizde `colors.toml` dosyasından yeniden oluşturulur.

Omarchy ikisini, temanın içinde kendi git repo'su olup olmadığına bakarak ayırt eder; `omarchy theme install` klonladığında geride bıraktığı şey de budur. Böylece yazdığınız tema sizde kalır, internetten çektiğiniz bir tema ise sadece renkler olarak kalır.

### Aydınlık mod

Aydınlık mod teması yapıyorsanız, `colors.toml` dosyanızın en üstüne `mode = "light"` yazın. Böylece tüm uygulamalar için otomatik olarak aydınlık mod ile eşleştirilir. (Temanızın köküne `light.mode` adlı boş bir dosya bırakma şeklindeki eski yöntem de hâlâ çalışır.)

### Açılış ve oturum açma ekranları

Açılışta sürücü parolasını soran ekran ve oturum açma ekranı, Omarchy logosunu temanızın `background` rengi üzerine `accent` rengiyle çizer; parola alanı `foreground` rengindedir ve yanlış parola için `red` kullanılır. Bunlar için fazladan göndereceğiniz bir şey yoktur: Omarchy artık bir temanın `unlock.png` veya `preview-unlock.png` dosyalarını kullanmıyor. Apple Silicon Mac'lerde sürücü parolası ekranı tema ne olursa olsun Omarchy'nin varsayılan görünümünü korur.

### Omarchy'nin kapsamadığı uygulamaları temalandırma

O listede olmayan bir uygulama kullanıyorsanız, bir şablonla Omarchy'ye onu kendiniz temalandırmayı öğretebilirsiniz. `~/.config/omarchy/themed/` içine, oluşturduğu yapılandırmanın adını artı `.tpl` uzantısını taşıyan bir dosya bırakın ve yapılandırmayı yer tutucu olarak `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` ile `{{ color15 }}` arası ve paletin geri kalanıyla yazın. Tema değiştirdiğiniz her seferde dosya o temanın renkleriyle yeniden oluşturulur.

O klasörde kopyalamanız için tamamen açıklamalı bir `alacritty.toml.tpl.sample` vardır — kullanabileceğiniz her değişkeni, ayrıca renklerini `#` olmadan veya ondalık RGB olarak isteyen uygulamalar için `_strip` ve `_rgb` değiştiricilerini listeler. Şablonlarınız Omarchy'nin kendi şablonlarına göre önceliklidir, dolayısıyla bunu yerleşik bir uygulamanın nasıl temalandırılacağını geçersiz kılmak için de kullanabilirsiniz.

### Temanızı dağıtma

Temanızı başkalarının kullanabilmesi için dağıtmak istiyorsanız, onu GitHub gibi herkese açık bir git sunucusuna koymanız gerekir. Ardından insanlar o URL'yi kullanarak Omarchy menüsünde _Install > Style > Theme_ yoluyla yükleyebilir. `omarchy-[themename]-theme` adlandırma kuralını izlemeniz önerilir, çünkü tema yükleme sonrasında tema seçim menüsünde doğru şekilde yalnızca `[themename]` olarak görünür.

Geride kalan o `[themename]` temanın dizin adı olur, dolayısıyla Omarchy'nin güvenle oradan oraya verebileceği bir ad olmalıdır: bir harf, bir rakam veya bir alt çizgi ile başlamalı, geri kalanı harfler, rakamlar, `.`, `_`, `+` ve `-` içerebilir. Büyük harfler sizin için küçük harfe çevrilir, ancak başka herhangi bir şey — bir boşluk, bir tırnak işareti, İngilizce olmayan bir karakter — bir dizin adına dönüştürülmek yerine yükleme sırasında reddedilir. Dolayısıyla `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ve `omarchy-c++-theme` temalarının hepsi sorunsuz yüklenir.

Bir repo'dan yüklendikten sonra, beraberinde gelen herhangi bir `.lua`, terminal yapılandırması veya `vscode.json` dosyasının düşürüleceğini unutmayın, bu yüzden temayı bunların etrafında kurmayın.

[omarchy-site repo'suna](https://github.com/omacom-io/omarchy-site) bir pull request göndererek temanızın [ekstra temalar sayfasına](https://omarchy.org/themes/) eklenmesini sağlayabilirsiniz.
